//
//  XMPPOrganization.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPP.h"

@protocol XMPPOrgDelegate;
@protocol XMPPOrgStorage;

@class XMPPOrgUserCoreDataStorageObject;

@interface XMPPOrg : XMPPModule
{
    __strong id <XMPPOrgStorage> _xmppOrgStorage;
}

@property (strong, readonly) id <XMPPOrgStorage> xmppOrgStorage;

@property (assign) BOOL autoFetchOrgList;
@property (assign) BOOL autoFetchOrgTemplateList;

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage;
- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

#pragma mark - 获取所有项目
- (void)requestServerAllOrgList;
- (void)requestDBAllOrgListWithBlock:(CompletionBlock)completionBlock;
- (void)clearAllOrgs;

#pragma mark - 获取所有模板
- (void)requestServerAllTemplates;
- (void)requestDBAllTemplatesWithBlock:(CompletionBlock)completionBlock;
- (void)clearAllTemplates;

#pragma mark - 获取一个组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId;

- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId;
- (void)requestDBAllUserListWithOrgId:(NSString *)orgId
                      completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取一个组织的所有关键组织的id
- (void)requestServerAllRelationListWithOrgId:(NSString *)orgId;
- (void)requestDBAllRelationListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock;


#pragma mark - 获取一个组织关联组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId
                                relationOrgId:(NSString *)relationOrgId;

- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                            relationOrgId:(NSString *)relationOrgId
                          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId
                            relationOrgId:(NSString *)relationOrgId;
- (void)requestDBAllUserListWithOrgId:(NSString *)orgId
                        relationOrgId:(NSString *)relationOrgId
                      completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 验证组织name
- (void)checkOrgName:(NSString *)name
     completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 创建组织
- (void)createOrgWithName:(NSString *)name
               templateId:(NSString *)templateId
                selfJobId:(NSString *)jobId
          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 结束组织
- (void)endOrgWithId:(NSString *)orgId
     completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 查询自己可以添加的职位（自己的子职位）列表
- (void)requestDBAllSubPositionsWithPtId:(NSString *)ptId
                                   orgId:(NSString *)orgId
                         completionBlock:(CompletionBlock)completionBlock;

- (void)requestServerAllSubPositionsWithOrgId:(NSString *)orgId
                              completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 查询自己可以添加的成员列表
- (id)requestDBAllSubUsersWithOrgId:(NSString *)orgId superUserBareJidStr:(NSString *)superUserBareJidStr;
- (id)requestDBAllSubUsersWithOrgId:(NSString *)orgId;


#pragma mark - 创建新的职位信息
/**
 *  创建新的职位信息
 *
 *  @param orgId           组织id
 *  @param parentPtId      职位所属上级职位的id
 *  @param ptName          职位名称
 *  @param dpName          职位所属部门名称
 *  @param completionBlock 返回结果block
 */
- (void)createPositionWithOrgId:(NSString *)orgId
                     parentPtId:(NSString *)parentPtId
                         ptName:(NSString *)ptName
                         dpName:(NSString *)dpName
                completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 为某个组织加人
- (void)addUsers:(NSArray *)userBareJids
         joinOrg:(NSString *)orgId
  withPositionId:(NSString *)ptId
 completionBlock:(CompletionBlock)completionBlock;

- (void)fillOrg:(NSString *)orgId
 withPositionId:(NSString *)ptId
  callBackBlock:(CompletionBlock)completionBlock
      withUsers:(NSString *)userBareJid1, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 从某个组织删人
- (void)removeUserBareJidStr:(NSString *)userBareJidStr
                     formOrg:(NSString *)orgId
             completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 订阅某个组织
- (void)subcribeOrgRequestWithSelfOrgId:(NSString *)selfOrgId
                             otherOrgId:(NSString *)otherOrgId
                            description:(NSString *)description
                        completionBlock:(CompletionBlock)completionBlock;

- (void)acceptSubcribeRequestWithSelfOrgId:(NSString *)selfOrgId
                            otherOrgId:(NSString *)otherOrgId
                           description:(NSString *)description
                       completionBlock:(CompletionBlock)completionBlock;

