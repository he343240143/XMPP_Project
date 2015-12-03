//
//  XMPPCloud.m
//  XMPP_Project
//
//  Created by jeff on 15/9/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloud.h"
#import "XMPPLogging.h"
#import "XMPP.h"

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
//static const NSString *CLOUD_PUSH_MSG_XMLNS = @"aft:library";
static const NSString *CLOUD_REQUEST_ERROR_XMLNS = @"aft:errors";
//static const NSString *CLOUD_ERROR_DOMAIN = @"com.afusion.cloud.error";
static NSString *CLOUD_REQUEST_XMLNS = @"aft:library";
static NSString *const REQUEST_ALL_CLOUD_KEY = @"request_all_cloud_key";

@interface XMPPCloud ()

@property (nonatomic, assign) BOOL hasBeenOwnPrivate;

@end

@implementation XMPPCloud
@synthesize xmppCloudStorage = _xmppCloudStorage;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithCloudStorage:nil dispatchQueue:queue];
}

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage
{
    return [self initWithCloudStorage:storage dispatchQueue:NULL];
}

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppCloudStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        //your code ...
        
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

- (id <XMPPCloudStorage>)xmppOrgStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppCloudStorage;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 一. 处理服务器返回的数据

#pragma mark - 1.处理获取文件夹内容 OK
- (void)handleCloudListFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSArray *serverDatas = [self _handleCloudListFolderDatasWithDicDatas:dicDatas projectID:projectID];
    
    [self _handleCloudListFolderDeleteDatasWithDicDatas:dicDatas serverDatas:serverDatas projectID:projectID];
    
    for (NSDictionary *dic in serverDatas) {
        [_xmppCloudStorage insertCloudDic:dic xmppStream:xmppStream];
    }
    
}

