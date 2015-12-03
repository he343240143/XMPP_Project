//
//  XMPPUnReadMessageCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/21.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPUnReadMessageCoreDataStorageObject.h"


@implementation XMPPUnReadMessageCoreDataStorageObject

@dynamic bareJidStr;
@dynamic streamBareJidStr;
@dynamic unReadCount;
@dynamic hasBeenEnd;

#pragma mark -
#pragma mark - Getter/Setters Methods

- (NSString *)bareJidStr
{
    [self willAccessValueForKey:@"bareJidStr"];
    NSString *value = [self primitiveValueForKey:@"bareJidStr"];
    [self didAccessValueForKey:@"bareJidStr"];
    return value;
}
            
- (void)setBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"bareJidStr"];
    [self setPrimitiveValue:value forKey:@"bareJidStr"];
    [self didChangeValueForKey:@"bareJidStr"];
}

- (NSNumber *)unReadCount
{
    [self willAccessValueForKey:@"unReadCount"];
    NSNumber *value = [self primitiveValueForKey:@"unReadCount"];
    [self didAccessValueForKey:@"unReadCount"];
    return value;
}

- (void)setUnReadCount:(NSNumber *)value
{
    [self willChangeValueForKey:@"unReadCount"];
    [self setPrimitiveValue:value forKey:@"unReadCount"];
    [self didChangeValueForKey:@"unReadCount"];
}

- (NSString *)streamBareJidStr
{
    [self willAccessValueForKey:@"streamBareJidStr"];
    NSString *value = [self primitiveValueForKey:@"streamBareJidStr"];
    [self didAccessValueForKey:@"streamBareJidStr"];
    return value;
}

- (void)setStreamBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"streamBareJidStr"];
    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
    [self didChangeValueForKey:@"streamBareJidStr"];
}

- (NSDate *)lastChatTime
{
    [self willAccessValueForKey:@"lastChatTime"];
    NSDate *value = [self primitiveValueForKey:@"lastChatTime"];
    [self didAccessValueForKey:@"lastChatTime"];
    return value;
}

- (void)setLastChatTime:(NSDate *)value
{
    [self willChangeValueForKey:@"lastChatTime"];
    [self setPrimitiveValue:value forKey:@"lastChatTime"];
    [self didChangeValueForKey:@"lastChatTime"];
}

//- (NSNumber *)hasBeenEnd
//{
//    [self willAccessValueForKey:@"hasBeenEnd"];
//    NSNumber *value = [self primitiveValueForKey:@"hasBeenEnd"];
//    [self didAccessValueForKey:@"hasBeenEnd"];
//    return value;
//}
//
//- (void)setHasBeenEnd:(NSNumber *)value
//{
//    [self willChangeValueForKey:@"hasBeenEnd"];
//    [self setPrimitiveValue:value forKey:@"hasBeenEnd"];
//    [self didChangeValueForKey:@"hasBeenEnd"];
//}

- (void)awakeFromInsert
{
    //self.hasBeenEnd = [NSNumber numberWithBool:NO];
}

#pragma mark -
#pragma mark - Public  Methods
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                    withUserJIDstr:(NSString *)jidStr
                unReadMessageCount:(NSUInteger)unReatCount
                      lastChatTime:(NSDate *)lastMessageTime
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (jidStr == nil){
        NSLog(@"XMPPUserCoreDataStorageObject: invalid jid (nil)");
        return nil;
    }
    if (streamBareJidStr == nil) return nil;
    
    XMPPUnReadMessageCoreDataStorageObject *newObject;
    newObject = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPUnReadMessageCoreDataStorageObject"
                                            inManagedObjectContext:moc];
    
    newObject.bareJidStr = jidStr;
    newObject.streamBareJidStr = streamBareJidStr;
    newObject.unReadCount = [NSNumber numberWithUnsignedInteger:unReatCount];
    newObject.lastChatTime = lastMessageTime;
    
    return newObject;
}

+ (BOOL)deleteObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                            withUserJIDstr:(NSString *)jidStr
                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (jidStr == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPUnReadMessageCoreDataStorageObject *deleteObject = [XMPPUnReadMessageCoreDataStorageObject objectInManagedObjectContext:moc withUserJIDStr:jidStr streamBareJidStr:streamBareJidStr];
    
    if (!deleteObject) return NO;
    
    [moc deleteObject:deleteObject];
    
    return YES;
}


+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                    withUserJIDStr:(NSString *)jidStr
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (jidStr == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUnReadMessageCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@",
                              jidStr, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPUnReadMessageCoreDataStorageObject *)[results lastObject];
}

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                    withUserJIDstr:(NSString *)jidStr
                                unReadMessageCount:(NSUInteger)unReadCount
                                      lastChatTime:(NSDate *)lastMessageTime
                                  streamBareJidStr:(NSString *)streamBareJidStr
{
    
    if (jidStr == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPUnReadMessageCoreDataStorageObject *updateObject = [XMPPUnReadMessageCoreDataStorageObject objectInManagedObjectContext:moc withUserJIDStr:jidStr streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (updateObject){
        
        updateObject.bareJidStr = jidStr;
        updateObject.unReadCount = [NSNumber numberWithUnsignedInteger:([updateObject.unReadCount unsignedIntegerValue]+unReadCount)];
        updateObject.streamBareJidStr = streamBareJidStr;
        if (lastMessageTime) {
            updateObject.lastChatTime = lastMessageTime;
        }
        
        return YES;
        
    }else{//if not find the object in the CoreData system ,we should insert the new object to it
        //FIXME:There is a bug meybe here
        updateObject = [XMPPUnReadMessageCoreDataStorageObject insertInManagedObjectContext:moc
                                                                             withUserJIDstr:jidStr
                                                                         unReadMessageCount:unReadCount
                                                                               lastChatTime:lastMessageTime
                                                                           streamBareJidStr:streamBareJidStr];
        return YES;
    }
    
    return NO;
}

+ (BOOL)readObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                          withUserJIDstr:(NSString *)jidStr
                        streamBareJidStr:(NSString *)streamBareJidStr
{
    if (jidStr == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPUnReadMessageCoreDataStorageObject *readObject = [XMPPUnReadMessageCoreDataStorageObject objectInManagedObjectContext:moc withUserJIDStr:jidStr streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (!readObject) return NO;
    
    readObject.unReadCount = [NSNumber numberWithUnsignedInteger:0];
    
    return YES;
}

+ (BOOL)readOneObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                             withUserJIDstr:(NSString *)jidStr
                           streamBareJidStr:(NSString *)streamBareJidStr
{
    if (jidStr == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPUnReadMessageCoreDataStorageObject *readObject = [XMPPUnReadMessageCoreDataStorageObject objectInManagedObjectContext:moc withUserJIDStr:jidStr streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (!readObject) return NO;
    
    NSUInteger oldUnreadCount = [readObject.unReadCount unsignedIntegerValue];
    
    if (oldUnreadCount > 0) {
        --oldUnreadCount;
    }
    readObject.unReadCount = [NSNumber numberWithUnsignedInteger:oldUnreadCount];
    
    return YES;
}

@end
