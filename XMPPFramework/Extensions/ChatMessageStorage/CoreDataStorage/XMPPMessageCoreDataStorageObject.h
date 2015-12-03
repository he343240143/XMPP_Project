//
//  XMPPMessageCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPAdditionalCoreDataMessageObject.h"

@interface XMPPMessageCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString                              * bareJidStr;
@property (nonatomic, retain) NSNumber                              * messageType;
@property (nonatomic, retain) NSNumber                              * hasBeenRead;
@property (nonatomic, retain) NSNumber                              * isGroupChat;
@property (nonatomic, retain) NSString                              * messageID;
@property (nonatomic, retain) NSDate                                * messageTime;
@property (nonatomic, retain) NSNumber                              * sendFromMe;
@property (nonatomic, retain) NSString                              * streamBareJidStr;
@property (nonatomic, retain) XMPPAdditionalCoreDataMessageObject   * additionalMessage;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withPredicate:(NSPredicate *)predicate;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withMessageID:(NSString *)messageID
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
             withMessageDictionary:(NSDictionary *)messageDic
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                             withMessageDictionary:(NSDictionary *)messageDic
                                  streamBareJidStr:(NSString *)streamBareJidStr;

@end
