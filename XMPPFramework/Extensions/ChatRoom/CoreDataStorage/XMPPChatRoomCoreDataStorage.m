//
//  XMPPChatRoomCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/25.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatRoomCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

@interface XMPPChatRoomCoreDataStorage () <XMPPChatRoomStorage,XMPPChatRoomQueryModuleStorage>

@end

@implementation XMPPChatRoomCoreDataStorage
static XMPPChatRoomCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPChatRoomCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    XMPPLogTrace();
    [super commonInit];
    
    // This method is invoked by all public init methods of the superclass
    autoRemovePreviousDatabaseFile = YES;
    autoRecreateDatabaseFile = YES;
    
    chatRoomPopulationSet = [[NSMutableSet alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPChatRoomCoreDataStorageObject *)chatRoomForID:(NSString *)id
                                           xmppStream:(XMPPStream *)stream
                                 managedObjectContext:(NSManagedObjectContext *)moc
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    XMPPLogTrace();
    
    if (id == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (stream == nil)
        predicate = [NSPredicate predicateWithFormat:@"jid == %@", id];
    else
        predicate = [NSPredicate predicateWithFormat:@"jid == %@ AND streamBareJidStr == %@",
                     id, [[self myJIDForXMPPStream:stream] bare]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPChatRoomCoreDataStorageObject *)[results lastObject];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPChatRoomStorage Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)insertChatRoomWithDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                       withNSDictionary:dictionary
                                                       streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
    }];
}

- (void)insertOrUpdateUserWithChatRoomBareJidStr:(NSString *)chatRoomBareJidStr dic:(NSDictionary *)userDic xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        // find the user we want whether 
        XMPPChatRoomUserCoreDataStorageObject *user = [XMPPChatRoomUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                           withBareJidStr:userDic[@"bareJidStr"]
                                                                                                              chatRoomJid:chatRoomBareJidStr
                                                                                                         streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
        if (user) {
            [user updateWithDictionary:userDic];
        }else{
            user = [XMPPChatRoomUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      withNSDictionary:userDic
                                                                           chatRoomJid:chatRoomBareJidStr
                                                                      streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        }
        
        
    }];

}

- (void)handleChatRoomUserChatRoomBareJidStr:(NSString *)chatRoomBareJidStr dictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    NSString *action = dictionary[@"action"];
    NSString *bareJidStr = dictionary[@"bareJidStr"];
    NSString *streamBarJidStr = [[stream myJID] bare];
    
    // 如果被删除的认识自己，那么需要删除自己本地的这个群组
    if ([bareJidStr isEqualToString:streamBarJidStr] && [action isEqualToString:@"remove"]) {
        
        [self deleteChatRoomWithBareJidStr:chatRoomBareJidStr xmppStream:stream];
        
    }else {// 增加或者删除的是别人
        
        [self scheduleBlock:^{
            
            NSManagedObjectContext *moc = [self managedObjectContext];
            
            //When we add or update a object in the coredata system,we all use the updateOrInsert... method
            if ([action isEqualToString:@"remove"]){// 删除被移除聊天室的人员信息
                
                [XMPPChatRoomUserCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                             withID:bareJidStr
                                                                        chatRoomJid:chatRoomBareJidStr
                                                                   streamBareJidStr:streamBarJidStr];
            }else/* if (![action isEqualToString:@"remove"]) */{// 增加或者跟新被增加人的信息
                //action in coredata
                [XMPPChatRoomUserCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                                                 withNSDictionary:dictionary
                                                                                      chatRoomJid:chatRoomBareJidStr
                                                                                 streamBareJidStr:streamBarJidStr];
            }
            
        }];
    }

}

- (void)handleChatRoomUserDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    //MARK:here we will storage the chat room user in to the Core Data system
    //???:Your code here ...
    XMPPLogTrace();
    
    NSString *action = [dictionary objectForKey:@"action"];
    NSString *bareJidStr = [dictionary objectForKey:@"bareJidStr"];
    NSString *chatRoomBareJidStr = [dictionary objectForKey:@"RoomBareJidStr"];
    NSString *streamBarJidStr = [[stream myJID] bare];
    
    if ([bareJidStr isEqualToString:streamBarJidStr] && [action isEqualToString:@"remove"]) {
        
        [self deleteChatRoomWithBareJidStr:chatRoomBareJidStr xmppStream:stream];
        
    }else {
        
        [self scheduleBlock:^{
            
            NSManagedObjectContext *moc = [self managedObjectContext];
           
            //When we add or update a object in the coredata system,we all use the updateOrInsert... method
            if ([action isEqualToString:@"remove"]){
                
                [XMPPChatRoomUserCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                             withID:bareJidStr
                                                                        chatRoomJid:chatRoomBareJidStr
                                                                   streamBareJidStr:streamBarJidStr];
            }else/* if (![action isEqualToString:@"remove"]) */{
            //action in coredata
            [XMPPChatRoomUserCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                                             withNSDictionary:dictionary
                                                                                  chatRoomJid:chatRoomBareJidStr
                                                                             streamBareJidStr:streamBarJidStr];
            }
            
        }];
    }
}

