//
//  XMPPOrgRelationObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"

@interface XMPPOrgRelationObject : XMPPManagedObject 

@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * relationOrgId;
@property (nonatomic, retain) NSString * relationOrgName;
@property (nonatomic, retain) NSString * relationPhoto;
@property (nonatomic, retain) NSString * relationPtTag;
@property (nonatomic, retain) NSString * relationUserTag;
@property (nonatomic, retain) NSString * streamBareJidStr;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withSelfOrgId:(NSString *)selfOrgId
                     relationOrgId:(NSString *)relationOrgId
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)moc
                                 selfOrgId:(NSString *)selfOrgId
                                   withDic:(NSDictionary *)dic
                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                         selfOrgId:(NSString *)selfOrgId
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDic:(NSDictionary *)dic;

- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another;
- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another options:(NSStringCompareOptions)mask;

@end
