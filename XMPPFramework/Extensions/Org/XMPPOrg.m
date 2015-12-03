
//  XMPPOrganization.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrg.h"
#import "XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"
#import "NSString+NSDate.h"
#import "NSDictionary+KeysTransfrom.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

static NSString *const ORG_REQUEST_XMLNS = @"aft:project";
static NSString *const ORG_PUSH_MSG_XMLNS = @"aft:project";
static NSString *const ORG_REQUEST_ERROR_XMLNS = @"aft:error";

static NSString *const REQUEST_ALL_ORG_KEY = @"request_all_org_key";
static NSString *const REQUEST_ALL_TEMPLATE_KEY = @"request_all_template_key";
static NSString *const REQUEST_ORG_POSITION_LIST_KEY = @"request_org_position_list_key";
static NSString *const REQUEST_ORG_USER_LIST_KEY = @"request_org_user_list_key";
static NSString *const REQUEST_ORG_RELATION_LIST_KEY = @"request_org_relation_list_key";
static NSString *const REQUEST_ORG_INFO_KEY = @"request_org_info_key";
static NSString *const REQUEST_RELATION_ORG_INFO_KEY = @"request_relation_org_info_key";

@implementation XMPPOrg
@synthesize xmppOrgStorage = _xmppOrgStorage;
@synthesize autoFetchOrgList;
@synthesize autoFetchOrgTemplateList;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithOrganizationStorage:nil dispatchQueue:queue];
}

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage
{
    return [self initWithOrganizationStorage:storage dispatchQueue:NULL];
}

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppOrgStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        //your code ...

        autoFetchOrgList = NO;
        autoFetchOrgTemplateList = NO;
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    XMPPLogTrace();
    
    if ([super activate:aXmppStream])
    {
        XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
        // Reserved for future potential use
        
        return YES;
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration and Flags
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)autoFetchOrgList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = autoFetchOrgList;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoFetchOrgList:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        autoFetchOrgList = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)autoFetchOrgTemplateList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = autoFetchOrgTemplateList;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoFetchOrgTemplateList:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        autoFetchOrgTemplateList = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may optionally be used by XMPPOrganization classes (declared in XMPPMoudle.h).
 **/
- (GCDMulticastDelegate *)multicastDelegate
{
    return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPOrgStorage>)xmppOrgStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppOrgStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_insertOrUpatePositionWithOrgId:(NSString *)orgId positionDic:(NSDictionary *)positionDic
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [_xmppOrgStorage insertOrUpdatePositionInDBWithOrgId:orgId dic:[positionDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                         @"ptId":@"id",
                                                                                                                         @"ptName":@"name",
                                                                                                                         @"ptLeft":@"left",
                                                                                                                         @"ptRight":@"right",
                                                                                                                         @"dpId":@"part_id",
                                                                                                                         @"dpName":@"part",
                                                                                                                         @"orgId":@"project_id"
                                                                                                                         }]
                                              xmppStream:xmppStream];
}
- (void)_insertOrUpdatePositionWithDic:(NSArray *)positionDics orgId:(NSString *)orgId
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([positionDics count] < 1) return;
    
    NSArray *ptIds = [self _specifiedValuesWithKey:@"id" fromDics:positionDics];
    
    // delete the old data
    [_xmppOrgStorage clearPositionsNotInPtIds:ptIds orgId:orgId xmppStream:xmppStream];
    
    [positionDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //{"id":"1", "name":"项目经理", "left":"1", "right":"20", "part":"领导班子"}
        [_xmppOrgStorage insertOrUpdatePositionInDBWithOrgId:orgId
                                                         dic:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                           @"ptId":@"id",
                                                                                                                           @"ptName":@"name",
                                                                                                                           @"ptLeft":@"left",
                                                                                                                           @"ptRight":@"right",
                                                                                                                           @"dpId":@"part_id",
                                                                                                                           @"dpName":@"part",
                                                                                                                           @"orgId":@"project_id"
                                                                                                                           }]
                                                  xmppStream:xmppStream];
        
    }];
}

- (void)_insertNewOrgAfterCreateOrgId:(NSString *)orgId
                               orgDic:(NSDictionary *)orgDic
                              userDic:(NSDictionary *)userDic
                          positionDic:(NSDictionary *)positionDic
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    __weak typeof(self) weakSelf = self;
    [_xmppOrgStorage insertNewCreateOrgnDBWith:[orgDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                @"orgId":@"id",
                                                                                                @"orgName":@"name",
                                                                                                @"orgPhoto":@"photo",
                                                                                                @"orgState":@"status",
                                                                                                @"orgStartTime":@"start_time",
                                                                                                @"orgEndTime":@"end_time",
                                                                                                @"orgAdminJidStr":@"admin",
                                                                                                @"orgDescription":@"description",
                                                                                                @"ptTag":@"job_tag",
                                                                                                @"userTag":@"member_tag",
                                                                                                @"orgRelationShipTag":@"link_tag",
                                                                                                }]
                                    xmppStream:xmppStream
                                     userBlock:^(NSString *orgId) {
                                         
                                         // 0.request all user info from server
                                         
                                         [weakSelf requestServerAllUserListWithOrgId:orgId];
                                         
                                     } positionBlock:^(NSString *orgId) {
                                         
                                         // 1.request all position info from server
                                         
                                         [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                         
                                     } relationBlock:^(NSString *orgId) {
                                         
                                         // 2.request all relation org info from server
                                         
                                         [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                     }];
    
    [_xmppOrgStorage insertOrUpdateUserInDBWithOrgId:orgId dic:[userDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                 @"userJidStr":@"jid",
                                                                                                                 @"orgId":@"orgId",
                                                                                                                 @"ptId":@"job_id",
                                                                                                                 @"ptName":@"job_name"
                                                                                                                 }]
                                          xmppStream:xmppStream];
    
    [_xmppOrgStorage insertOrUpdatePositionInDBWithOrgId:orgId
                                                     dic:[positionDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                               @"ptId":@"job_id",
                                                                                                               @"ptName":@"job_name",
                                                                                                               @"ptLeft":@"left",
                                                                                                               @"ptRight":@"right",
                                                                                                               @"dpId":@"part_id",
                                                                                                               @"dpName":@"part",
                                                                                                               @"orgId":@"project_id"
                                                                                                               }]
                                              xmppStream:xmppStream];
}

- (void)_insertOrUpateOrgWithOrgId:(NSString *)orgId orgDic:(NSDictionary *)orgDic userDic:(NSDictionary *)userDic
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    
    __weak typeof(self) weakSelf = self;
    [_xmppOrgStorage insertOrUpdateOrgInDBWith:[orgDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                @"orgId":@"id",
                                                                                                @"orgName":@"name",
                                                                                                @"orgPhoto":@"photo",
                                                                                                @"orgState":@"status",
                                                                                                @"orgStartTime":@"start_time",
                                                                                                @"orgEndTime":@"end_time",
                                                                                                @"orgAdminJidStr":@"admin",
                                                                                                @"orgDescription":@"description",
                                                                                                @"ptTag":@"job_tag",
                                                                                                @"userTag":@"member_tag",
                                                                                                @"orgRelationShipTag":@"link_tag",
                                                                                                }]
                                    xmppStream:xmppStream
                                     userBlock:^(NSString *orgId) {
                                         
                                         // 0.request all user info from server
                                         
                                         [weakSelf requestServerAllUserListWithOrgId:orgId];
                                         
                                     } positionBlock:^(NSString *orgId) {
                                         
                                         // 1.request all position info from server
                                         
                                         [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                         
                                     } relationBlock:^(NSString *orgId) {
                                         
                                         // 2.request all relation org info from server
                                         
                                         [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                     }];
    
    [_xmppOrgStorage insertOrUpdateUserInDBWithOrgId:orgId dic:[userDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                 @"userJidStr":@"jid",
                                                                                                                 @"orgId":@"orgId",
                                                                                                                 @"ptId":@"job_id",
                                                                                                                 @"ptName":@"job_name"
                                                                                                                 }]
                                          xmppStream:xmppStream];
}