- (void)InsertOrUpdateChatRoomWith:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
       
        if ([chatRoomPopulationSet containsObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]]){
            NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
            
            [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                           withNSDictionary:dic
                                                           streamBareJidStr:streamBareJidStr];
        }else{
            NSString *jid = [dic objectForKey:@"groupid"];
            
            XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:jid
                                                                   xmppStream:stream
                                                         managedObjectContext:moc];
            
            if (chatRoom) {
                
                [chatRoom updateWithDictionary:dic];
                
            }else{
                NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                
                [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                               withNSDictionary:dic
                                                               streamBareJidStr:streamBareJidStr];
            }
        }
        
    }];
}

//
- (void)beginChatRoomPopulationForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        [chatRoomPopulationSet addObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]];
        
        // Clear anything already in the roster core data store.
        //
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        for (XMPPChatRoomCoreDataStorageObject *room in allChatRooms)
        {
            [moc deleteObject:room];
        }
        
    }];
}

- (void)endChatRoomPopulationForXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        [chatRoomPopulationSet removeObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]];
    }];
}

- (void)handleChatRoomDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    //	NSLog(@"NSXMLElement:%@",itemSubElement.description);
    // Remember XML heirarchy memory management rules.
    // The passed parameter is a subnode of the IQ, and we need to pass it to an asynchronous operation.
    NSDictionary *dic = [dictionary copy];
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSString *jid = dic[@"jid"];
        NSString *action = dic[@"action"];
        
        if ([chatRoomPopulationSet containsObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]]){
          
            if ([action isEqualToString:@"dismiss"]) {
                
                NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                
                [XMPPChatRoomCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                         withID:jid
                                                               streamBareJidStr:streamBareJidStr];
                
            }else /*if (![action isEqualToString:@"dismiss"]) */{
                
                XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:jid
                                                                       xmppStream:stream
                                                             managedObjectContext:moc];
                
                if (chatRoom) {
                    [chatRoom updateWithDictionary:dic];
                }else{
                    NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                    
                    [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                                   withNSDictionary:dic
                                                                   streamBareJidStr:streamBareJidStr];
                }
                
            }

        }else{
            
            if ([action isEqualToString:@"dismiss"]) {
                
                NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                
                [XMPPChatRoomCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                         withID:jid
                                                               streamBareJidStr:streamBareJidStr];
                
            }else /*if (![action isEqualToString:@"dismiss"]) */{
                
                XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:jid
                                                                       xmppStream:stream
                                                             managedObjectContext:moc];
                
                if (chatRoom) {
                    [chatRoom updateWithDictionary:dic];
                }else{
                    NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                    
                    [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                                   withNSDictionary:dic
                                                                   streamBareJidStr:streamBareJidStr];
                }

            }
        }
        
    }];

}

- (BOOL)chatRoomExistsWithID:(NSString *)id xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:id
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        result = (chatRoom != nil);
    }];
    
    return result;
}

- (void)clearAllChatRoomsForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        __block NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        [allChatRooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [moc deleteObject:(XMPPChatRoomCoreDataStorageObject *)obj];
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
            
        }];
    }];
}

- (NSArray *)idsForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block NSMutableArray *results = [NSMutableArray array];
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        [allChatRooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [results addObject:((XMPPChatRoomCoreDataStorageObject *)obj).jid];
            
        }];
    
    }];
    
    return results;
}

#if TARGET_OS_IPHONE
- (void)setPhoto:(UIImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream
#else
- (void)setPhoto:(NSImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream
#endif
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:id
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        if (chatRoom){
            chatRoom.photo = photo;
        }
    }];
}

- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    if (!nickname || !bareJidStr) return;
    
    
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:bareJidStr
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        if (chatRoom){
            [chatRoom setNickName:nickname];
        }
    
    }];
}

- (BOOL)isMasterForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:bareChatRoomJidStr
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        //if the chat room obejct is exsited
        //We compare self jid is whether equal to the master bare jid string
        if (chatRoom) {
            result = ([chatRoom.masterBareJidStr isEqualToString:[[stream myJID] bare]]);
        }
    }];
    
    return result;
}

