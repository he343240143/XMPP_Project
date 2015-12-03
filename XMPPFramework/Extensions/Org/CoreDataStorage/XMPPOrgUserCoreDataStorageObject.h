//
//  XMPPOrgUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"

@class XMPPOrgPositionCoreDataStorageObject;

@interface XMPPOrgUserCoreDataStorageObject : XMPPManagedObject

@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSString * userJidStr;
@property (nonatomic, retain) XMPPOrgPositionCoreDataStorageObject *userPtShip;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                             orgId:(NSString *)orgId
                        userJidStr:(NSString *)userJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                               orgId:(NSString *)orgId
                          userJidStr:(NSString *)userJidStr
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDic:(NSDictionary *)dic;


@end
