//
//  XMPPMessageCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessageCoreDataStorageObject.h"
#import "XMPPUnReadMessageCoreDataStorageObject.h"

@implementation XMPPMessageCoreDataStorageObject

@dynamic bareJidStr;
@dynamic hasBeenRead;
@dynamic messageType;
@dynamic isGroupChat;
@dynamic messageID;
@dynamic additionalMessage;
@dynamic messageTime;
@dynamic sendFromMe;
@dynamic streamBareJidStr;

//This the getter and setters
#pragma mark - Getters/Setters methods
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

- (NSNumber *)hasBeenRead
{
    [self willAccessValueForKey:@"hasBeenRead"];
    NSNumber *value = [self primitiveValueForKey:@"hasBeenRead"];
    [self didAccessValueForKey:@"hasBeenRead"];
    return value;
}

- (void)setHasBeenRead:(NSNumber *)value
{
    [self willChangeValueForKey:@"hasBeenRead"];
    [self setPrimitiveValue:value forKey:@"hasBeenRead"];
    [self didChangeValueForKey:@"hasBeenRead"];
}
- (NSNumber *)isGroupChat
{
    [self willAccessValueForKey:@"isGroupChat"];
    NSNumber *value = [self primitiveValueForKey:@"isGroupChat"];
    [self didAccessValueForKey:@"isGroupChat"];
    return value;
}

- (void)setIsGroupChat:(NSNumber *)value
{
    [self willChangeValueForKey:@"isGroupChat"];
    [self setPrimitiveValue:value forKey:@"isGroupChat"];
    [self didChangeValueForKey:@"isGroupChat"];
}
- (XMPPAdditionalCoreDataMessageObject *)additionalMessage
{
    [self willAccessValueForKey:@"additionalMessage"];
    XMPPAdditionalCoreDataMessageObject *value = [self primitiveValueForKey:@"additionalMessage"];
    [self didAccessValueForKey:@"additionalMessage"];
    return value;
}

- (void)setAdditionalMessage:(XMPPAdditionalCoreDataMessageObject *)value
{
    [self willChangeValueForKey:@"additionalMessage"];
    [self setPrimitiveValue:value forKey:@"additionalMessage"];
    [self didChangeValueForKey:@"additionalMessage"];
}
- (NSNumber *)sendFromMe
{
    [self willAccessValueForKey:@"sendFromMe"];
    NSNumber *value = [self primitiveValueForKey:@"sendFromMe"];
    [self didAccessValueForKey:@"sendFromMe"];
    return value;
}

- (void)setSendFromMe:(NSNumber *)value
{
    [self willChangeValueForKey:@"sendFromMe"];
    [self setPrimitiveValue:value forKey:@"sendFromMe"];
    [self didChangeValueForKey:@"sendFromMe"];
}

- (NSNumber *)messageType
{
    [self willAccessValueForKey:@"messageType"];
    NSNumber *value = [self primitiveValueForKey:@"messageType"];
    [self didAccessValueForKey:@"messageType"];
    return value;
}

- (void)setMessageType:(NSNumber *)value
{
    [self willChangeValueForKey:@"messageType"];
    [self setPrimitiveValue:value forKey:@"messageType"];
    [self didChangeValueForKey:@"messageType"];
}


- (NSDate *)messageTime
{
    [self willAccessValueForKey:@"messageTime"];
    NSDate *value = [self primitiveValueForKey:@"messageTime"];
    [self didAccessValueForKey:@"messageTime"];
    return value;
}

- (void)setMessageTime:(NSDate *)value
{
    [self willChangeValueForKey:@"messageTime"];
    [self setPrimitiveValue:value forKey:@"messageTime"];
    [self didChangeValueForKey:@"messageTime"];
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

- (NSString *)messageID
{
    [self willAccessValueForKey:@"messageID"];
    NSString *value = [self primitiveValueForKey:@"messageID"];
    [self didAccessValueForKey:@"messageID"];
    return value;
}

- (void)setMessageID:(NSString *)value
{
    [self willChangeValueForKey:@"messageID"];
    [self setPrimitiveValue:value forKey:@"messageID"];
    [self didChangeValueForKey:@"messageID"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
}
#pragma mark -
#pragma mark - Public Methods

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withPredicate:(NSPredicate *)predicate
{
    if (moc == nil) return nil;
    if (predicate == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];

    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPMessageCoreDataStorageObject *)[results lastObject];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withMessageID:(NSString *)messageID
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (messageID == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@ AND streamBareJidStr == %@",
                              messageID, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPMessageCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
             withMessageDictionary:(NSDictionary *)messageDic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *messageID = [messageDic objectForKey:@"messageID"];
    if (messageID == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    XMPPMessageCoreDataStorageObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    [newObject updateWithDictionary:messageDic streamBareJidStr:streamBareJidStr];
    
    //Add the unread message count or insert a new unread message info
    [XMPPUnReadMessageCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                                        withUserJIDstr:[messageDic objectForKey:@"bareJidStr"]
                                                                    unReadMessageCount:[(NSNumber *)[messageDic objectForKey:@"unReadMessageCount"] unsignedIntegerValue] lastChatTime:[messageDic objectForKey:@"messageTime"]
                                                                      streamBareJidStr:streamBareJidStr];
    
    return newObject;
}

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                             withMessageDictionary:(NSDictionary *)messageDic
                                  streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *messageID = [messageDic objectForKey:@"messageID"];
    if (messageID == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                      withMessageID:messageID
                                                                                                   streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (updateObject){
        
        [updateObject updateWithDictionary:messageDic streamBareJidStr:streamBareJidStr];
        
        return YES;
        
    }else{//if not find the object in the CoreData system ,we should insert the new object to it
        //FIXME:There is a bug meybe here
        updateObject = [XMPPMessageCoreDataStorageObject insertInManagedObjectContext:moc
                                                                withMessageDictionary:messageDic
                                                                     streamBareJidStr:streamBareJidStr];
        
        if(updateObject != nil) return YES;
    }
    
    return NO;

}

#pragma mark -
#pragma mark - Private Methods
- (void)updateWithDictionary:(NSDictionary *)messageDic streamBareJidStr:(NSString *)streamBareJidStr
{
    NSDate *messageSendTime = [messageDic objectForKey:@"messageTime"];
    
    [self setMessageID:[messageDic objectForKey:@"messageID"]];
    [self setBareJidStr:[messageDic objectForKey:@"bareJidStr"]];
    [self setSendFromMe:[messageDic objectForKey:@"sendFromMe"]];
    [self setMessageTime:(messageSendTime ? messageSendTime:[NSDate date])];
    [self setHasBeenRead:[messageDic objectForKey:@"hasBeenRead"]];
    [self setMessageType:[messageDic objectForKey:@"messageType"]];
    [self setStreamBareJidStr:streamBareJidStr];
    [self setIsGroupChat:[messageDic objectForKey:@"isGroupChat"]];
    [self setAdditionalMessage:[messageDic objectForKey:@"additionalMessage"]];
}

@end


