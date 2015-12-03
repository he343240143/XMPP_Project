//
//  XMPPCloud.h
//  XMPP_Project
//
//  Created by jeff on 15/9/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

typedef void(^CompletionBlock)(id data, NSError *error);

@protocol XMPPCloudStorage;

@interface XMPPCloud : XMPPModule
{
    __strong id <XMPPCloudStorage> _xmppCloudStorage;
}

@property (strong, readonly) id <XMPPCloudStorage> xmppCloudStorage;

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage;
- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

#pragma mark - 1.获取文件夹内容
- (void)requestCloudListFolderWithParent:(NSString *)parent projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;

#pragma mark - 2.创建文件夹
- (void)requestCloudAddFolderWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name block:(CompletionBlock)completionBlock;

#pragma mark - 3.添加文件
- (void)requestCloudAddFileWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name size:(NSString *)size uuid:(NSString *)uuid block:(CompletionBlock)completionBlock;

#pragma mark - 4.删除文件夹/删除文件
- (void)requestCloudDeleteWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;

#pragma mark - 5.重命名
- (void)requestCloudRenameWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID name:(NSString *)name folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;

#pragma mark - 6.共享
- (void)requestCloudShareWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users hasShared:(BOOL)hasShared block:(CompletionBlock)completionBlock;

#pragma mark - 7.移动
- (void)requestCloudMoveWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID destinationParent:(NSString *)destinationParent folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;

#pragma mark - 8.上传版本 问题
//- (void)requestCloudUploadVersionWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users block:(CompletionBlock)completionBlock;

#pragma mark - 9.获取共享人员列表
- (void)requestCloudSharedListWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;

#pragma mark - 10.获取文件版本 问题
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 %% id是file version id, file是文件id. 如果id为-1则是最近的版本。
 {"id":"xxx", "file":[{"id":"-1", "file","xxx", "uuid":"xxx", "size":"xxx", "creator":"xxx", "time":"xxx"}, ...]}
 </query>
 </iq>
 
 */



#pragma mark - 11.网盘文件下载:TOFIX 问题
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx"  subtype="download">
 {"id":"xxx",  "uuid":"xxx"} %% id: file id
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 {"id":"xxx", "uuid":"xxx", "url":"xxx"}
 </query>
 </iq>
 
 */



#pragma mark - 12.获取日志
- (void)requestCloudGetLogWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before after:(NSString *)after block:(CompletionBlock)completionBlock;

#pragma mark - 13.获取我的回收站
- (void)requestCloudGetTrashWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before after:(NSString *)after block:(CompletionBlock)completionBlock;

#pragma mark - 14.清空回收站
- (void)requestCloudClearTrashWithProjectID:(NSString *)projectID block:(CompletionBlock)completionBlock;

#pragma mark - 15.恢复
- (void)requestCloudRecoverFileWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID name:(NSString *)name destParent:(NSString *)destParent block:(CompletionBlock)completionBlock;


@end


@protocol XMPPCloudStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPCloud *)aParent queue:(dispatch_queue_t)queue;

@optional
#pragma mark - handle datas to database
- (void)insertCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;
- (void)deleteClouDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;
- (void)updateSpecialCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;

#pragma mark - getDatas
#pragma mark 1.获取文件夹内容
- (id)cloudGetFolderWithParent:(NSString *)parent projectID:(NSString *)projectID xmppStream:(XMPPStream *)stream;

#pragma mark 2.创建文件夹
- (id)cloudAddFolderWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream;

#pragma mark - 3.cloudID查找数据 (删除,重命名)
- (id)cloudIDInfoWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream;

@end