- (NSArray *)_handleCloudListFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    /**
     
     <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="B0D937C6-2990-4E07-A667-DA4FD3A3A724" type="result">
        <query xmlns="aft:library" subtype="list_folder" project="483">
            {"parent":"186", 
             "folder":[{"id":"250", "type":"1", "name":"人人人", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-11-12 15:40:15"},{"id":"232", "type":"1", "name":"哈哈还是", "creator":"7e75cb7ccf6447c0b595cb2107c90b35@120.24.94.38", "owner":"admin", "Time":"2015-11-08 17:04:08"}], 
             "file":[{"id":"7", "uuid":"0360ad270564475e98139777701302f3", "name":"2015-11-12- 185616951.jpg", "size":"53919", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:56:17"},{"id":"6", "uuid":"1fc2af2943be4bfc86717024311b920d", "name":"20151112181441536_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"142744", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:14:46"},{"id":"4", "uuid":"8c6167fa2d7f4449bdfb43a3bd0fb6a4", "name":"20151112181104306_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"175935", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:11:07"},{"id":"3", "uuid":"93059ce920794524bb06616c243a656a", "name":"20151112180905048_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"175935", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:09:11"},{"id":"2", "uuid":"38a9abb4d26c46d6ae23b93dbc16a19a", "name":"20151112174004174_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"47164", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 17:40:19"}]}
        </query>
     </iq>
     
     {"parent":"-1", 
     "folder":[{"id":"10", "type":"2", "name":"", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"},
     {"id":"9", "type":"0", "name":"资料归档", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},
     {"id":"8", "type":"0", "name":"资料库", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},
     {"id":"7", "type":"0", "name":"工作文件", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"}], 
     "file":[]}
     客户端检查一下type=2的项，有没有owner=self jid，如果没有，显示一个自己的文件夹
     
     */
    NSString *myJidStr = [[xmppStream myJID] bare];
    NSString *parent = [dicDatas objectForKey:@"parent"];
    NSArray *folders = [dicDatas objectForKey:@"folder"];
    NSArray *files = [dicDatas objectForKey:@"file"];
    NSMutableArray *arrayM = [NSMutableArray array];
    
    
    // 一.在root目录下
    if ([parent isEqualToString:@"-1"]) {
        
        
        int count = 0;
        for ( NSDictionary *dic in folders ) {
            // 1.判断是否有自己的私人文件夹
            NSString *creator = [dic objectForKey:@"creator"];
            NSString *owner = [dic objectForKey:@"owner"];
            NSString *type = [dic objectForKey:@"type"];
            NSString *name = [dic objectForKey:@"name"];
            if ( [type isEqualToString:@"2"] &&
                 [creator isEqualToString:myJidStr] &&
                 [owner isEqualToString:myJidStr] &&
                 [name isEqualToString:@""] ) {
                count++;
            }
            
            // 2.添加到新的字典 (服务器返回数据需要处理)
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
            [dicM setObject:projectID forKey:@"project"];
            [dicM setObject:parent forKey:@"parent"];
            [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
            if ( [creator isEqualToString:myJidStr] ) {
                [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderIsMe"];
            } else {
                [dicM setObject:[NSNumber numberWithBool:NO] forKey:@"folderIsMe"];
            }
            [arrayM addObject:dicM];
        }
        
        
        // 3.处理有没有自己的私人文件夹
        // 3.1没有自己的私人文件夹 (需要创建一个属于自己的字典作为自己的私人文件夹)
        if (count == 0) {
            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            [dicM setObject:projectID forKey:@"project"];
            [dicM setObject:parent forKey:@"parent"];
            [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"type"];
            [dicM setObject:@"工作" forKey:@"name"];
            [dicM setObject:@"" forKey:@"id"];
            [dicM setObject:myJidStr forKey:@"owner"];
            [dicM setObject:myJidStr forKey:@"creator"];
            [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderIsMe"];
            [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
            [arrayM addObject:dicM];
        }
    }
    
    
    // 二. 不在root目录下的请求
    else {
        
        // 1.添加folders到新的字典
        for ( NSDictionary *dic in folders ) {
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
            [dicM setObject:projectID forKey:@"project"];
            [dicM setObject:parent forKey:@"parent"];
            [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
            NSString *creator = [dic objectForKey:@"creator"];
            if ( [creator isEqualToString:myJidStr] ) {
                [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
            } else {
                [dicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
            }
            [arrayM addObject:dicM];
        }
        
        /**
         // 公共文件夹/子文件夹
         <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="4FB8B9C3-BB8A-4527-AF80-BC3FF05CEDC1" type="result"><query xmlns="aft:library" subtype="list_folder" project="460">{"parent":"9", "folder":[{"id":"27", "type":"1", "name":"尼克", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"admin", "Time":"2015-10-22 15:36:29"},{"id":"24", "type":"1", "name":"星期", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-10-21 11:19:35"},{"id":"22", "type":"1", "name":"心情", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-10-21 10:58:42"}], "file":[]}</query></iq>
         // 私人文件夹
         <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="EF25643B-BD84-483C-BAF1-8476DA63E8D6" type="result"><query xmlns="aft:library" subtype="list_folder" project="460">{"parent":"10", "folder":[{"id":"21", "type":"3", "name":"星期天", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-16 13:28:21"},{"id":"11", "type":"5", "name":"通讯录", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"}], "file":[]}</query></iq>
         
         <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="18ADBB05-A195-4770-A3E0-8585C6A41261" type="result"><query xmlns="aft:library" subtype="list_folder" project="483">{"parent":"199", "folder":[{"id":"201", "type":"3", "name":"天天天", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "Time":"2015-11-07 15:01:49"},{"id":"200", "type":"3", "name":"他哥哥", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "Time":"2015-11-07 14:48:44"}], "file":[]}</query></iq>
         
         // 有文件的情况
         <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="B0D937C6-2990-4E07-A667-DA4FD3A3A724" type="result">
            <query xmlns="aft:library" subtype="list_folder" project="483">
                {"parent":"186",
                 "folder":[{"id":"250", "type":"1", "name":"人人人", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-11-12 15:40:15"},{"id":"232", "type":"1", "name":"哈哈还是", "creator":"7e75cb7ccf6447c0b595cb2107c90b35@120.24.94.38", "owner":"admin", "Time":"2015-11-08 17:04:08"}],
                 "file":[{"id":"7", "uuid":"0360ad270564475e98139777701302f3", "name":"2015-11-12- 185616951.jpg", "size":"53919", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:56:17"},{"id":"6", "uuid":"1fc2af2943be4bfc86717024311b920d", "name":"20151112181441536_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"142744", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:14:46"},{"id":"4", "uuid":"8c6167fa2d7f4449bdfb43a3bd0fb6a4", "name":"20151112181104306_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"175935", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:11:07"},{"id":"3", "uuid":"93059ce920794524bb06616c243a656a", "name":"20151112180905048_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"175935", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 18:09:11"},{"id":"2", "uuid":"38a9abb4d26c46d6ae23b93dbc16a19a", "name":"20151112174004174_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"47164", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"186", "Time":"2015-11-12 17:40:19"}]}
            </query>
         </iq>
         */
        
        

    }
    
    // 2.添加files到新的字典
    for ( NSDictionary *dic in files ) {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:parent forKey:@"parent"];
        [dicM setObject:[NSNumber numberWithBool:NO] forKey:@"folderOrFileType"];
        NSString *creator = [dic objectForKey:@"creator"];
        if ( [creator isEqualToString:myJidStr] ) {
            [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
        } else {
            [dicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
        }
        [arrayM addObject:dicM];
    }
    
    return [NSArray arrayWithArray:arrayM];
}


/** 其他账户删除文件/文件夹 共享的操作的文件 */
- (void)_handleCloudListFolderDeleteDatasWithDicDatas:(NSDictionary *)dicDatas serverDatas:(NSArray *)serverDatas projectID:(NSString *)projectID
{
    NSArray *DBDatas = [_xmppCloudStorage cloudGetFolderWithParent:[dicDatas objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
    if (DBDatas.count) { // 比较
        for (XMPPCloudCoreDataStorageObject *DBCloud in DBDatas) {
            
            int count = 0;
            for (NSDictionary *serDic in serverDatas) {
                if ([DBCloud.cloudID isEqualToString:[serDic valueForKey:@"id"]]) {
                    count++;
                    break;
                }
            }
            
            // 实体有删除或共享类操作，更新数据库
            if (count == 0) {
                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
                [dicM setObject:DBCloud.cloudID forKey:@"id"];
                [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"hasBeenDelete"];
                [_xmppCloudStorage deleteClouDic:dicM xmppStream:xmppStream];
                
            }
            
        }
        
    }

}


#pragma mark 2.处理创建文件夹 OK
- (NSArray *)handleCloudAddFolderDatasWithArrDatas:(NSArray *)arrDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return nil;
    
    NSArray *serverDatas = [self _handleCloudAddFolderDatasWithArrDatas:arrDatas projectID:projectID];
    
    for ( NSDictionary *dic in serverDatas ) {
        [_xmppCloudStorage insertCloudDic:dic xmppStream:xmppStream];
    }
    return serverDatas;
}

- (NSArray *)_handleCloudAddFolderDatasWithArrDatas:(NSArray *)arrDatas projectID:(NSString *)projectID
{
    /**
     // 1.没有私人文件夹id
     [{"parent":"-1", "folder":[{"id":"199", "type":"2", "name":"", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "Time":"2015-11-07 14:48:44"}]}, 
     {"parent":"199", "folder":[{"id":"200", "type":"3", "name":"他哥哥", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38","owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "Time":"2015-11-07 14:48:44"}]}]
     // 2.有私人文件夹id
     [{"parent":"189", "folder":[{"id":"191", "type":"3", "name":"断喉弩","creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","Time":"2015-11-07 12:58:16"}]}]
     */
    
    NSString *myJidStr = [[xmppStream myJID] bare];
    NSMutableArray *arrayM = [NSMutableArray array];
    for ( NSDictionary *dic in arrDatas ) {
        NSString *parent = [dic objectForKey:@"parent"];
        NSArray *folders = [dic objectForKey:@"folder"];
        
        // 添加到新的字典
        NSDictionary *folderDic = [folders firstObject];
        NSString *creator = [folderDic objectForKey:@"creator"];
        
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:folderDic];
        [dicM setObject:parent forKey:@"parent"];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
        if ( [creator isEqualToString:myJidStr] ) {
            [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
        } else {
            [dicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
        }
        [arrayM addObject:dicM];
    }
    return [NSArray arrayWithArray:arrayM];
}



#pragma mark 3.添加文件 OK
- (NSArray *)handleCloudAddFileDatasWithArrData:(NSArray *)arrData projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return nil;
    
    NSArray *serverArr = [self _handleCloudAddFileDatasWithArrData:arrData projectID:projectID];
    
    for (NSDictionary *dic in serverArr) {
        [_xmppCloudStorage insertCloudDic:dic xmppStream:xmppStream];
    }
    return serverArr;
}

- (NSArray *)_handleCloudAddFileDatasWithArrData:(NSArray *)arrData projectID:(NSString *)projectID
{
    /**
     
     <iq xmlns="jabber:client" from="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38" to="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38/mobile" id="76A0E166-EB1F-42E6-9E6F-A13C1559F157" type="result">
        <query xmlns="aft:library" subtype="add_file" project="582">
            [{"parent":"-1", "folder":[{"id":"480", "type":"2", "name":"", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "Time":"2015-11-30 11:34:03"}]}, {"parent":"480", "file":[{"id":"693", "uuid":"6e27f016abf54292a5f472ec4feec808", "name":"2015-11-30 193353699.jpg", "size":"53919", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "version_count":"1", "folder":"480", "Time":"2015-11-30 11:34:03"}]}]
        </query>
     </iq>
    
     note(2, 3):如果在私人文件夹内创建文件夹或添加文件，个人文件夹还未创立，parent设为""，
     服务器会根据""，如果没有创建去创建它，创建的id号在parent属性里，客户端根据此parent去更新一下本地,
     如果有，则不用创建个人文件夹。
     */

    NSString *myJidStr = [[xmppStream myJID] bare];
    NSMutableArray *arrayM = [NSMutableArray array];
    for ( NSDictionary *dic in arrData ) {
        NSString *parent = [dic objectForKey:@"parent"];
        if ([parent isEqualToString:@"-1"]) {
            NSArray *folders = [dic objectForKey:@"folder"];
            // 添加到新的字典
            // 1.文件夹
            NSDictionary *folderDic = [folders firstObject];
            NSString *creator = [folderDic objectForKey:@"creator"];
            
            NSMutableDictionary *folderDicM = [NSMutableDictionary dictionaryWithDictionary:folderDic];
            [folderDicM setObject:parent forKey:@"parent"];
            [folderDicM setObject:projectID forKey:@"project"];
            [folderDicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
            if ( [creator isEqualToString:myJidStr] ) {
                [folderDicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
            } else {
                [folderDicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
            }
            [arrayM addObject:folderDicM];
            
        }
        
        else {
            NSArray *files = [dic objectForKey:@"file"];
            
            // 2.文件
            NSDictionary *fileDic = [files firstObject];
            NSString *creator = [fileDic objectForKey:@"creator"];
            
            NSMutableDictionary *fileDicM = [NSMutableDictionary dictionaryWithDictionary:fileDic];
            [fileDicM setObject:parent forKey:@"parent"];
            [fileDicM setObject:projectID forKey:@"project"];
            [fileDicM setObject:[NSNumber numberWithBool:NO] forKey:@"folderOrFileType"];
            if ( [creator isEqualToString:myJidStr] ) {
                [fileDicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
            } else {
                [fileDicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
            }
            [arrayM addObject:fileDicM];
        }
    }
    return [NSArray arrayWithArray:arrayM];
}

- (NSString *)handleCloudAddFileCloudIDWithArr:(NSArray *)arr
{
    for ( NSDictionary *dic in arr ) {
        NSString *parent = [dic objectForKey:@"parent"];
        if ([parent isEqualToString:@"-1"]) {
            NSArray *folders = [dic objectForKey:@"folder"];
            NSDictionary *folderDic = [folders firstObject];
            NSString *cloudID = [folderDic valueForKey:@"id"];
            return cloudID;
        }
    }
    return nil;
}


#pragma mark 4.删除文件夹/删除文件 OK
- (void)handleCloudDeleteFolderDatasWithDicData:(NSDictionary *)dicData projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSDictionary *serverDic = [self _handleCloudDeleteFolderDatasWithDicData:dicData projectID:projectID];
    
    [_xmppCloudStorage updateSpecialCloudDic:serverDic xmppStream:xmppStream];
}

- (NSDictionary *)_handleCloudDeleteFolderDatasWithDicData:(NSDictionary *)dicData projectID:(NSString *)projectID
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dicData];
    [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"hasBeenDelete"];
    return [NSDictionary dictionaryWithDictionary:dicM];
}

#pragma mark 5.重命名 OK
- (void)handleCloudRenameDatasWithDicData:(NSDictionary *)dicData projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [_xmppCloudStorage updateSpecialCloudDic:dicData xmppStream:xmppStream];
}


#pragma mark 6.共享 OK
- (void)handleCloudShareDatasWithDicData:(NSDictionary *)dicData projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSDictionary *serverDic = [self _handleCloudShareDatasWithDicData:dicData];
    
    [_xmppCloudStorage updateSpecialCloudDic:serverDic xmppStream:xmppStream];
}

- (NSDictionary *)_handleCloudShareDatasWithDicData:(NSDictionary *)dicData
{
    /**
     
     1.(私密共享),右下角有锁  共享开关关闭着 没有成员列表 type = 5
        eg:{"id":"73"}
     2.(部分共享),右上角有红箭头  共享开关关闭着 有成员列表 type = 4
        eg:{"id":"74","users":["33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38","4c76a063541d48da9b46a7bce4f1eca8@120.24.94.38"]}
     3.(完全共享),没标记  共享开关开着 没有成员列表 type = 3
        eg:{"id":"75","users":[]}
     */
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    NSArray *keys = [dicData allKeys];
    NSString *cloudID;
    NSString *type;
    
    for ( NSString *key in keys ) {
        if ([key isEqualToString:@"id"]) {
            cloudID = [dicData objectForKey:@"id"];
            continue;
        } else if ([key isEqualToString:@"users"]) {
            NSArray *users = [dicData objectForKey:@"users"];
            if (users.count) {
                type = @"4";
            } else if (users.count == 0) {
                type = @"3";
            }
        }
    }
    if (!type) {
        type = @"5";
    }
    
    [dicM setObject:cloudID forKey:@"id"];
    [dicM setObject:type forKey:@"type"];
    return [NSDictionary dictionaryWithDictionary:dicM];
}


#pragma mark 7.移动 OK
- (void)handleCloudMoveDatasWithDicData:(NSDictionary *)dicData projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [_xmppCloudStorage updateSpecialCloudDic:dicData xmppStream:xmppStream];
}



#pragma mark 9.获取共享人员列表 无需存储 OK


#pragma mark 15 恢复
- (void)handleCloudRecoverFileDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSDictionary *dicData = [self _handleCloudRecoverFileDatasWithDicDatas:dicDatas projectID:projectID];
    
    [_xmppCloudStorage updateSpecialCloudDic:dicData xmppStream:xmppStream];
}

- (NSDictionary *)_handleCloudRecoverFileDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dicDatas];
    [dicM setObject:[NSNumber numberWithBool:NO] forKey:@"hasBeenDelete"];
    return [NSDictionary dictionaryWithDictionary:dicM];
}


#pragma mark - 二. 网盘网络接口

#pragma mark - 1.获取文件夹内容 OK
/**
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="list_folder">
 {"folder":""}   %% folder_id = -1: list_root,  %% list root  folder value is empty.
 </query>
 </iq>
 
 结果：
 note: 客户端根据owner中的jid从本地数据库中，获取此人的职位并显示, 如果是admin不做此操作。
 
 list_root result:
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="list_folder">
 {"parent":"xxx", "folders":[], "files":[]}
 %%[{"folder":"1", "id":"1",  "type":"0" "name":"资料库",      "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"2",  "type":"0" "name":"资料归档",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"3",  "type":"0" "name":"工作文件",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"4",  "type":"2" "name":"张三",          "creator":"jid",      "owner":"admin",  "time":"2015-09-01"}
 </query>
 </iq>
 
 note: 客户端检查一下type=2的项，有没有owner=self jid，如果没有，显示一个自己的文件夹。
 
 list other folder result:
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="list_folder">
 {"parent":"xxx", "folders":[], "files":[]}
 %%[{"folder":"1", "id":"4", "parent":"xx", "type":"1" "name":"效果图", "creator":"jid", "owner":"admin", "time":"2015-09-01"},
 %% {"folder":"0", "id":"5", "parent":"xx", "uuid":"xxx", "name":"通迅录.xls", "version":"3", "creator":"jid", "time":"2015-09-01"}]
 </query>
 </iq>
 
 */

- (void)requestCloudListFolderWithParent:(NSString *)parent projectID:(NSString *)projectID block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {
            
            // we should make sure whether we can send a request to the server
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="list_folder">
             {"folder":""}   %% folder_id = -1: list_root,  %% list root  folder value is empty.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:parent, @"folder", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"list_folder", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        } else {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


#pragma mark 2.创建文件夹 OK
/*
 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
 <project xmlns="aft:project" type="project_name_exist">
 {"name":"星河丹堤"}
 </project>
 </iq>
 
 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
 <project xmlns="aft:project" type="project_name_exist">
 {"name":"桂芳园"}
 </project>
 </iq>
 
 */

/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="add_folder">
 {"parent":"", "name":"xxx"}  %% parent value empty mean self folder not exist.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="add_folder">
 {"parent":"xxx", "folders":[]}
 </query>
 </iq>
 
 */

- (void)requestCloudAddFolderWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="add_folder">
             {"parent":"", "name":"xxx"}  %% parent value empty mean self folder not exist.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSString *tempParent = parent;
            if ([tempParent isEqualToString:@""]) {
                // DB取root下的文件夹信息 找到服务器返回的私人文件夹id
                NSArray *folders = [_xmppCloudStorage cloudGetFolderWithParent:@"-1" projectID:projectID xmppStream:xmppStream];
                NSString *myJidStr = [[xmppStream myJID] bare];
                for (XMPPCloudCoreDataStorageObject *rootCloud in folders) {
                    if ([rootCloud.owner isEqualToString:myJidStr] && [rootCloud.creator isEqualToString:myJidStr] && [rootCloud.cloudID isEqualToString:@""]) {
                        tempParent = rootCloud.cloudID;
                    }
                }
            }
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", tempParent, @"parent", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"add_folder", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        } else {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }

    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}



#pragma mark 3.添加文件 OK
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="add_file">
 {"parent":"", "name":"xxx", "uuid":"xxx", "size":"xxx"}  %% parent value empty mean self folder not exist.  jid same with mms's store jid.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="add_file">
 {"parent":"xxx", "files":[]}
 </query>
 </iq>
 
 note(2, 3):如果在私人文件夹内创建文件夹或添加文件，个人文件夹还未创立，parent设为""，
 服务器会根据""，如果没有创建去创建它，创建的id号在parent属性里，客户端根据此parent去更新一下本地,
 如果有，则不用创建个人文件夹。
 
 */
- (void)requestCloudAddFileWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name size:(NSString *)size uuid:(NSString *)uuid block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {
            
            // we should make sure whether we can send a request to the server
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="add_file">
             {"parent":"", "name":"xxx", "uuid":"xxx", "size":"xxx"}  %% parent value empty mean self folder not exist.  jid same with mms's store jid.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSString *tempParent;
            if ([tempParent isEqualToString:@"2"]) {
                // DB取root下的文件夹信息 找到服务器返回的私人文件夹id
                NSArray *folders = [_xmppCloudStorage cloudGetFolderWithParent:@"-1" projectID:projectID xmppStream:xmppStream];
                NSString *myJidStr = [[xmppStream myJID] bare];
                for (XMPPCloudCoreDataStorageObject *rootCloud in folders) {
                    if ([rootCloud.owner isEqualToString:myJidStr] && [rootCloud.creator isEqualToString:myJidStr]) {
                        tempParent = rootCloud.cloudID;
                    }
                }
            }
            else {
                tempParent = parent;
            }
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:tempParent, @"parent", name, @"name", uuid, @"uuid", size, @"size", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"add_file", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        } else {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}



#pragma mark 4.删除文件夹/删除文件 OK
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="delete_folder"/"delete_file">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="delete_folder"/"delete_file">
 {"id":"xxx"}
 </query>
 </iq>
 
 note：如果把私人文件夹内的东西都删掉了，服务器会删掉私人文件夹，客户端需要更新私人文件夹id为"".
 
 */
- (void)requestCloudDeleteWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="delete_folder"/"delete_file">
             {"id":"xxx"}
             </query>
             </iq>
             */
            NSString *subtype = folderOrFileType.integerValue ? @"delete_folder" : @"delete_file";
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 5.重命名 OK
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
 {"id":"xxx", "name":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
 {"id":"xxx", "name":"xxx"}
 </query>
 </iq>
 
 */
- (void)requestCloudRenameWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID name:(NSString *)name folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
             {"id":"xxx", "name":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", cloudID, @"id", nil];
            
            NSString *subtype = folderOrFileType.integerValue ? @"rename_folder" : @"rename_file";
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 6.共享 OK
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="share">
 {"id":"xxx", "users":["jid1", "jid2", "jid3", ...]} %% 如果没有users项，变成私密的。 如果users为[], 变成全共享的。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="share">
 {"id":"xxx", "users":["jid1", "jid2", "jid3", ..]}
 </query>
 </iq>
 
 */
- (void)requestCloudShareWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users hasShared:(BOOL)hasShared block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="share">
             {"id":"xxx", "users":["jid1", "jid2", "jid3", ...]} %% 如果没有users项，变成私密的。 如果users为[], 变成全共享的。
             </query>
             </iq>
             
             <iq id="request_all_cloud_key" type="set"><query xmlns="aft:library" subtype="share" project="460"/></iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic;
            if (hasShared) {
                NSArray *temp =  [NSArray array];
                templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", temp, @"users", nil];
            } else {
                if (users.count) {
                    templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", users, @"users", nil];
                } else {
                    templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", nil];
                }
            }
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"share", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 7.移动 OK
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="move_folder"/"move_file">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="move_file"/"move_folder">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 */
- (void)requestCloudMoveWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID destinationParent:(NSString *)destinationParent folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="move_folder"/"move_file">
             {"id":"xxx", "dest_parent":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:destinationParent, @"dest_parent", cloudID, @"id", nil];
            
            NSString *subtype = folderOrFileType.integerValue ? @"move_folder" : @"move_file";
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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

#pragma mark 9.获取共享人员列表 OK
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_share_users">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx"  subtype="list_share_users">
 ["jid1", "jid2", ...]
 </query>
 </iq>
 
 */
- (void)requestCloudSharedListWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="list_share_users">
             {"id":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"list_share_users", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 12.获取日志
/**
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="get_log">
 {"before"/"after":"1", "count:"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="get_log">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
 {"count":"xxx", "logs":[{"id":"xxx", "jid":"xxx", "operation":"xxx", "text":"xxx", "time":"xxx", "project":"xxx"}, ...] } %% logs 需要客户端自己根据id去升序排序。
 </query>
 </iq>
 */
- (void)requestCloudGetLogWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before after:(NSString *)after block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
                <query xmlns="aft:library" project="xxx" subtype="get_log">
                    {"before"/"after":"1", "count:"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
                </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSString *key;
            NSString *attribute;
            if (after.length <= 0) {
                attribute = before;
                key = @"before";
            } else if (before.length <= 0) {
                attribute = after;
                key = @"after";
            }
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", attribute, key, nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"get_log", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 13.获取我的回收站
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="get_trash">
 {"before"/"after":1, "count":"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="get_trash">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
 {"count":"xxx", "files":[] } %% logs 需要客户端自己根据id去升序排序。
 </query>
 </iq>
 
 注意：如果file的location里有"@"请替换为自己的姓名。
 
 */
- (void)requestCloudGetTrashWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before after:(NSString *)after block:(CompletionBlock)completionBlock;
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="get_trash">
             {"before"/"after":1, "count":"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSString *key;
            NSString *attribute;
            if (after.length <= 0) {
                attribute = before;
                key = @"before";
            } else if (before.length <= 0) {
                attribute = after;
                key = @"after";
            }
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", before, @"before", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"get_trash", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark 14.清空回收站
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="clear_trash">
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="clear_trash">
 </query>
 </iq>
 
 */
- (void)requestCloudClearTrashWithProjectID:(NSString *)projectID block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="clear_trash">
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"clear_trash", @"project":projectID}
                                                                stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
            
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



#pragma mark - 15.恢复
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="49" subtype="recover_file">
 {"id":"9", "name":"全体通过录2", "dest_parent":"2"}  % name may be a new name as dest folder has duplication name.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="recover_file">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 */
- (void)requestCloudRecoverFileWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID name:(NSString *)name destParent:(NSString *)destParent block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="49" subtype="recover_file">
             {"id":"9", "name":"全体通过录2", "dest_parent":"2"}  % name may be a new name as dest folder has duplication name.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", name, @"name", destParent, @"dest_parent", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"recover_file", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
            
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
#pragma mark - 三. XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
}

- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    return [self _executeRequestBlockWithElementName:@"project" xmlns:CLOUD_REQUEST_XMLNS sendIQ:iq];
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
    if ( [[iq type] isEqualToString:@"result"] || [[iq type] isEqualToString:@"error"] ) {
        NSXMLElement *project = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_XMLNS]];
        
        if (project) {
            NSString *requestkey = [iq elementID];
            NSString *projectType = [project attributeStringValueForName:@"subtype"];
            NSString *projectID = [project attributeStringValueForName:@"project"];
            
            
#pragma mark - 1.list_folder -- ok
            if ([projectType isEqualToString:@"list_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
    list_root result:
                 {"parent":"-1", "folder":
                    [{"id":"10", "type":"2", "name":"", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"},
                     {"id":"9", "type":"0", "name":"资料归档", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},	
                     {"id":"8", "type":"0", "name":"资料库","creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},
                     {"id":"7", "type":"0", "name":"工作文件", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"}], "file":[]}
                 
    list other folder result:
                 {"parent":"10", "folder":
                    [{"id":"21", "type":"3", "name":"星期天", 		"creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"Time":"2015-10-16 13:28:21"},
                    {"id":"11", "type":"5", "name":"通讯录", 		"creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"Time":"2015-10-15 17:57:03"}], "file":[]}
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudListFolderDatasWithDicDatas:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudGetFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 2.add_folder -- ok
            else if ([projectType isEqualToString:@"add_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38" to="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38/mobile" id="1A803CCE-122A-4916-BBDA-2B3E7626F77E" type="result">
                    <query xmlns="aft:library" subtype="add_folder" project="469">
                        [{"parent":"83", "folder":[{"id":"89", "type":"3", "name":"体育馆","creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38","Time":"2015-11-05 18:29:19"}]}]
                    </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSArray *arrData = (NSArray *)data;
                NSArray *serverDatas = [self handleCloudAddFolderDatasWithArrDatas:arrData projectID:projectID];

                NSString *ownerCloudID;
                NSString *addCloudID;
                for (NSDictionary *serverDic in serverDatas) {
                    if ([[serverDic valueForKey:@"parent"] isEqualToString:@"-1"]) {
                        ownerCloudID = [serverDic valueForKey:@"id"];
                    } else {
                        addCloudID = [serverDic valueForKey:@"id"];
                    }
                }
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *ownerFolder = [_xmppCloudStorage cloudAddFolderWithProjectID:projectID cloudID:ownerCloudID xmppStream:xmppStream];
                    NSArray *addFolder = [_xmppCloudStorage cloudAddFolderWithProjectID:projectID cloudID:addCloudID xmppStream:xmppStream];
                    NSMutableArray *results = [NSMutableArray array];
                    [results addObjectsFromArray:ownerFolder];
                    [results addObjectsFromArray:addFolder];
                    
                    
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:[NSArray arrayWithArray:results]];
                }
                return YES;
            }
            
#pragma mark - 3.add_file -- ok
            else if ([projectType isEqualToString:@"add_file"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq id="9D916ED7-E25C-4FF4-A3C3-88FAA12DEF78" type="set">
                    <query xmlns="aft:library" subtype="add_file" project="483">
                    {"name":"20151112164508909_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg","uuid":"5b8576e5aeb74f9fb67f7b9dd5769459","size":"36335","parent":"187"}
                    </query>
                 </iq>
                 
                 
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="9D916ED7-E25C-4FF4-A3C3-88FAA12DEF78" type="result">
                    <query xmlns="aft:library" subtype="add_file" project="483">
                        [{"parent":"187", "file":[{"id":"1", "uuid":"5b8576e5aeb74f9fb67f7b9dd5769459", "name":"20151112164508909_1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38.jpg", "size":"36335", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "version_count":"1", "folder":"187", "Time":"2015-11-12 16:46:15"}]}]
                    </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSArray *arrData = (NSArray *)data;
                NSArray *serverDatas = [self handleCloudAddFileDatasWithArrData:arrData projectID:projectID];
                NSString *ownerCloudID;
                NSString *addCloudID;
                for (NSDictionary *serverDic in serverDatas) {
                    if ([[serverDic valueForKey:@"parent"] isEqualToString:@"-1"]) {
                        ownerCloudID = [serverDic valueForKey:@"id"];
                    } else {
                        addCloudID = [serverDic valueForKey:@"id"];
                    }
                }

                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *ownerFolder = [_xmppCloudStorage cloudAddFolderWithProjectID:projectID cloudID:ownerCloudID xmppStream:xmppStream];
                    NSArray *addFolder = [_xmppCloudStorage cloudAddFolderWithProjectID:projectID cloudID:addCloudID xmppStream:xmppStream];
                    NSMutableArray *results = [NSMutableArray array];
                    [results addObjectsFromArray:ownerFolder];
                    [results addObjectsFromArray:addFolder];
                    
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:results];
                }
                return YES;
            }
            
#pragma mark - 4.delete_folder and delete_file -- ok
            else if ([projectType isEqualToString:@"delete_folder"] || [projectType isEqualToString:@"delete_file"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="86E1C98A-04DD-40F4-8E7E-E7E7C6A4DBFF" type="result">
                 <query xmlns="aft:library" subtype="delete_folder" project="460">
                 {"id":"18"}
                 </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                // 数据库删除
                [self handleCloudDeleteFolderDatasWithDicData:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudIDInfoWithProjectID:projectID cloudID:[dicData objectForKey:@"id"] xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 5.rename_folder and rename_file -- ok
            if ([projectType isEqualToString:@"rename_folder"] || [projectType isEqualToString:@"rename_file"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudRenameDatasWithDicData:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudIDInfoWithProjectID:projectID cloudID:[dicData objectForKey:@"id"] xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 6.share -- ok
            else if ([projectType isEqualToString:@"share"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result"><query xmlns="aft:library" subtype="share" project="460">{"id":"28","users":[]}</query></iq>
                 <Oct 24 2015 14:26:35>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudShareDatasWithDicData:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.用block返回数据 (无需储存)
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:dicData];
                }
                return YES;
            }
            
#pragma mark - 7.1.move_folder -- ok
            else if ([projectType isEqualToString:@"move_folder"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq id="2A0B77A2-E6A6-41E8-9B16-E671EB8D56FE" type="set"><query xmlns="aft:library" subtype="move_folder" project="483">{"id":"277","dest_parent":"188"}</query></iq>
                 
                 
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudMoveDatasWithDicData:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudIDInfoWithProjectID:projectID cloudID:[dicData objectForKey:@"id"] xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 7.2.move_file -- ok
            else if ([projectType isEqualToString:@"move_file"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudMoveDatasWithDicData:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudIDInfoWithProjectID:projectID cloudID:[dicData objectForKey:@"id"] xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 9.list_share_users -- ok
            else if ([projectType isEqualToString:@"list_share_users"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 88f7c8781ae748959eb3d3d8de592e7b
                 1758b0fbfecb47398d4d2710269aa9e5
                 
                 1758b0fbfecb47398d4d2710269aa9e5
                 1758b0fbfecb47398d4d2710269aa9e5
                 88f7c8781ae748959eb3d3d8de592e7b
                 
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result">
                    <query xmlns="aft:library" subtype="list_share_users" project="460">
                    ["1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","88f7c8781ae748959eb3d3d8de592e7b@120.24.94.38"]
                    </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSArray *arrData = (NSArray *)data;
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.用block返回数据 (无需存储)
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:arrData];
                }
                return YES;
            }
            
#pragma mark - 12.get_log
            else if ([projectType isEqualToString:@"get_log"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq type="result" id="1234" >
                    <query xmlns="aft:library"  project="xxx" subtype="get_log">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
                        {"count":"xxx", "logs":[{"id":"xxx", "jid":"xxx", "operation":"xxx", "text":"xxx", "time":"xxx", "project":"xxx"}, ...] } %% logs 需要客户端自己根据id去升序排序。
                    </query>
                 </iq>
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:dicData];
                }
                return YES;
            }
            
#pragma mark - 13.get_trash
            else if ([projectType isEqualToString:@"get_trash"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq type="result" id="1234" >
                 <query xmlns="aft:library"  project="xxx" subtype="get_trash">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
                 {"count":"xxx", "file":[] } %% logs 需要客户端自己根据id去升序排序。
                 </query>
                 </iq>
                 
                 注意：如果file的location里有"@"请替换为自己的姓名。
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;

                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:dicData];
                }
                return YES;
            }
            
#pragma mark - 14.clear_trash
            else if ([projectType isEqualToString:@"clear_trash"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq type="result" id="1234" >
                 <query xmlns="aft:library" project="xxx" subtype="clear_trash">
                 </query>
                 </iq>
                 */
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"clearTrash", nil];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:result];
                }
                return YES;
            }
            
#pragma mark - 14.recover_file
            else if ([projectType isEqualToString:@"recover_file"]) {
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq type="result" id="1234" >
                 <query xmlns="aft:library" project="xxx" subtype="recover_file">
                 {"id":"xxx", "dest_parent":"xxx"}
                 </query>
                 </iq>
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudRecoverFileDatasWithDicDatas:dicData projectID:projectID];

                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:dicData];
                }
                return YES;
            }
            
            
        }
        
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
}

@end

