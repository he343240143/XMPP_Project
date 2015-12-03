//
//  XMPPMmsRequest.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/4/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

typedef NS_ENUM(NSUInteger, XMPPMmsRequestUploadType) {
    XMPPMmsRequestUploadTypePublic = 1,
    XMPPMmsRequestUploadTypePrivateMessage,
    XMPPMmsRequestUploadTypePrivateFileLibrary
};

@interface XMPPMmsRequest : XMPPModule

// privare upload new file
- (void)requestUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;

// public upload new file
- (void)requestPublicUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;


- (void)requestUploadInfoWithType:(XMPPMmsRequestUploadType)type
                  completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;


// upload exists file
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                        completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                             requestKey:(NSString *)requestKey
                        completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;


- (void)requestDownloadURLWithFile:(NSString *)file
                    completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock;
- (void)requestDownloadURLWithFile:(NSString *)file
                         requestKey:(NSString *)requestKey
                    completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock;


@end