- (BOOL)isMemberOfChatRoomWithBareJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomUserCoreDataStorageObject *user = [XMPPChatRoomUserCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                                                                withBareJidStr:[[stream myJID] bare]
                                                                                                                   chatRoomJid:bareChatRoomJidStr
                                                                                                              streamBareJidStr:[[stream myJID] bare]];
        //if the chat room obejct is exsited
        //We compare self jid is whether equal to the master bare jid string
        result = (user != nil);
    }];
    
    return result;
}

- (BOOL)isUserWithBareJidStr:(NSString *)bareJidStr aMemberOfChatRoom:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    if (!bareJidStr || !bareChatRoomJidStr || !stream) return NO;
    
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPChatRoomUserCoreDataStorageObject *user = [XMPPChatRoomUserCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                                                                withBareJidStr:bareJidStr
                                                                                                                   chatRoomJid:bareChatRoomJidStr
                                                                                                              streamBareJidStr:[[stream myJID] bare]];
        //if the chat room obejct is exsited
        //We compare self jid is whether equal to the master bare jid string
        result = (user != nil);
    }];
    
    return result;
}

- (void)deleteChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr xmppStream:(XMPPStream *)stream
{
    if (!chatRoomBareJidStr || !stream) return;
    
    
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        //delete the chat room
        [XMPPChatRoomCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                 withID:chatRoomBareJidStr
                                                       streamBareJidStr:[[stream myJID] bare]];
       
    }];
    //Delete the user in the chat room
    [self clearAllUserForBareChatRoomJidStr:chatRoomBareJidStr xmppStream:stream];

}

- (void)clearAllUserForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext* moc = [self managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr== %@ AND chatRoomBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare],bareChatRoomJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRoomUser = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        __block NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        [allChatRoomUser enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [moc deleteObject:(XMPPChatRoomUserCoreDataStorageObject *)obj];
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
            
        }];
    }];

}

- (void)deleteUserWithBareJidStr:(NSString *)bareJidStr fromChatRoomWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext * moc = [self managedObjectContext];
        [XMPPChatRoomUserCoreDataStorageObject deleteInManagedObjectContext:moc withID:bareJidStr chatRoomJid:bareChatRoomJidStr streamBareJidStr:[[stream myJID] bare]];
     
        
    }];
}

- (NSArray *)userListForChatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"chatRoomBareJidStr == %@ && streamBareJidStr == %@",bareJidStr,
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];

    }];
    
    return results;

}

- (NSArray *)chatRoomListWithType:(XMPPChatRoomType)type xmppStream:(XMPPStream *)stream
{
    
    XMPPLogTrace();
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ && type == %@",[[self myJIDForXMPPStream:stream] bare],@(type)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];
        
    }];
    
    return results;

}

- (id)chatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    __block XMPPChatRoomCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        result = [XMPPChatRoomCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                               withID:bareJidStr
                                                                     streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
    
    return result;
}
- (id)userInfoFromChatRoom:(NSString *)bareChatRoomJidStr withBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    __block XMPPChatRoomUserCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        result = [XMPPChatRoomUserCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                           withBareJidStr:bareJidStr
                                                                              chatRoomJid:bareChatRoomJidStr
                                                                         streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
    
    return result;
}

- (BOOL)existChatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPChatRoomCoreDataStorageObject *chatRoom = [XMPPChatRoomCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                                                                    withID:bareJidStr streamBareJidStr:[[stream myJID] bare]];
        if (chatRoom != nil) {
            result = YES;
        }
        
    }];
    
    return result;

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPChatRoomQueryModuleStorage Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)privateChatRoomForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
//        NSManagedObjectContext *moc = [self managedObjectContext];
//        
//        XMPPChatRoomCoreDataStorageObject *chatRoom = [XMPPChatRoomCoreDataStorageObject fetchObjectInManagedObjectContext:moc
//                                                                                                                    withID:bareChatRoomJidStr streamBareJidStr:[[stream myJID] bare]];
//        if (chatRoom != nil) {
//            result = YES;
//        }
        
    }];
    
    return result;
}
- (NSString *)chatRoomNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPChatRoomCoreDataStorageObject *chatRoom = [XMPPChatRoomCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                                                                    withID:bareChatRoomJidStr
                                                                                                          streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (chatRoom) {
            result = chatRoom.nickName;
        }
    }];
    
    return result;
}
- (NSString *)userNickNameForBareJidStr:(NSString *)bareJidStr withBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPChatRoomUserCoreDataStorageObject *user = [XMPPChatRoomUserCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                                                                withBareJidStr:bareJidStr
                                                                                                                   chatRoomJid:bareChatRoomJidStr
                                                                                                              streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (user) {
            result = user.nickName;
        }
        
    }];
    
    return result;

}

@end
