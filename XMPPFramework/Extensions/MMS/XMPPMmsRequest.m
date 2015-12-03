//
//  XMPPMmsRequest.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/4/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPMmsRequest.h"
#import "XMPPStream.h"

static const double REQUEST_TIMEOUT_DELAY = 30.0f;
static const NSString *MMS_REQUEST_XMLNS = @"aft:mms";
static const NSString *MMS_ERROR_DOMAIN = @"com.afusion.mms.error";
static const NSInteger MMS_ERROR_CODE = 9999;
//static const NSString *MMS_DOWNLOAD_TOKEN_KEY = @"download_key_string";

typedef void(^DownloadBlock)(NSString *string, NSError *error);
typedef void(^UploadBlock)(NSString *token, NSString *file, NSString *expiration, NSError *error);

@interface XMPPMmsRequest ()

@property (strong, nonatomic) NSMutableDictionary *uploadCompletionBlockDcitionary;
@property (strong, nonatomic) NSMutableDictionary *downloadCompletionBlockDcitionary;
@property (assign, nonatomic) BOOL canSendRequest;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation XMPPMmsRequest
@synthesize uploadCompletionBlockDcitionary;
@synthesize downloadCompletionBlockDcitionary;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    if ((self = [super initWithDispatchQueue:queue]))
    {
        uploadCompletionBlockDcitionary = [NSMutableDictionary dictionary];
        downloadCompletionBlockDcitionary = [NSMutableDictionary dictionary];
        canSendRequest = NO;
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    if ([super activate:aXmppStream])
    {
        // Reserved for possible future use.
        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    // Reserved for possible future use.
    dispatch_block_t block = ^{
        
        canSendRequest = NO;
        
        [uploadCompletionBlockDcitionary removeAllObjects];
        [downloadCompletionBlockDcitionary removeAllObjects];
        uploadCompletionBlockDcitionary = nil;
        downloadCompletionBlockDcitionary = nil;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    [super deactivate];
}

- (void)dealloc
{
    dispatch_block_t block = ^{
        
        [uploadCompletionBlockDcitionary removeAllObjects];
        [downloadCompletionBlockDcitionary removeAllObjects];
        uploadCompletionBlockDcitionary = nil;
        downloadCompletionBlockDcitionary = nil;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration and Flags
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)canSendRequest
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = canSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setCanSendRequest:(BOOL)CanSendRequest
{
    dispatch_block_t block = ^{
        
        canSendRequest = CanSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)requestPublicUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock
{
    [self requestUploadInfoWithType:XMPPMmsRequestUploadTypePublic completionBlock:completionBlock];
}

// upload new file
- (void)requestUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock
{
    [self requestUploadInfoWithType:XMPPMmsRequestUploadTypePrivateMessage completionBlock:completionBlock];
}

- (void)requestUploadInfoWithType:(XMPPMmsRequestUploadType)type
                  completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {
            
            NSString *requestKey = [[self xmppStream] generateUUID];
            [uploadCompletionBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            /*
             <iq type="get" id="2115763">
             <query xmlns="aft:mms" query_type="upload" type="1"></query>
             </iq>
             */
            
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
            [queryElement addAttributeWithName:@"query_type" stringValue:@"upload"];
            [queryElement addAttributeWithName:@"type" unsignedIntegerValue:type];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:requestKey child:queryElement];
            
            [[self xmppStream] sendElement:iq];
            
            [self _removeCompletionBlockWithDictionary:uploadCompletionBlockDcitionary requestKey:requestKey];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

// upload exists file
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                        completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock
{
    dispatch_block_t block = ^{
        
        NSString *key = [[self xmppStream] generateUUID];
        
        [self requestExistsUploadInfoWithFile:file requestKey:key completionBlock:completionBlock];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                             requestKey:(NSString *)requestKey
                              completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock
{
    if (!requestKey) return;
    
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {
            
            if (!file) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"The upload file id can not been nil" forKey:NSLocalizedDescriptionKey];
                NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
                
                dispatch_main_async_safe(^{
                    completionBlock(nil,nil,nil,_error);
                });
                
                return;
            }
            
            [uploadCompletionBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            /*
             <iq type="get" id="2115763">
                <query xmlns="aft:mms" query_type="upload">
                    <file>1c7ca8f4-8e79-4e0a-8672-64b831da9a36</file>
                </query>
             </iq>
             */
            
            // query element
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
            [queryElement addAttributeWithName:@"query_type" stringValue:@"upload"];
            
            // file element
             NSXMLElement *fileElement = [NSXMLElement elementWithName:@"file" stringValue:file];
            [queryElement addChild:fileElement];
            
            // iq element
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:requestKey child:queryElement];
            
            [[self xmppStream] sendElement:iq];
            
            [self _removeCompletionBlockWithDictionary:uploadCompletionBlockDcitionary requestKey:requestKey];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

// download method
- (void)requestDownloadURLWithFile:(NSString *)file completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock
{
    dispatch_block_t block = ^{
        
        NSString *key = [[self xmppStream] generateUUID];
        
        [self requestDownloadURLWithFile:file requestKey:key completionBlock:completionBlock];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)requestDownloadURLWithFile:(NSString *)file requestKey:(NSString *)requestKey completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock
{
    if (!requestKey) return;
    
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {
            
            if (!file) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"The download file id can not been nil" forKey:NSLocalizedDescriptionKey];
                NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
                
                dispatch_main_async_safe(^{
                    completionBlock(nil,_error);
                });
                
                return;
            }
            
            NSDictionary *blockDic = [NSDictionary dictionaryWithObject:completionBlock forKey:file];
            [downloadCompletionBlockDcitionary setObject:blockDic forKey:requestKey];
            
            /*
             <iq type="get" id="2115763">
                <query xmlns="aft:mms" query_type="download">
                    <file>1c7ca8f4-8e79-4e0a-8672-64b831da9a36</file>
                </query>
             </iq>
             */

            // query element
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
            [queryElement addAttributeWithName:@"query_type" stringValue:@"download"];
            
            // file element
            NSXMLElement *fileElement = [NSXMLElement elementWithName:@"file" stringValue:file];
            [queryElement addChild:fileElement];
            
            // iq element
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:requestKey child:queryElement];
            
            [[self xmppStream] sendElement:iq];
            
            [self _removeCompletionBlockWithDictionary:downloadCompletionBlockDcitionary requestKey:requestKey];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_removeCompletionBlockWithDictionary:(NSMutableDictionary *)dic requestKey:(NSString *)requestKey
{
    NSTimeInterval delayInSeconds = REQUEST_TIMEOUT_DELAY;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, moduleQueue, ^(void){@autoreleasepool{
    
        if ([dic objectForKey:requestKey]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"request from server with no response for a long time!" forKey:NSLocalizedDescriptionKey];
            NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
            
            if ([dic isEqual:uploadCompletionBlockDcitionary]) {
                
                UploadBlock uploadBlock = (UploadBlock)[dic objectForKey:requestKey];
                
                if (uploadBlock) {
                    dispatch_main_async_safe(^{
                        uploadBlock(nil, nil, nil, _error);
                    });
                }
                
                
            }else if ([dic isEqual:downloadCompletionBlockDcitionary]){
                
                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:requestKey];
                NSString *file = [[blockDic allKeys] firstObject];
                
                DownloadBlock downloadBlock = (DownloadBlock)[blockDic objectForKey:file];
                
                if (downloadBlock) {
                    
                    dispatch_main_async_safe(^{
                        downloadBlock(nil, _error);
                    });
                }
                
            }
            
            [dic removeObjectForKey:requestKey];
        }
    
    }});
}

- (void)requestUploadErrorWithCode:(NSInteger)errorCode description:(NSString *)description key:(NSString *)key
{
    [self _errorWithCode:errorCode description:description isUploadRequest:YES key:key];
}

- (void)requestDownloadErrorWithCode:(NSInteger)errorCode description:(NSString *)description key:(NSString *)key
{
    [self _errorWithCode:errorCode description:description isUploadRequest:NO key:key];
}

- (void)_errorWithCode:(NSInteger)errorCode description:(NSString *)description isUploadRequest:(BOOL)isUploadRequest key:(NSString *)key
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    
    NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:errorCode userInfo:userInfo];
    
    if (isUploadRequest) {
        
        UploadBlock uploadBlock = (UploadBlock)[uploadCompletionBlockDcitionary objectForKey:key];
        
        if (uploadBlock) {
            
            dispatch_main_async_safe(^{
                uploadBlock(nil,nil,nil, _error);
            });
            [uploadCompletionBlockDcitionary removeObjectForKey:key];
        }
        
    }else{
        NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:key];
        NSString *file = [[blockDic allKeys] firstObject];
        
        DownloadBlock downloadBlock = (DownloadBlock)[blockDic objectForKey:file];
        
        if (downloadBlock) {
            
            dispatch_main_async_safe(^{
                downloadBlock(nil, _error);
            });

            [downloadCompletionBlockDcitionary removeObjectForKey:key];
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
}
- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    if ([[iq type] isEqualToString:@"get"]) {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
        
        if (query)
        {
            NSString *key = [iq elementID];
            
            if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
            {
                [self requestUploadErrorWithCode:MMS_ERROR_CODE description:@"send iq error" key:key];
            }
            else if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
            {
                [self requestDownloadErrorWithCode:MMS_ERROR_CODE description:@"send iq error" key:key];
            }
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    if ([[iq type] isEqualToString:@"result"]) {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
        
        if (query)
        {
            NSString *key = [iq elementID];
            
            if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
            {
                /*
                 <iq from='alice@localhost' to='alice@localhost' id='2115763' type='result'>
                    <query xmlns='aft:mms' query_type='upload'>
                        <token>3e4963702884b4ddf72a696c81ee49b</token>
                        <file>1c7ca8f4-8e79-4e0a-8672-64b831da9a36</file>
                        <expiration>1428994820549535</expiration>
                    </query>
                 </iq>
                 */
                NSString *token = [[query elementForName:@"token"] stringValue];
                NSString *file = [[query elementForName:@"file"] stringValue];
                NSString *expiration = [[query elementForName:@"expiration"] stringValue];
                UploadBlock uploadBlock = (UploadBlock)[uploadCompletionBlockDcitionary objectForKey:key];
                
                if (uploadBlock) {
                    
                    dispatch_main_async_safe(^{
                        uploadBlock(token, file, expiration, nil);
                    });
                    
                    [uploadCompletionBlockDcitionary removeObjectForKey:key];
                }
                
            }
            else if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
            {
                /*
                 <iq type="result" id="2115763">
                    <query xmlns="aft:mms" query_type="download" >https://xxx.aft.s3.amazonaws.com/8e13373a-46e8-40c4-8f18-dc2c9cf21223?AWSAccessKeyId=AKIAIQJNLH5YIBB3LV4Q&amp;Signature=yXTcTAfMstsIQzN5Opx5xGM9ur8%3D&amp;Expires=1426237616</query>
                 </iq>
                 */
                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:key];
                NSString *file = [[blockDic allKeys] firstObject];
                
                DownloadBlock downloadBlock = (DownloadBlock)[blockDic objectForKey:file];
                
                if (downloadBlock) {
                    
                    dispatch_main_async_safe(^{
                        downloadBlock([query stringValue], nil);
                    });
                    
                    [downloadCompletionBlockDcitionary removeObjectForKey:key];
                }
                
            }

            
            return YES;
        }
    }
    
    return NO;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:NO];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"You had disconnect with the server"                                                                      forKey:NSLocalizedDescriptionKey];
    
    NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
    
    [uploadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        UploadBlock uploadBlock = (UploadBlock)obj;
        
        if (uploadBlock) {
            dispatch_main_async_safe(^{
                uploadBlock(nil, nil, nil, _error);
            });
        }
        
    }];
    
    [downloadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *file = [[dic allKeys] firstObject];
        DownloadBlock downloadBlock = (DownloadBlock)[dic objectForKey:file];
        
        if (downloadBlock) {
            dispatch_main_async_safe(^{
                downloadBlock(nil, _error);
            });
        }
        
    }];
    
    [uploadCompletionBlockDcitionary removeAllObjects];
    [downloadCompletionBlockDcitionary removeAllObjects];
}

@end