- (void)refuseSubcribeRequestWithSelfOrgId:(NSString *)selfOrgId
                                otherOrgId:(NSString *)otherOrgId
                               description:(NSString *)description
                           completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 取消订阅某个组织
- (void)removeSubcribeOrg:(NSString *)orgId
                  formOrg:(NSString *)formOrg
              description:(NSString *)description
          completionBlock:(CompletionBlock)completionBlock;


#pragma mark - 搜索某个组织
-(void)searchOrgWithName:(NSString *)orgName
         completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 根据某个组织的id获取这个组织的信息
- (void)requestServerOrgWithOrgId:(NSString *)orgId;
- (void)requestDBOrgWithOrgId:(NSString *)orgId
              completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 根据某个组织的id查询他的部门信息
- (void)requestDBOrgDepartmentWithOrgId:(NSString *)orgId
                        completionBlock:(CompletionBlock)completionBlock;

- (void)requestDBOrgDepartmentWithOrgId:(NSString *)orgId
                          relationOrgId:(NSString *)relationOrgId
                        completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 查询成员列表
- (id)requestDBAllUsersWithOrgId:(NSString *)orgId;

#pragma mark - 按部门名称查询部门成员列表
- (id)requestDBAllUsersWithOrgId:(NSString *)orgId 
                          dpName:(NSString *)dpName
                       ascending:(BOOL)ascending;

#pragma mark - 按部门名称查询部门职位列表
- (id)requestDBAllPositionsWithOrgId:(NSString *)orgId
                              dpName:(NSString *)dpName
                           ascending:(BOOL)ascending;

#pragma mark - 根据某个组织的id查询他在数据库中的名称
- (void)requestDBOrgNameWithOrgId:(NSString *)orgId
                  completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 根据某个关联组织的id查询他在数据库中的名称
- (void)requestDBRelationOrgNameWithRelationOrgId:(NSString *)relationOrgId
                                            orgId:(NSString *)orgId
                                  completionBlock:(CompletionBlock)completionBlock;

- (void)relationOrgPhotoWithrelationOrgId:(NSString *)relationOrgId
                                    orgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取一个关联组组的详细信息
- (void)requestServerRelationOrgWithRelationId:(NSString *)relationId
                                         orgId:(NSString *)orgId;

- (void)requestDBRelationOrgWithRelationId:(NSString *)relationId
                                     orgId:(NSString *)orgId
                           completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 自己是否是该工程的admin
- (BOOL)isSelfAdminOfOrgWithOrgId:(NSString *)orgId;

#pragma mark - 查询某个用户是否在某个组织中
- (BOOL)existedUserWithBareJidStr:(NSString *)bareJidStr inOrgWithId:(NSString *)orgId;

#pragma mark - 根据组织id 查询该组织的头像url
- (void)requestDBOrgPhotoWithOrgId:(NSString *)orgId
                   completionBlock:(CompletionBlock)completionBlock;

-(void)getTempHashWithcompletionBlock:(CompletionBlock)completionBlock ;

@end


// XMPPOrganizationDelegate
@protocol XMPPOrgDelegate <NSObject>

@required

@optional

- (void)xmppOrg:(XMPPOrg *)xmppOrg didReceiveSubcribeRequestFromOrgId:(NSString *)fromOrgId fromOrgName:(NSString *)fromOrgName toOrgId:(NSString *)toOrgId;
- (void)xmppOrg:(XMPPOrg *)xmppOrg didReceiveAcceptSubcribeFromOrgId:(NSString *)fromOrgId fromOrgName:(NSString *)fromOrgName toOrgId:(NSString *)toOrgId;
- (void)xmppOrg:(XMPPOrg *)xmppOrg didReceiveRefuseSubcribeFromOrgId:(NSString *)fromOrgId fromOrgName:(NSString *)fromOrgName toOrgId:(NSString *)toOrgId;
- (void)xmppOrg:(XMPPOrg *)xmppOrg didReceiveRemoveSubcribeFromOrgId:(NSString *)fromOrgId fromOrgName:(NSString *)fromOrgName toOrgId:(NSString *)toOrgId;