- (NSArray *)_specifiedValuesWithKey:(NSString *)key fromDics:(NSArray *)dics
{
    if (!dispatch_get_specific(moduleQueueTag)) return nil;
    
    //if ([dics count] < 1) return nil;
    
    __block NSMutableArray *array = [NSMutableArray array];
    
    [dics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        
        [array addObject:[dic objectForKey:key]];
        
    }];
    
    return array;
}

- (void)_insertOrUpateOrgWithDics:(NSArray *)orgDics isTemplate:(BOOL)isTemplate
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    //if ([orgDics count] < 1) return;
    
    __weak typeof(self) weakSelf = self;
    
    
    NSArray *orgIds = [self _specifiedValuesWithKey:@"id" fromDics:orgDics];
    
    [_xmppOrgStorage clearOrgsNotInOrgIds:orgIds isTemplate:isTemplate xmppStream:xmppStream];
    
    [orgDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_xmppOrgStorage insertOrUpdateOrgInDBWith:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                 @"orgId":@"id",
                                                                                                                 @"orgName":@"name",
                                                                                                                 @"orgPhoto":@"photo",
                                                                                                                 @"orgState":@"status",
                                                                                                                 @"orgStartTime":@"start_time",
                                                                                                                 @"orgEndTime":@"end_time",
                                                                                                                 @"orgAdminJidStr":@"admin",
                                                                                                                 @"orgDescription":@"description",
                                                                                                                 @"ptTag":@"job_tag",
                                                                                                                 @"userTag":@"member_tag",
                                                                                                                 @"orgRelationShipTag":@"link_tag"
                                                                                                                 }]
                                                 xmppStream:xmppStream
                                                  userBlock:^(NSString *orgId) {
                                                      
                                                      // 0.request all user info from server
                                                      
                                                      [weakSelf requestServerAllUserListWithOrgId:orgId];
                                                      
                                                  } positionBlock:^(NSString *orgId) {
                                                      
                                                      // 1.request all position info from server
                                                      
                                                      [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                                      
                                                  } relationBlock:^(NSString *orgId) {
                                                      
                                                      // 2.request all relation org info from server
                                                      
                                                      [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                                  }];
        
    }];
}

- (void)_insertNewUserWithDics:(NSArray *)userDics orgId:(NSString *)orgId
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([userDics count] < 1) return;
    
    [userDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_xmppOrgStorage insertOrUpdateUserInDBWithOrgId:orgId
                                                     dic:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                       @"userJidStr":@"jid",
                                                                                                                       @"orgId":@"orgId",
                                                                                                                       @"ptId":@"job_id",
                                                                                                                       @"dpName":@"part"
                                                                                                                       }]
                                              xmppStream:xmppStream];
        
    }];

}

- (void)_resetAllUserWithDics:(NSArray *)userDics orgId:(NSString *)orgId
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([userDics count] < 1) return;
    
    NSArray *userJidStrs = [self _specifiedValuesWithKey:@"jid" fromDics:userDics];
    
    [_xmppOrgStorage clearUsersNotInUserJidStrs:userJidStrs orgId:orgId xmppStream:xmppStream];
    
    [userDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        [_xmppOrgStorage insertOrUpdateUserInDBWithOrgId:orgId
                                                     dic:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                       @"userJidStr":@"jid",
                                                                                                                       @"orgId":@"orgId",
                                                                                                                       @"ptId":@"job_id",
                                                                                                                       @"dpName":@"part"
                                                                                                                       }]
                                              xmppStream:xmppStream];
        
    }];
}


- (void)_insertOrUpdateRelationWithDics:(NSArray *)relationDics orgId:(NSString *)orgId
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([relationDics count] < 1) return;
    
    [_xmppOrgStorage clearRelationsWithOrgId:orgId xmppStream:xmppStream];
    
    [relationDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_xmppOrgStorage insertOrUpdateRelationInDBWithOrgId:orgId
                                                         dic:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                           @"relationOrgId":@"id",
                                                                                                                           @"relationOrgName":@"name",
                                                                                                                           @"relationPhoto":@"photo",
                                                                                                                           @"relationPtTag":@"job_tag",
                                                                                                                           @"relationUserTag":@"member_tag"
                                                                                                                           }] xmppStream:xmppStream
                                                   userBlock:^(NSString *orgId, NSString *relationOrgId) {
                                                       [self requestServerAllUserListWithOrgId:orgId relationOrgId:relationOrgId];
                                                   }
                                               positionBlock:^(NSString *orgId, NSString *relationOrgId) {
                                                   [self requestServerAllPositionListWithOrgId:orgId relationOrgId:relationOrgId];
                                               }];
        
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)clearAllOrgs
{
    dispatch_block_t block = ^{
        [_xmppOrgStorage clearAllOrgWithXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)clearAllTemplates
{
    dispatch_block_t block = ^{
        [_xmppOrgStorage clearAllTemplatesWithXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 根据某个组织的id获取这个组织的信息

- (void)requestServerOrgWithOrgId:(NSString *)orgId
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            // 0. Create a key for storaging completion block
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ORG_INFO_KEY];
            
            // 1. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_project">
              {"project":"xxx"}
             </project>
             </iq>
             */
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_project"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
        }else{
            // 0. tell the the user that can not send a request
            NSLog(@"%@",@"you can not send this iq before logining");
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)requestDBOrgWithOrgId:(NSString *)orgId
              completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        id org = [_xmppOrgStorage orgWithOrgId:orgId xmppStream:xmppStream];
        
        org ? completionBlock(org, nil) : [self _requestServerOrgWithOrgId:orgId completionBlock:completionBlock];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)_requestServerOrgWithOrgId:(NSString *)orgId
                   completionBlock:(CompletionBlock)completionBlock
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
        
        // If the templateId is nil，we should notice the user the info
        // 0. Create a key for storaging completion block
        NSString *requestKey = [self requestKey];;
        
        // 1. add the completionBlock to the dcitionary
        [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
        
        // 2. Listing the request iq XML
        /*
         <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
         <project xmlns="aft:project" type="get_project">
         {"project":"xxx"}
         </project>
         </iq>
         */
        
        // 3. Create the request iq
        NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                forKey:@"project"];
        
        ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                         xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                     attribute:@{@"type":@"get_project"}
                                                                   stringValue:[templateDic JSONString]];
        
        IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                         to:nil
                                                       type:@"get"
                                                         id:requestKey
                                               childElement:organizationElement];
        // 4. Send the request iq element to the server
        [[self xmppStream] sendElement:iqElement];
        
        // 5. add a timer to call back to user after a long time without server's reponse
        [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
        
    }else{
        // 0. tell the the user that can not send a request
        [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
    }
}

