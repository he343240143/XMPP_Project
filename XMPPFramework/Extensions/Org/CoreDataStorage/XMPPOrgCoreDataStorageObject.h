//
//  XMPPOrgCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"

/**
 *  The org state tag
 */
typedef NS_ENUM(NSInteger, XMPPOrgCoreDataStorageObjectState){
    /**
     *  This value indicating that the object is a templete
     */
    XMPPOrgCoreDataStorageObjectStateTemplate = -1,
    /**
     *  This value indicating that the object had been end
     */
    XMPPOrgCoreDataStorageObjectStateEnd,
    /**
     *  This value indicating that the object is during running
     */
    XMPPOrgCoreDataStorageObjectStateActive
};

@interface XMPPOrgCoreDataStorageObject : XMPPManagedObject

@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * orgName;
@property (nonatomic, retain) NSString * orgPhoto;
// org state: -1==>template, 0==>org has been ended , 1==>org is been running
@property (nonatomic, retain) NSNumber * orgState;
@property (nonatomic, retain) NSDate * orgStartTime;
@property (nonatomic, retain) NSDate * orgEndTime;
@property (nonatomic, retain) NSString * orgAdminJidStr;
@property (nonatomic, retain) NSString * orgDescription;
@property (nonatomic, retain) NSString * streamBareJidStr;
// when the positons of a org had been update,this value will been updated
@property (nonatomic, retain) NSString * ptTag;
// when the users of a org had been update,this value will been updated
@property (nonatomic, retain) NSString * userTag;
// when the relationship org list of a org had been update,this value will been updated
@property (nonatomic, retain) NSString * relationShipTag;


+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                         withOrgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                           withOrgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDic:(NSDictionary *)dic;

@end