@end


// XMPPOrganizationStorage
@protocol XMPPOrgStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPOrg *)aParent queue:(dispatch_queue_t)queue;

@optional

- (void)clearOrgsNotInOrgIds:(NSArray *)orgIds isTemplate:(BOOL)isTemplate xmppStream:(XMPPStream *)stream;
- (void)clearOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (void)clearAllOrgWithXMPPStream:(XMPPStream *)stream;
- (void)clearAllTemplatesWithXMPPStream:(XMPPStream *)stream;
- (id)allOrgTemplatesWithXMPPStream:(XMPPStream *)stream;
- (id)allOrgsWithXMPPStream:(XMPPStream *)stream;
- (id)orgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (id)relationOrgWithRelationId:(NSString *)relationId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (id)orgPositionsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgDepartmentWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgUsersWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgPhotoWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)subUsersWithOrgId:(NSString *)orgId superUserBareJidStr:(NSString *)superUserBareJidStr xmppStream:(XMPPStream *)stream;

- (id)usersInDepartmentWithDpName:(NSString *)dpName
                            orgId:(NSString *)orgId
                        ascending:(BOOL)ascending
                       xmppStream:(XMPPStream *)stream;

- (id)positionsInDepartmentWithDpName:(NSString *)dpName
                                orgId:(NSString *)orgId
                            ascending:(BOOL)ascending
                           xmppStream:(XMPPStream *)stream;

- (id)newUsersWithOrgId:(NSString *)orgId userIds:(NSArray *)userIds xmppStream:(XMPPStream *)stream;

- (id)orgRelationsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (void)insertOrUpdateOrgInDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock;

- (void)insertNewCreateOrgnDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock;

- (void)clearUsersWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)clearUsersNotInUserJidStrs:(NSArray *)userJidStrs orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (void)deleteUserWithUserJidStr:(NSString *)userJidStr orgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)deleteUserWithUserBareJidStrs:(NSArray *)userBareJidStrs fromOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdateUserInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;
 
- (void)clearPositionsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)clearPositionsNotInPtIds:(NSArray *)ptIds  orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdatePositionInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;

- (void)clearRelationsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
/*- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;*/
- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId
                                        dic:(NSDictionary *)dic
                                 xmppStream:(XMPPStream *)stream
                                  userBlock:(void (^)(NSString *orgId, NSString *relationOrgId))userBlock
                              positionBlock:(void (^)(NSString *orgId,  NSString *relationOrgId))positionBlock;

- (id)endOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)subPositionsWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (id)positionWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (BOOL)isAdminWithUser:(NSString *)userBareJidStr orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (BOOL)existedUserWithBareJidStr:(NSString *)bareJidStr orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)endOrgWithOrgId:(NSString *)orgId orgEndTime:(NSDate *)orgEndTime xmppStream:(XMPPStream *)stream;
- (void)comparePositionInfoWithOrgId:(NSString *)orgId
                         positionTag:(NSString *)positionTag
                          xmppStream:(XMPPStream *)stream
                        refreshBlock:(void (^)(NSString *orgId))refreshBlock;
- (void)updateUserTagWithOrgId:(NSString *)orgId
                       userTag:(NSString *)userTag
                    xmppStream:(XMPPStream *)stream
                  pullOrgBlock:(void (^)(NSString *orgId))pullOrgBlock;
- (void)updateRelationShipTagWithOrgId:(NSString *)orgId
                       relationShipTag:(NSString *)relationShipTag
                            xmppStream:(XMPPStream *)stream;

- (void)insertSubcribeObjectWithDic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;
- (void)updateSubcribeObjectWithDic:(NSDictionary *)dic accept:(BOOL)accept xmppStream:(XMPPStream *)stream;
- (void)addOrgId:(NSString *)fromOrgId orgName:(NSString *)formOrgName toOrgId:(NSString *)toTogId xmppStream:(XMPPStream *)stream;
- (void)removeOrgId:(NSString *)removeOrgId fromOrgId:(NSString *)fromOrgId xmppStream:(XMPPStream *)stream;

@end
