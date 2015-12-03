//
//  XMPPChatMesageCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessageCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorageObject.h"
#import "XMPPUnReadMessageCoreDataStorageObject.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "XMPPAllMessage.h"
#import "XMPPAllMessageQueryModule.h"
#import "XMPPMessage+AdditionMessage.h"

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

@interface XMPPMessageCoreDataStorage () <XMPPAllMessageStorage, XMPPAllMessageQueryModuleStorage>
{

}
@end

@implementation XMPPMessageCoreDataStorage
static XMPPMessageCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPMessageCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
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
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tool methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API (XMPPAllMessageStorage Methods)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)configureWithParent:(XMPPAllMessage *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

- (void)archiveMessage:(XMPPExtendMessageObject *)message active:(BOOL)active xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *myBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        [XMPPMessageCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                               withMessageDictionary:[message toDictionaryWithActive:active]
                                                                    streamBareJidStr:myBareJidStr];
        
    }];
}

//When read the message ,we should -1 for the unread message table
- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        [message setHasBeenRead:[NSNumber numberWithBool:YES]];
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPUnReadMessageCoreDataStorageObject readOneObjectInManagedObjectContext:moc
                                                                     withUserJIDstr:message.bareJidStr
                                                                   streamBareJidStr:message.bareJidStr];
        
    }];
}

//we should -1 to the unread message table
- (void)readMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"messageID",messageID,@"streamBareJidStr",
                                      streamBareJidStr];
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withPredicate:predicate];
            if (!updateObject) return;
            
            [updateObject setHasBeenRead:[NSNumber numberWithBool:YES]];
            [XMPPUnReadMessageCoreDataStorageObject readOneObjectInManagedObjectContext:moc
                                                                         withUserJIDstr:updateObject.bareJidStr
                                                                       streamBareJidStr:updateObject.streamBareJidStr];
        }
    }];
}

- (void)readAllUnreadMessageWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            //!!!!:Notice:This method should not read the voice message
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@ && %K == %@ && %K != %@",@"bareJidStr",bareUserJid,@"streamBareJidStr",
                         streamBareJidStr,@"sendFromMe",@0,@"hasBeenRead",@0,@"messageType",@1];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){

            //update the hasBeenRead attribute
            message.hasBeenRead = [NSNumber numberWithBool:YES];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        
        //Update the unread message object
        [XMPPUnReadMessageCoreDataStorageObject readObjectInManagedObjectContext:moc withUserJIDstr:bareUserJid streamBareJidStr:streamBareJidStr];

    }];
}
//When there is only one message ,we should delete the unread message history
- (void)deleteMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withMessageID:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
        
            //The all message count
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                      inManagedObjectContext:moc];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",updateObject.bareJidStr,@"streamBareJidStr",
                                      updateObject.streamBareJidStr];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            [fetchRequest setFetchLimit:2];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setFetchBatchSize:saveThreshold];
            
            NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
            
            //When the all message count is only one,we should delete the chat history
            if ([allMessages count] < 2) {
                [XMPPUnReadMessageCoreDataStorageObject deleteObjectInManagedObjectContext:moc
                                                                            withUserJIDstr:updateObject.bareJidStr
                                                                          streamBareJidStr:streamBareJidStr];
            }
            
            //Delete the message
            [moc deleteObject:updateObject];
        }

    }];
}

//When there is only one message ,we should delete the unread message history
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        //The all message count
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",message.bareJidStr,@"streamBareJidStr",
                                  message.streamBareJidStr];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:2];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        //When the all message count is only one,we should delete the chat history
        if ([allMessages count] < 2) {
            [XMPPUnReadMessageCoreDataStorageObject deleteObjectInManagedObjectContext:moc
                                                                        withUserJIDstr:message.bareJidStr
                                                                      streamBareJidStr:streamBareJidStr];
        }
        
        //Delete the message
        [moc deleteObject:message];
    }];
}

- (void)clearChatHistoryWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareUserJid,@"streamBareJidStr",
                         streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){
            [moc deleteObject:message];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        //Delete the unread message object
        [XMPPUnReadMessageCoreDataStorageObject deleteObjectInManagedObjectContext:moc withUserJIDstr:bareUserJid streamBareJidStr:streamBareJidStr];
    }];
}

- (void)clearAllChatHistoryAndMessageWithXMPPStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                         inManagedObjectContext:moc];
        NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"XMPPUnReadMessageCoreDataStorageObject"
                                                         inManagedObjectContext:moc];
        
        NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
        NSFetchRequest *historyFetchRequest = [[NSFetchRequest alloc] init];
        
        [messageFetchRequest setEntity:messageEntity];
        [messageFetchRequest setFetchBatchSize:saveThreshold];
        
        [historyFetchRequest setEntity:historyEntity];
        [historyFetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"streamBareJidStr",
                         streamBareJidStr];
            
            [messageFetchRequest setPredicate:predicate];
            [historyFetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:messageFetchRequest error:nil];
        NSArray *allChatHistorys = [moc executeFetchRequest:historyFetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){
            [moc deleteObject:message];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        
        for (XMPPUnReadMessageCoreDataStorageObject *history in allChatHistorys){
            [moc deleteObject:history];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}
- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID sendSucceed:(XMPPMessageSendStatusType)sendType xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withMessageID:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            
            [updateObject setHasBeenRead:[NSNumber numberWithInteger:sendType]];
        }

    }];
}
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message success:(BOOL)success xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        [message setHasBeenRead:[NSNumber numberWithBool:success]];
    }];
}

- (void)updateMessageWithNewFilePath:(NSString *)newFilePath messageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withMessageID:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            
            [[updateObject additionalMessage] setFilePath:newFilePath];
            [[updateObject additionalMessage] setFileData:nil];
        }

    }];
}

- (id)lastMessageWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)xmppStream
{
    if (!bareJidStr || !xmppStream) return nil;
    
    __block id result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
       
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareJidStr,@"streamBareJidStr",
                         streamBareJidStr];
        
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        result = (XMPPMessageCoreDataStorageObject *)[allMessages lastObject];
    }];
    
    return result;
}

- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset xmppStream:(XMPPStream *)xmppStream
{
    if (bareJidStr == nil || xmppStream == nil) return nil;
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:NO];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:fetchSize];
        [fetchRequest setFetchOffset:fetchOffset];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareJidStr,@"streamBareJidStr",
                                      streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    
    return results;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPAllMessageQueryModuleStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)messageSendStateWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    __block NSInteger result = 0;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        
        if (stream)
        {
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"messageID",messageID,@"streamBareJidStr",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        XMPPMessageCoreDataStorageObject *message = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        
        if (message) result = [message.hasBeenRead integerValue];
    }];
    
    return result;
}
- (id)messageWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    __block XMPPMessageCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        
        if (stream)
        {
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"messageID",messageID,@"streamBareJidStr",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        XMPPMessageCoreDataStorageObject *message = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        
        if (message) result = message;
    }];
    
    return result;
}

- (void)setAllSendingStateMessagesToFailureStateWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ && sendFromMe == %@ && hasBeenRead == %@",streamBareJidStr,@(YES),@(0)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allSendingStateMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        [allSendingStateMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            XMPPMessageCoreDataStorageObject *message = obj;
            
            message.hasBeenRead = @(-1);
        }];
    }];

}
- (id)allSendingStateMessagesWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allSendingStateMessages = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ && sendFromMe == %@ && hasBeenRead == %@",streamBareJidStr,@(YES),@(0)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        allSendingStateMessages = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    
    return allSendingStateMessages;
}

@end
