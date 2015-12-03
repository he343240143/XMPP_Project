//
//  XMPPUnReadMessageCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/21.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPUnReadMessageCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSDate * lastChatTime;
@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * unReadCount;
@property (nonatomic, retain) NSNumber * hasBeenEnd;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                    withUserJIDstr:(NSString *)jidStr
                unReadMessageCount:(NSUInteger)unReatCount
                      lastChatTime:(NSDate *)lastMessageTime
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                            withUserJIDstr:(NSString *)jidStr
                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                    withUserJIDstr:(NSString *)jidStr
                                unReadMessageCount:(NSUInteger)unReadCount
                                      lastChatTime:(NSDate *)lastMessageTime
                                  streamBareJidStr:(NSString *)streamBareJidStr;
//The method is not implemented
/*
+ (BOOL)editObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                          withUserJIDstr:(NSString *)jidStr
                       nReadMessageCount:(NSUInteger)unReadCount
                        streamBareJidStr:(NSString *)streamBareJidStr;
 */

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                    withUserJIDStr:(NSString *)jidStr
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)readObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                            withUserJIDstr:(NSString *)jidStr
                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)readOneObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                             withUserJIDstr:(NSString *)jidStr
                           streamBareJidStr:(NSString *)streamBareJidStr;

//The method is not implemented
/*
+ (BOOL)clearAllObjectsInInManagedObjectContext:(NSManagedObjectContext *)moc
                               streamBareJidStr:(NSString *)streamBareJidStr;
 */

@end