- (void)requestDBOrgDepartmentWithOrgId:(NSString *)orgId
                          relationOrgId:(NSString *)relationOrgId
                        completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{
        
        id departMentArray = [_xmppOrgStorage orgDepartmentWithOrgId:(relationOrgId ? :orgId) xmppStream:xmppStream];
        
        if ([departMentArray count] > 0) {
            dispatch_main_async_safe(^{
                completionBlock(departMentArray, nil);
            });
        }else{
            dispatch_main_async_safe(^{
                completionBlock(nil, nil);
            });
            [self requestServerAllPositionListWithOrgId:orgId relationOrgId:relationOrgId];
            [self requestServerAllUserListWithOrgId:orgId relationOrgId:relationOrgId];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)requestDBOrgDepartmentWithOrgId:(NSString *)orgId
                        completionBlock:(CompletionBlock)completionBlock
{
    [self requestDBOrgDepartmentWithOrgId:orgId relationOrgId:nil completionBlock:completionBlock];
}

#pragma mark - 根据某个组织的id查询他在数据库中的名称

- (void)requestDBOrgNameWithOrgId:(NSString *)orgId
                  completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        XMPPOrgCoreDataStorageObject *org = [_xmppOrgStorage orgWithOrgId:orgId xmppStream:xmppStream];
        
        if (org != nil) {
            dispatch_main_async_safe(^{
                completionBlock(org.orgName, nil);
            });
        }else{
            [self _callBackWithMessage:@"There is no result in your database" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 根据某个关联组织的id查询他在数据库中的名称
- (void)requestDBRelationOrgNameWithRelationOrgId:(NSString *)relationOrgId
                                            orgId:(NSString *)orgId
                                  completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        XMPPOrgRelationObject *relation = [_xmppOrgStorage relationOrgWithRelationId:relationOrgId orgId:orgId xmppStream:xmppStream];
        
        if (relation != nil) {
    
            dispatch_main_async_safe(^{
                completionBlock(relation.relationOrgName, nil);
            });
            
        }else{
            [self _callBackWithMessage:@"There is no result in your database" completionBlock:completionBlock];
            [self _requestServerRelationOrgWithRelationId:relationOrgId orgId:orgId completionBlock:NULL];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)relationOrgPhotoWithrelationOrgId:(NSString *)relationOrgId
                                    orgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        XMPPOrgRelationObject *relation = [_xmppOrgStorage relationOrgWithRelationId:relationOrgId orgId:orgId xmppStream:xmppStream];
        
        if (relation != nil) {
            
            dispatch_main_async_safe(^{
                completionBlock(relation.relationPhoto, nil);
            });
            
        }else{
            [self _callBackWithMessage:@"There is no result in your database" completionBlock:completionBlock];
            [self _requestServerRelationOrgWithRelationId:relationOrgId orgId:orgId completionBlock:NULL];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
#pragma mark - 获取所有项目

// 数据库同服务器请求
- (void)requestServerAllOrgList
{
    [self _requestServerAllOrgListWithBlock:NULL];
}

// 逻辑层向数据库请求

- (void)requestDBAllOrgListWithBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *orgs = [_xmppOrgStorage allOrgsWithXMPPStream:xmppStream];
        
        if (orgs.count > 0) {
            dispatch_main_async_safe(^{
                completionBlock(orgs, nil);
            });
        }else{
            [self _requestServerAllOrgListWithBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestServerAllOrgListWithBlock:(CompletionBlock)completionBlock
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
        
        // If the templateId is nil，we should notice the user the info
        
        // 0. Create a key for storaging completion block
        NSString *requestKey = nil;
        if (completionBlock == NULL ) {
            
            requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_ORG_KEY];
            
        }else{
            
            requestKey = [self requestKey];;
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];

        }
        
        // 2. Listing the request iq XML
        /*
         <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
         <project xmlns="aft:project" type="list_project">
         </project>
         </iq>
         */
        
        // 3. Create the request iq
        ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                         xmlns:@"aft:project"
                                                                     attribute:@{@"type":@"list_project"}
                                                                   stringValue:nil];
        
        IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                         to:nil
                                                       type:@"get"
                                                         id:requestKey
                                               childElement:organizationElement];
        // 4. Send the request iq element to the server
        [[self xmppStream] sendElement:iqElement];
        
        // 5. add a timer to call back to user after a long time without server's reponse
        [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
        
    }else{
        if (completionBlock != NULL) {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }
}
#pragma mark - 获取所有模板
- (void)requestServerAllTemplates
{
    
}

- (void)_requestServerAllTemplatesWithBlock:(CompletionBlock)completionBlock
{
    
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    
    if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
        
        
        // 0. Create a key for storaging completion block
        NSString *requestKey = nil;
        if (completionBlock == NULL ) {
            
            requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY];
            
        }else{
            
            requestKey = [self requestKey];;
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
        }
        
        // 2. Listing the request iq XML
        /*
         获取模块请求：
         <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
         <project xmlns="aft:project" type="list_template">
         </project>
         </iq>
         */
        
        // 3. Create the request iq
        
        ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                         xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                     attribute:@{@"type":@"list_template"}
                                                                   stringValue:nil];
        
        IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                         to:nil
                                                       type:@"get"
                                                         id:requestKey
                                               childElement:organizationElement];
        
        
        // 4. Send the request iq element to the server
        [[self xmppStream] sendElement:iqElement];
        
        // 5. add a timer to call back to user after a long time without server's reponse
        [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
        
    }else{
        if (completionBlock != NULL) {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }
}

- (void)requestDBAllTemplatesWithBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *templates = [_xmppOrgStorage allOrgTemplatesWithXMPPStream:xmppStream];
        
        if (templates.count > 0) {
            dispatch_main_async_safe(^{
                completionBlock(templates, nil);
            });
        }else{
            [self _requestServerAllTemplatesWithBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 获取一个组织关联组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId
                                relationOrgId:(NSString *)relationOrgId
{
    [self _requestServerAllPositionListWithOrgId:orgId relationOrgId:relationOrgId completionBlock:NULL];
}

- (void)_requestServerAllPositionListWithOrgId:(NSString *)orgId
                                 relationOrgId:(NSString *)relationOrgId
                               completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            if (!orgId) {
                [self _callBackWithMessage:@"The template id you inputed is nil" completionBlock:completionBlock];
            }
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = nil;
            if (completionBlock == NULL ) {
                
                requestKey = [NSString stringWithFormat:@"%@",REQUEST_ORG_POSITION_LIST_KEY];
                
            }else{
                
                requestKey = [self requestKey];;
                // 1. add the completionBlock to the dcitionary
                [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
                
            }
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft.project" type="get_structure">
             {"project":"xxx"}
             </project>
             </iq>
             */
            NSMutableDictionary *templateDic  = [NSMutableDictionary dictionary];
            // 3. Create the request iq
            if (orgId.length > 0) templateDic[@"project"] = orgId;
            if (relationOrgId.length > 0) templateDic[@"project_target"] = relationOrgId;
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_structure"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            if (completionBlock != NULL) {
                // 0. tell the the user that can not send a request
                [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                            relationOrgId:(NSString *)relationOrgId
                          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *positions = [_xmppOrgStorage orgPositionsWithOrgId:(relationOrgId ? :orgId) xmppStream:xmppStream];
        
        if (positions.count > 0) {
            dispatch_main_async_safe(^{
                completionBlock(positions, nil);
            });
        }else{
            [self _requestServerAllPositionListWithOrgId:orgId
                                           relationOrgId:relationOrgId
                                         completionBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId
                            relationOrgId:(NSString *)relationOrgId
{
    [self _requestServerAllUserListWithOrgId:orgId relationOrgId:relationOrgId completionBlock:NULL];
}

- (void)_requestServerAllUserListWithOrgId:(NSString *)orgId
                             relationOrgId:(NSString *)relationOrgId
                           completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = nil;
            if (completionBlock == NULL ) {
                
                requestKey = [NSString stringWithFormat:@"%@",REQUEST_ORG_USER_LIST_KEY];
                
            }else{
                
                requestKey = [self requestKey];;
                // 1. add the completionBlock to the dcitionary
                [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
                
            }
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_member">
             {"project":"60", "project_target":"61"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
            if (orgId) tempDic[@"project"] = orgId;
            if (relationOrgId) tempDic[@"project_target"] = relationOrgId;
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_member"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            if (completionBlock != NULL) {
                // 0. tell the the user that can not send a request
                [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
            }        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}

- (void)requestDBAllUserListWithOrgId:(NSString *)orgId
                        relationOrgId:(NSString *)relationOrgId
                      completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *users = [_xmppOrgStorage orgUsersWithOrgId:(relationOrgId ? :orgId) xmppStream:xmppStream];
        
        if (users.count > 0) {
            dispatch_main_async_safe(^{
                completionBlock(users, nil);
            });
        }else{
            [self _requestServerAllUserListWithOrgId:orgId
                                       relationOrgId:relationOrgId
                                     completionBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 获取一个关联组组的详细信息
- (void)requestServerRelationOrgWithRelationId:(NSString *)relationId
                                         orgId:(NSString *)orgId
{
    [self _requestServerRelationOrgWithRelationId:relationId orgId:orgId completionBlock:NULL];
}

- (void)requestDBRelationOrgWithRelationId:(NSString *)relationId
                                     orgId:(NSString *)orgId
                           completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        XMPPOrgRelationObject *relation = [_xmppOrgStorage relationOrgWithRelationId:relationId orgId:orgId xmppStream:xmppStream];
        
        if (relation != nil) {
            dispatch_main_async_safe(^{
                completionBlock(relation, nil);
            });
        }else{
            [self _requestServerRelationOrgWithRelationId:relationId
                                                    orgId:orgId
                                          completionBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestServerRelationOrgWithRelationId:(NSString *)relationOrgId
                                          orgId:(NSString *)orgId
                                completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = nil;
            
            if (completionBlock == NULL) {
                requestKey = [NSString stringWithFormat:@"%@",REQUEST_RELATION_ORG_INFO_KEY];
            }else{
                requestKey = [self requestKey];;
                
                // 1. add the completionBlock to the dcitionary
                [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            }
            
            // 2. Listing the request iq XML
            /*
             <iq from="81464048fffd4648915e839d9acebcda@192.168.1.130/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_link_project">
             {"project":"41", "project_target":"50"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
            if (orgId) tempDic[@"project"] = orgId;
            if (relationOrgId) tempDic[@"project_target"] = relationOrgId;
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_link_project"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            if (completionBlock != NULL)
                // 5. add a timer to call back to user after a long time without server's reponse
                [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            if (completionBlock != NULL) {
                // 0. tell the the user that can not send a request
                [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
#pragma mark - 获取一个组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId
{
    [self requestServerAllPositionListWithOrgId:orgId relationOrgId:nil];
}

- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock
{
    [self requestDBAllPositionListWithOrgId:orgId relationOrgId:nil completionBlock:completionBlock];
}

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId
{
    [self requestServerAllUserListWithOrgId:orgId relationOrgId:nil];
}

- (void)requestDBAllUserListWithOrgId:(NSString *)orgId
                      completionBlock:(CompletionBlock)completionBlock
{
    [self requestDBAllUserListWithOrgId:orgId relationOrgId:nil completionBlock:completionBlock];
}

#pragma mark - 获取一个组织的所有关键组织的id
- (void)requestServerAllRelationListWithOrgId:(NSString *)orgId
{
    [self _requestServerAllRelationListWithOrgId:orgId completionBlock:NULL];
}

- (void)_requestServerAllRelationListWithOrgId:(NSString *)orgId
                               completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = nil;
            
            if (completionBlock == NULL) {
                requestKey = [NSString stringWithFormat:@"%@",REQUEST_ORG_RELATION_LIST_KEY];
            }else{
                requestKey = [self requestKey];;
                
                // 1. add the completionBlock to the dcitionary
                [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            }

            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_link_project">
             {"project":"60"}
             </project>
             </iq>
             
             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:orgId,@"project", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_link_project"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
    
}
- (void)requestDBAllRelationListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *relations = [_xmppOrgStorage orgRelationsWithOrgId:orgId xmppStream:xmppStream];
        
        if ([relations count] > 0) {
            dispatch_main_async_safe(^{
                completionBlock(relations, nil);
            });
        }else{
            [self _requestServerAllRelationListWithOrgId:orgId
                                         completionBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)checkOrgName:(NSString *)name
     completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
        
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="project_name_exist">
             {"name":"星河丹堤"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:name
                                                                    forKey:@"name"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"project_name_exist"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (void)createOrgWithName:(NSString *)name
               templateId:(NSString *)templateId
                selfJobId:(NSString *)jobId
          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="create">
             {"name": "星河丹堤", "template":"41", "job":"1"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",templateId,@"template",jobId,@"job", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"create"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}
- (void)endOrgWithId:(NSString *)orgId
     completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="set">
             <project xmlns="aft.project"  type="finish">
             {"project": "40"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"finish"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (void)requestDBOrgPhotoWithOrgId:(NSString *)orgId
                   completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSString *photo = [_xmppOrgStorage orgPhotoWithOrgId:orgId xmppStream:xmppStream];
        
        if (photo != nil) {
            dispatch_main_async_safe(^{
                completionBlock(photo, nil);
            });
        }else{
            [self _requestDBOrgPhotoWithOrgId:orgId
                              completionBlock:completionBlock];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestDBOrgPhotoWithOrgId:(NSString *)orgId
                    completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            if (!orgId) {
                [self _callBackWithMessage:@"The template id you inputed is nil" completionBlock:completionBlock];
            }
            
            // fetch data from database
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="c834580a878d43088fa382bac1530603@192.168.1.130/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_photo">
             {"project":"41"}
             </project>
             </iq>
             */
            NSDictionary *templateDic  =nil;
            // 3. Create the request iq
            if (orgId.length>0) {
                templateDic = [NSDictionary dictionaryWithObject:orgId
                                                          forKey:@"project"];
            }
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_photo"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)existedUserWithBareJidStr:(NSString *)bareJidStr inOrgWithId:(NSString *)orgId
{
    __block BOOL isAdmin = NO;
    
    dispatch_block_t block = ^{
        
        isAdmin = [_xmppOrgStorage existedUserWithBareJidStr:bareJidStr orgId:orgId xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return isAdmin;
}

- (BOOL)isSelfAdminOfOrgWithOrgId:(NSString *)orgId
{
    __block BOOL isAdmin = NO;
    
    dispatch_block_t block = ^{
        
        isAdmin = [_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:orgId xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return isAdmin;
}

- (id)requestDBAllUsersWithOrgId:(NSString *)orgId
{
    __block NSArray *users = nil;
    
    dispatch_block_t block = ^{
        
        users = [_xmppOrgStorage orgUsersWithOrgId:orgId xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return users;
}

- (id)requestDBAllUsersWithOrgId:(NSString *)orgId
                          dpName:(NSString *)dpName
                       ascending:(BOOL)ascending
{
    __block NSArray *users = nil;
    
    dispatch_block_t block = ^{
        
        users = [_xmppOrgStorage usersInDepartmentWithDpName:dpName
                                                       orgId:orgId
                                                   ascending:ascending
                                                  xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return users;
}

- (id)requestDBAllPositionsWithOrgId:(NSString *)orgId
                              dpName:(NSString *)dpName
                           ascending:(BOOL)ascending
{
    __block NSArray *positions = nil;
    
    dispatch_block_t block = ^{
        
        positions = [_xmppOrgStorage positionsInDepartmentWithDpName:dpName
                                                               orgId:orgId
                                                           ascending:ascending
                                                          xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return positions;
}

- (id)requestDBAllSubUsersWithOrgId:(NSString *)orgId
{
    return [self requestDBAllSubUsersWithOrgId:orgId superUserBareJidStr:[[xmppStream myJID] bare]];
}

- (id)requestDBAllSubUsersWithOrgId:(NSString *)orgId superUserBareJidStr:(NSString *)superUserBareJidStr
{
    __block NSArray *users = nil;
    
    dispatch_block_t block = ^{
        
        users = [_xmppOrgStorage subUsersWithOrgId:orgId superUserBareJidStr:superUserBareJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return users;
}

- (void)requestDBAllSubPositionsWithPtId:(NSString *)ptId
                                   orgId:(NSString *)orgId
                         completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *positions = [_xmppOrgStorage subPositionsWithPtId:ptId
                                                             orgId:orgId
                                                        xmppStream:xmppStream];
        
        dispatch_main_async_safe(^{
            completionBlock(positions, nil);
        });
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)requestServerAllSubPositionsWithOrgId:(NSString *)orgId
                              completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_children_jobs">
             {"project":"62"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_children_jobs"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}
- (void)createPositionWithOrgId:(NSString *)orgId
                     parentPtId:(NSString *)parentPtId
                         ptName:(NSString *)ptName
                         dpName:(NSString *)dpName
                completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="add_job">
             { "project":"62", "parent_job_id":"277", "job_name":"安装主任2", "part":"领导班子"}
             </project>
             </iq>
             
             */
            
            // 3. Create the request iq
            
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:orgId, @"project",parentPtId,@"parent_job_id",ptName,@"job_name",dpName,@"part", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"add_job"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)addUsers:(NSArray *)userBareJids
         joinOrg:(NSString *)orgId
  withPositionId:(NSString *)ptId
 completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="353303d3e01e45d0a7d2ac436031a5d7@192.168.1.167/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="add_member">
             {"project":"48", "member":[{"job_id":"84", "jid":"855a8e0a42df4c0bb25cbf7e8ad94568@192.168.1.167"}] }
             </project>
             </iq>
             */
        
            // 3. Create the request iq
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            __block NSMutableArray *userArrays = [NSMutableArray array];
            
            [userBareJids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *userBareJid = obj;
                NSDictionary *tempUserDic = @{
                                              @"jid":userBareJid,
                                              @"job_id":ptId
                                              };
                
                [userArrays addObject:tempUserDic];
            }];
            
            [dic setObject:orgId forKey:@"project"];
            [dic setObject:userArrays forKey:@"member"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"add_member"}
                                                                       stringValue:[dic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)fillOrg:(NSString *)orgId
 withPositionId:(NSString *)ptId
  callBackBlock:(CompletionBlock)completionBlock
      withUsers:(NSString *)userBareJid1, ...
{
    __block NSMutableArray *userArrays = [NSMutableArray array];
    
    va_list args;
    va_start(args, userBareJid1);
    
    if (userBareJid1) {
        
        NSString *userBareJid;
        
        while ((userBareJid = va_arg(args, NSString *))) {
            
            NSDictionary *tempUserDic = @{
                                          @"job_id":ptId,
                                          @"jid":userBareJid
                                          };
            [userArrays addObject:tempUserDic];
        }
    }
    
    va_end(args);
    
    
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="353303d3e01e45d0a7d2ac436031a5d7@192.168.1.167/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="add_member">
             {"project":"48", "member":[{"job_id":"84", "jid":"855a8e0a42df4c0bb25cbf7e8ad94568@192.168.1.167"}] }
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            [dic setObject:orgId forKey:@"project"];
            [dic setObject:userArrays forKey:@"member"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"add_member"}
                                                                       stringValue:[dic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)removeUserBareJidStr:(NSString *)userBareJidStr formOrg:(NSString *)orgId completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (![_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:orgId xmppStream:xmppStream]) {
            [self _callBackWithMessage:@"you can not send this request because that you are not the admin of this org" completionBlock:completionBlock];
            return ;
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="delete_member">
             {"project":"40", "jid":"hello6@123"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:orgId,
                                      @"project",userBareJidStr,@"jid", nil];
         
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"delete_member"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

    
}

-(void)searchOrgWithName:(NSString *)orgName
         completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="search_project">
             {"name":"芳"}
             </project>
             </iq>
             */
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:orgName,
                                      @"name", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"search_project"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}
- (void)subcribeOrgRequestWithSelfOrgId:(NSString *)selfOrgId
                             otherOrgId:(NSString *)otherOrgId
                            description:(NSString *)description
                        completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (![_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:selfOrgId xmppStream:xmppStream]) {
            [self _callBackWithMessage:@"you can not send this request because that you are not the admin of this org" completionBlock:completionBlock];
            return ;
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="subscribe">
             {"id_self":"60","id_target":"61"}
             </project>
             </iq>

             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:selfOrgId,@"id_self",otherOrgId,@"id_target", nil];

            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"subscribe"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)acceptSubcribeRequestWithSelfOrgId:(NSString *)selfOrgId
                                otherOrgId:(NSString *)otherOrgId
                               description:(NSString *)description
                           completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (![_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:selfOrgId xmppStream:xmppStream]) {
            [self _callBackWithMessage:@"you can not send this request because that you are not the admin of this org" completionBlock:completionBlock];
            return ;
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="subscribed">
             {"id_self":"49", "id_target":"48"}
             </project>
             </iq>

             
             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:selfOrgId,@"id_self",otherOrgId,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"subscribed"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}
- (void)refuseSubcribeRequestWithSelfOrgId:(NSString *)selfOrgId
                                otherOrgId:(NSString *)otherOrgId
                               description:(NSString *)description
                           completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (![_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:selfOrgId xmppStream:xmppStream]) {
            [self _callBackWithMessage:@"you can not send this request because that you are not the admin of this org" completionBlock:completionBlock];
            return ;
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="unsubscribed">
             {"id_self":"49", "id_target":"48"}
             </project>
             </iq>
             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:selfOrgId,@"id_self",otherOrgId,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"unsubscribed"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
 
}

- (void)removeSubcribeOrg:(NSString *)orgId
                  formOrg:(NSString *)formOrg
              description:(NSString *)description
          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (![_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:formOrg xmppStream:xmppStream]) {
            [self _callBackWithMessage:@"you can not send this request because that you are not the admin of this org" completionBlock:completionBlock];
            return ;
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="unsubscribe">
             {"id_self":"49","id_target":"48"}
             </project>
             </iq>

             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:formOrg,@"id_self",orgId,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"unsubscribe"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}
-(void)getTempHashWithcompletionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_template_hash">
             </project>
             </iq>
             */
            // 3. Create the request iq
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_template_hash"}
                                                                       stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
    
    // fetch all the org list
    if (autoFetchOrgList) [self requestServerAllOrgList];
    if (autoFetchOrgTemplateList) [self requestServerAllTemplates];
}


- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    return [self _executeRequestBlockWithElementName:@"project" xmlns:ORG_REQUEST_XMLNS sendIQ:iq];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:NO];
    
    __weak typeof(self) weakSelf = self;
    
    [requestBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        CompletionBlock completionBlock = (CompletionBlock)obj;
        
        if (completionBlock) {
            
            [weakSelf callBackWithMessage:@"You had disconnect with the server"  completionBlock:completionBlock];
            [requestBlockDcitionary removeObjectForKey:key];
        }
        
    }];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    if ([[iq type] isEqualToString:@"result"] || [[iq type] isEqualToString:@"error"]) {
        
        NSXMLElement *project = [iq elementForName:@"project" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]];
        
        if (project){
            
            NSString *requestkey = [iq elementID];
            NSString *projectType = [project attributeStringValueForName:@"type"];
            
            if([projectType isEqualToString:@"get_structure"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    /*
                     <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/IOS" id="5244001" type="error">
                        <project xmlns="aft.project" type="get_structure"></project>
                        <error code="10003"></error>
                     </iq>
                     */

                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/IOS" id="5244001" type="result">
                    <project xmlns="aft.project" type="get_structure">
                    {"project":"41","structure":[{"id":"xxx", "name":"项目经理", "left":"1", "right":"20", "part":"xxx"}, {...}]}
                    </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                NSArray *positions = [data objectForKey:@"structure"];
                
                [self _insertOrUpdatePositionWithDic:positions orgId:orgId];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ORG_POSITION_LIST_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *positions = [_xmppOrgStorage orgPositionsWithOrgId:orgId xmppStream:xmppStream];
                    
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:positions];
                    
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"list_member"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_member">
                 {"project":"xxx", "member":[{"jid":"xxx", "job_id":"xxx", "job_name":"xxx", "part":"1"}, {} ]}
                 </projec
                 </iq>
                 */
               
                
                // 0.跟新数据库
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                NSArray *users = [data objectForKey:@"member"];
                
                [self _resetAllUserWithDics:users orgId:orgId];
                
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ORG_USER_LIST_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *users = [_xmppOrgStorage orgUsersWithOrgId:orgId xmppStream:xmppStream];
                    
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:users];
                    
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_link_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_link_project">
                 {"self_project":"xxx", "link_project":[ [{"id":"xxx", "name":"xxx"}, {}] } %% modify3
                 </project>
                 </iq
                 */
                
                // 0.跟新数据库
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"self_project"];
                NSArray *relations = [data objectForKey:@"link_project"];
                
                [self _insertOrUpdateRelationWithDics:relations orgId:orgId];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ORG_RELATION_LIST_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *relations = [_xmppOrgStorage orgRelationsWithOrgId:orgId xmppStream:xmppStream];
                    
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:relations];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 正确的结果：
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="list_project">
                 [{"id":"xxx", "name":"xxx", "job_tag":"xxx", "member_tag":"xxx", "link_tag":"xxx"}, ...]
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSArray *orgDics = [[project stringValue] objectFromJSONString];
                
                [self _insertOrUpateOrgWithDics:orgDics isTemplate:NO];

                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *allOrgs = [_xmppOrgStorage allOrgsWithXMPPStream:xmppStream];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:allOrgs];
                    
                }

                return YES;

                
            }else if([projectType isEqualToString:@"list_template"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 正确的结果：("id"-->工程的ID, name-->工程的名称)
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="list_template">
                 {"template": [{"id":"xx", "name":"xxx", "job_tag":"xxx", "member_tag":"xxx"}, ...]} %% modify  如果模板变了，要手动更改job_tag和member_tag.
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSArray *orgDics = [[project stringValue] objectFromJSONString];


                [self _insertOrUpateOrgWithDics:orgDics isTemplate:YES];

                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *templates = [_xmppOrgStorage allOrgTemplatesWithXMPPStream:xmppStream];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:templates];
                    
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"get_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 正确的结果：
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="get_project">
                 [{"id":"xxx", "name":"xxx", "description":"xxx", "status":"xxx", "admin":"xxx", "start_time":"xxx", "end_time":"xxx", "job_tag":"xxx", "member_tag":"xxx", "link_tag":"xxx"}]
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSArray *orgDics = [[project stringValue] objectFromJSONString];
                NSString *orgId = [[orgDics firstObject] objectForKey:@"id"];
                
                __weak typeof(self) weakSelf = self;
                
                [orgDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [_xmppOrgStorage insertOrUpdateOrgInDBWith:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                             @"orgId":@"id",
                                                                                                                             @"orgName":@"name",
                                                                                                                             @"orgPhoto":@"photo",
                                                                                                                             @"orgState":@"status",
                                                                                                                             @"orgStartTime":@"start_time",
                                                                                                                             @"orgEndTime":@"end_time",
                                                                                                                             @"orgAdminJidStr":@"admin",
                                                                                                                             @"orgDescription":@"description",
                                                                                                                             @"ptTag":@"job_tag",
                                                                                                                             @"userTag":@"member_tag",
                                                                                                                             @"orgRelationShipTag":@"link_tag"
                                                                                                                             }]
                                                    xmppStream:xmppStream
                                                     userBlock:^(NSString *orgId) {
                                                         
                                                         // 0.request all user info from server
                                                         
                                                         [weakSelf requestServerAllUserListWithOrgId:orgId];
                                                         
                                                     } positionBlock:^(NSString *orgId) {
                                                         
                                                         // 1.request all position info from server
                                                         
                                                         [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                                         
                                                     } relationBlock:^(NSString *orgId) {
                                                         
                                                         // 2.request all relation org info from server
                                                         
                                                         [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                                     }];
                }];
                
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ORG_INFO_KEY]]) {
                    
                    // 2.向数据库获取数据
                    id data = [_xmppOrgStorage orgWithOrgId:orgId xmppStream:xmppStream];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                    
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"get_link_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 正确的结果：("id"-->工程的ID, name-->工程的名称)
                 <iq from="81464048fffd4648915e839d9acebcda@192.168.1.130/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="get_link_project">
                 {"self_project":"xxx", "link_project":{"id":"xxx", "name":"xxx", "admin":"xxx", "job_tag":"xxx", "member_tag":"xxx"}}
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                id data = [[project stringValue] objectFromJSONString];
                
                NSString *orgId = data[@"self_project"];
                NSDictionary *relationDic = data[@"link_project"];
                NSString *relationOrgId = data[@"id"];
                
                [_xmppOrgStorage insertOrUpdateRelationInDBWithOrgId:orgId
                                                                 dic:[(NSDictionary *)relationDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                                   @"relationOrgId":@"id",
                                                                                                                                   @"relationOrgName":@"name",
                                                                                                                                   @"relationPhoto":@"photo",
                                                                                                                                   @"relationPtTag":@"job_tag",
                                                                                                                                   @"relationUserTag":@"member_tag"
                                                                                                                                   }] xmppStream:xmppStream
                                                           userBlock:^(NSString *orgId, NSString *relationOrgId) {
                                                               [self requestServerAllUserListWithOrgId:orgId relationOrgId:relationOrgId];
                                                           }
                                                       positionBlock:^(NSString *orgId, NSString *relationOrgId) {
                                                           [self requestServerAllPositionListWithOrgId:orgId relationOrgId:relationOrgId];
                                                       }];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_RELATION_ORG_INFO_KEY]]) {
                    
                    // 2.向数据库获取数据
                    XMPPOrgRelationObject *relation = [_xmppOrgStorage relationOrgWithRelationId:relationOrgId orgId:orgId xmppStream:xmppStream];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:relation];
                    
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"project_name_exist"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
                 <project xmlns="aft:project" type="project_name_exist">
                 {"name":"桂芳园"}
                 </project>
                 </iq>

                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"create"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="81464048fffd4648915e839d9acebcda@192.168.1.130/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="create">
                 {
                 "project":{"id":"xxx", "name":"xxx", "job_tag":"xxx", "member_tag":"xxx", "link_tag":"xxx", "start_time":"xxx"} ,
                 "job":{"job_id":"xxx", "job_name":"xxx", "left":"xxx", "right":"xxx", "part":"xxx"},
                 "member":{"jid":"xxx"},
                 }
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                id  data = [[project stringValue] objectFromJSONString];
                
                NSDictionary *orgInfoDic = data[@"project"];
                NSDictionary *positionInfoDic = data[@"job"];
                
                NSString *orgId = orgInfoDic[@"id"];
                NSString *ptId = positionInfoDic[@"job_id"];
                
                NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:data[@"member"]];
                
                userInfoDic[@"job_id"] = ptId;
                
                [self _insertNewOrgAfterCreateOrgId:orgId
                                             orgDic:orgInfoDic
                                            userDic:userInfoDic
                                        positionDic:positionInfoDic];
                
                // 1.返回block
                XMPPOrgCoreDataStorageObject *org = [_xmppOrgStorage orgWithOrgId:orgId xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:org];
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"finish"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft.project"  type="finish">
                 {"project": "40"}
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                // TODO:修改结束时间
                XMPPOrgCoreDataStorageObject *org = [_xmppOrgStorage orgWithOrgId:orgId xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:org];
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_children_jobs"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_children_jobs">
                 {project_id_value:[{"job_id":"123", "job_name":"", "part":"xxx"}, {"job_id":"356", "job_name":"xxx", "part":"xxx"} ]}
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"add_job"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="add_job">
                 {
                    "project":"12345",
                    "job":{"id":"xxx", "name":"项目经理", "left":"1", "right":"20", "part":"xxx"}
                 }
                 </project>
                 </iq>
                 
        
                 
                 push msg:（客户端接收到这个消息后，需要重新去服务器拉组织架构，并重新获取project的job_tag)
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="60" type="add_job">
                 {"job_tag":"xxx"}
                 </sys>
                 </message>
                 */
                // 0.修改数据库
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                NSDictionary *ptInfoDic = [data objectForKey:@"job"];
                NSString *ptId = [ptInfoDic objectForKey:@"id"];
                
                [self _insertOrUpatePositionWithOrgId:orgId positionDic:ptInfoDic];
                
                // 1.返回block
                XMPPOrgPositionCoreDataStorageObject *position = [_xmppOrgStorage positionWithPtId:ptId
                                                                                             orgId:orgId
                                                                                        xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:position];
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"add_member"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="add_member">
                 {"project":"xxx", "member":[{"job_id":"104", "jid":"f73cc8848dd94c938c83eed0704351f7@192.168.1.167"}, ... ] }
                 </project>
                 </iq>
                 
                */
                
                // 0.解析获得数据
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                NSArray *userDics = [data objectForKey:@"member"];
                
                // 1.存入数据库
                [self _insertNewUserWithDics:userDics orgId:orgId];
                
                
                // 2.获取新加入的人员信息
                NSArray *newUserIds = [self _specifiedValuesWithKey:@"jid" fromDics:userDics];
                NSArray *newUsers = [_xmppOrgStorage newUsersWithOrgId:orgId userIds:newUserIds xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:newUsers];
                return YES;
                
                
            }else if([projectType isEqualToString:@"delete_member"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="delete_member">
                 {"project":"40", "jid":"hello6@123"}
                 </project>
                 </iq>
                 
                
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                NSString *orgId = [data objectForKey:@"project"];
                NSString *userJidStr = [data objectForKey:@"jid"];
                
                [_xmppOrgStorage deleteUserWithUserJidStr:userJidStr orgId:orgId xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:userJidStr];
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"search_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 模糊搜索
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="search_project">
                 [{"id":"xxx", "name":"xxx"},{"id":"xxx", "name":"xxx"},{}]
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"subscribe"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="subscribe">
                 {"id_self":"50",“id_target":"51"}
                 </project>
                 </iq>
                 
                 push to id_target admin.
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="subscribe">
                 {"id":"xxx", "name":"xxx"}
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"subscribed"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="d931cb6e4e4d46449d6a132a8bf6c31eb@192.168.1.158/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="subscribed">
                 {"id_self":"xxx",“id_target":"xxx"}
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"unsubscribed"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
              
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="unsubscribed">
                 {"id_self":"xxx", "id_target":"xxx"}
                 </project>
                 </iq>
                 
                 push message to id_target admin
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="unsubscribed">
                 {"id":"xxx", "name":"xxx"}
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"unsubscribe"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 <iq from="73b3739b1949486da7ad87698189cb65@192.168.1.158/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="unsubscribe">
                 {"id_self":"xx",“id_target":"xxx"}
                 </project>
                 </iq>
                 
                 push to every in all each project member;
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="subscribe">
                 {"id":"xxx", "name":"xxx", "link_tag":"xxx"}
                 </sys>
                 </message>

                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if([projectType isEqualToString:@"get_template_hash"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                
                id  data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
                
            }else if ([projectType isEqualToString:@"get_photo"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /*
                 正确的结果：
                 <iq from="c834580a878d43088fa382bac1530603@192.168.1.130/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="get_photo">
                 {"project":"xxx", "photo":"xxx"}
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSDictionary *orgDic = [[project stringValue] objectFromJSONString];
                NSString *orgId = orgDic[@"project"];
                
                __weak typeof(self) weakSelf = self;
                
                [_xmppOrgStorage insertOrUpdateOrgInDBWith:[orgDic destinationDictionaryWithNewKeysMapDic:@{
                                                                                                            @"orgId":@"id",
                                                                                                            @"orgName":@"name",
                                                                                                            @"orgState":@"status",
                                                                                                            @"orgStartTime":@"start_time",
                                                                                                            @"orgEndTime":@"end_time",
                                                                                                            @"orgAdminJidStr":@"admin",
                                                                                                            @"orgDescription":@"description",
                                                                                                            @"ptTag":@"job_tag",
                                                                                                            @"userTag":@"member_tag",
                                                                                                            @"orgRelationShipTag":@"link_tag"
                                                                                                            }]
                                                xmppStream:xmppStream
                                                 userBlock:^(NSString *orgId) {
                                                     
                                                     // 0.request all user info from server
                                                     
                                                     [weakSelf requestServerAllUserListWithOrgId:orgId];
                                                     
                                                 } positionBlock:^(NSString *orgId) {
                                                     
                                                     // 1.request all position info from server
                                                     
                                                     [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                                     
                                                 } relationBlock:^(NSString *orgId) {
                                                     
                                                     // 2.request all relation org info from server
                                                     
                                                     [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                                 }];
                
                
                // 2.向数据库获取数据
                id data = [_xmppOrgStorage orgPhotoWithOrgId:orgId xmppStream:xmppStream];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];

                return YES;
            }
            // add case
        }
    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // This method is invoked on the moduleQueue.
    XMPPLogTrace();
    
    NSXMLElement *sysElement = [message elementForName:@"sys" xmlns:[NSString stringWithFormat:@"%@",ORG_PUSH_MSG_XMLNS]];
    
    //This is a org push message
    if (sysElement) {
        
        __weak typeof(self) weakSelf = self;
        NSString *orgId = [sysElement attributeStringValueForName:@"projectid"];
        
        if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"finished"]){// 结束一个项目工程
            /*
            <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
            <sys xmlns="aft.sys.project" projectid="1" type="finished">
            {"end_time":"xxx"}
            </sys>
            </message>
            */
           
            id data = [[sysElement stringValue] objectFromJSONString];
            NSDate *endTime = [[data objectForKey:@"end_time"] StringToDate];
            
            [_xmppOrgStorage endOrgWithOrgId:orgId orgEndTime:endTime xmppStream:xmppStream];
            
            // TODO:执行block回掉，由于在请求回复事执行block  此处暂时不使用
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"add_job"]){// 添加自定义职位
            /*
             <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="1" type="add_job">
             {"job_tag":"xxx"}
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *positionTag = [data objectForKey:@"job_tag"];
            
            [_xmppOrgStorage comparePositionInfoWithOrgId:orgId
                                              positionTag:positionTag
                                               xmppStream:xmppStream
                                             refreshBlock:^(NSString *orgId) {
                                                 
                                                 // 0.request all position info from server
                                                 
                                                 [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                                 
                                             }];
        
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"add_member"]){// 添加成员
            /*
             <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="1" type="add_member">
             {
             "project":"xxx",
             "member_tag":"xxx",
             "member":[{"job_id":"279", "jid":"125d9af626064ba2bbdd1fe215b8926c@192.168.1.162"},...]
             }
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *userTag = [data objectForKey:@"member_tag"];
            NSArray *userInfoDics = [data objectForKey:@"member"];
            
            // 0.往数据库添加成员信息
            [self _insertNewUserWithDics:userInfoDics orgId:orgId];
            
            
            // 1.修改组织表中的成员tag,如果数据库中没有这个项目，就要下载(防止被添加人数据库没有这个组织)
            [_xmppOrgStorage updateUserTagWithOrgId:orgId
                                            userTag:userTag
                                         xmppStream:xmppStream pullOrgBlock:^(NSString *orgId) {
                                             
                                             // 2.下载这个组织的信息
                                             [weakSelf requestServerOrgWithOrgId:orgId];
                                         }];
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"delete_member"]){// 删除成员
            /*
             <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="1" type="delete_member">
             {
             "project":"xxx",
             "member_tag":"xxx",
             "member":["jid1","jid2","jid3",...,"jidn"]
             }
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *userTag = [data objectForKey:@"member_tag"];
            NSArray *userBareJidStrs = [data objectForKey:@"member"];
            
            // 0.判断被删除的人中是否有自己，有自己要删除数据库中的该项目信息，项目职位和人员信息
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", [[xmppStream myJID] bare]];
            NSArray *results = [userBareJidStrs filteredArrayUsingPredicate:predicate];
            
            if ([results count] >= 1) {// 有自己
                
                // 1.有自己删除数据库中该项目信息，项目职位和人员信息
                [_xmppOrgStorage clearOrgWithOrgId:orgId xmppStream:xmppStream];
                
            }else{// 没有自己
                
                // 2.没有自己，删除数据库中指定成员信息
                [_xmppOrgStorage deleteUserWithUserBareJidStrs:userBareJidStrs
                                              fromOrgWithOrgId:orgId
                                                    xmppStream:xmppStream];
                
                // 3.没有自己，修改组织表中的成员tag
                [_xmppOrgStorage updateUserTagWithOrgId:orgId
                                                userTag:userTag
                                             xmppStream:xmppStream
                                           pullOrgBlock:NULL];
            }
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"subscribe"]){// 收到工程关联的请求
            /*
             <message from="48@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="48" type="subscribe">
             {"id_self":"xxx", "name_self":"xxx", "id_target":"xxx", "name_target":"xxx",  }
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *fromOrgId = [data objectForKey:@"id_target"];
            NSString *formOrgName = [data objectForKey:@"name_target"];
            NSString *toOrgId = [data objectForKey:@"id_self"];
            

            [_xmppOrgStorage insertSubcribeObjectWithDic:[data destinationDictionaryWithNewKeysMapDic:@{
                                                                                                        @"formOrgId":@"id_target",
                                                                                                        @"fromOrgName":@"name_target",
                                                                                                        @"toOrgId":@"id_self",
                                                                                                        @"message":@"message"
                                                                                                          }]
                                              xmppStream:xmppStream];
            [multicastDelegate xmppOrg:self
    didReceiveSubcribeRequestFromOrgId:fromOrgId
                           fromOrgName:formOrgName
                               toOrgId:toOrgId];
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"subscribed"]){// 同意别的组织关联请求
            /*
             <message from="49@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="49" type="subscribed">
             {"id_self":"xxx", "name_self":"xxx", "link_tag_self":"xxx", "id_target":"xxx", "name_target":"xxx" }
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *formOrgId = [data objectForKey:@"id_target"];
            NSString *formOrgName = [data objectForKey:@"name_target"];
            NSString *toOrgId = [data objectForKey:@"id_self"];
            NSString *relationTag = [data objectForKey:@"link_tag_self"];
    
            
            // 0.把新的关联组织信息加入数据库
            [_xmppOrgStorage addOrgId:formOrgId orgName:formOrgName toOrgId:toOrgId xmppStream:xmppStream];
            
            // 1.修改本组织的关联tag
            [_xmppOrgStorage updateRelationShipTagWithOrgId:toOrgId relationShipTag:relationTag xmppStream:xmppStream];
            
            // 2.下载关联组织的职位信息和成员信息
            [self requestServerRelationOrgWithRelationId:formOrgId orgId:toOrgId];
            
            // FIXME:请求方会重复添加关联组织信息
            // 3.如果自己是本组织的admin，那么就修改该请求信息为已接受的
            if ([_xmppOrgStorage isAdminWithUser:[[xmppStream myJID] bare] orgId:toOrgId xmppStream:xmppStream]) {
                
                [_xmppOrgStorage updateSubcribeObjectWithDic:[data destinationDictionaryWithNewKeysMapDic:@{
                                                                                                            @"formOrgId":@"id_target",
                                                                                                            @"fromOrgName":@"name_target",
                                                                                                            @"toOrgId":@"id_self",
                                                                                                            @"message":@"message"
                                                                                                            }]
                                                      accept:YES
                                                  xmppStream:xmppStream];
                // 3.回掉通知收到 接受通知
                [multicastDelegate xmppOrg:self didReceiveAcceptSubcribeFromOrgId:formOrgId fromOrgName:formOrgName toOrgId:toOrgId];
            }
            
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"unsubscribed"]){// 拒绝别的组织的关联请求
            /*
             <sys xmlns="aft.sys.project" projectid="1" type="unsubscribed">
             {"id_self":"xxx", "name_self":"xxx", "id_target":"xxx", "name_target":"xxx"}
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *formOrgId = [data objectForKey:@"id_self"];
            NSString *formOrgName = [data objectForKey:@"name_self"];
            NSString *toOrgId = [data objectForKey:@"id_target"];
            
            // 0.回掉通知被拒绝
            [multicastDelegate xmppOrg:self didReceiveRefuseSubcribeFromOrgId:formOrgId fromOrgName:formOrgName toOrgId:toOrgId];
            
        }else if ([[sysElement attributeStringValueForName:@"type"] isEqualToString:@"unsubscribe"]){// 删除已经关联的组织
            /*
             <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
             <sys xmlns="aft.sys.project" projectid="1" type="unsubscribe">
             {"id_self":"xxx", "name_self":"xxx", "link_tag_self":"xxx", "id_target":"xxx", "name_target":"xxx"}
             </sys>
             </message>
             */
            
            id data = [[sysElement stringValue] objectFromJSONString];
            NSString *formOrgId = [data objectForKey:@"id_self"];
            NSString *toOrgId = [data objectForKey:@"id_target"];
            NSString *toOrgName = [data objectForKey:@"name_target"];
            NSString *relationTag = [data objectForKey:@"link_tag_self"];
            
            // 0.删除数据库关联组织信息
            [_xmppOrgStorage removeOrgId:toOrgId fromOrgId:formOrgId xmppStream:xmppStream];
            
            // 1.改变数据库组织表关联tag
            [_xmppOrgStorage updateRelationShipTagWithOrgId:formOrgId relationShipTag:relationTag xmppStream:xmppStream];
            
            // 2.回掉通知
            [multicastDelegate xmppOrg:self didReceiveRemoveSubcribeFromOrgId:toOrgId fromOrgName:toOrgName toOrgId:formOrgId];
        }
    }
}


@end
