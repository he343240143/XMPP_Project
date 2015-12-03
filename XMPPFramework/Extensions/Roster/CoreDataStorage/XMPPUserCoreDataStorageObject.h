//
//  XMPPUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/19.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import "XMPPUser.h"
#import "XMPP.h"

@class XMPPGroupCoreDataStorageObject, XMPPResourceCoreDataStorageObject;

@interface XMPPUserCoreDataStorageObject : NSManagedObject
{
    NSInteger section;
}
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, retain) NSString * emailAddress;

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *photo;
#else
@property (nonatomic, strong) NSImage *photo;
#endif

@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * sectionNum;
@property (nonatomic, retain) XMPPJID  * jid;
@property (nonatomic, retain) NSNumber * unreadMessages;
@property (nonatomic, retain) NSString * ask;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSString * subscription;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * englishName;
@property (nonatomic, retain) XMPPResourceCoreDataStorageObject *primaryResource;
@property (nonatomic, retain) NSSet *resources;
@property (nonatomic, retain) NSSet *groups;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withJID:(XMPPJID *)jid
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                          withItem:(NSXMLElement *)item
                  streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithItem:(NSXMLElement *)item;
- (void)updateWithPresence:(XMPPPresence *)presence streamBareJidStr:(NSString *)streamBareJidStr;
- (void)recalculatePrimaryResource;

- (NSComparisonResult)compareByName:(XMPPUserCoreDataStorageObject *)another;
- (NSComparisonResult)compareByName:(XMPPUserCoreDataStorageObject *)another options:(NSStringCompareOptions)mask;

- (NSComparisonResult)compareByAvailabilityName:(XMPPUserCoreDataStorageObject *)another;
- (NSComparisonResult)compareByAvailabilityName:(XMPPUserCoreDataStorageObject *)another
                                        options:(NSStringCompareOptions)mask;

@end

@interface XMPPUserCoreDataStorageObject (CoreDataGeneratedAccessors)

- (void)addResourcesObject:(XMPPResourceCoreDataStorageObject *)value;
- (void)removeResourcesObject:(XMPPResourceCoreDataStorageObject *)value;
- (void)addResources:(NSSet *)value;
- (void)removeResources:(NSSet *)value;

- (void)addGroupsObject:(XMPPGroupCoreDataStorageObject *)value;
- (void)removeGroupsObject:(XMPPGroupCoreDataStorageObject *)value;
- (void)addGroups:(NSSet *)value;
- (void)removeGroups:(NSSet *)value;

@end
