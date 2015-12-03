//
//  XMPPAllMessageQueryModule.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import "XMPP.h"
#import "XMPPExtendMessageObject.h"

@class XMPPAllMessage;
@class XMPPMessageCoreDataStorageObject;
@protocol XMPPAllMessageQueryModuleStorage;
@protocol XMPPAllMessageQueryModuleDelegate;

@interface XMPPAllMessageQueryModule : XMPPModule
{
    __strong XMPPAllMessage *_xmppAllMessage;
    __strong id <XMPPAllMessageQueryModuleStorage> _moduleStorage;
}

@property(nonatomic, strong, readonly) XMPPAllMessage *xmppAllMessage;

- (id)initWithAllMessage:(XMPPAllMessage *)xmppAllMessage;
- (id)initWithAllMessage:(XMPPAllMessage *)xmppAllMessage  dispatchQueue:(dispatch_queue_t)queue;

- (XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObjectWithMessageID:(NSString *)messageID;
- (XMPPMessageSendStatusType)xmppMessageSendStatusWithMessageID:(NSString *)messageID;


@end


@protocol XMPPAllMessageQueryModuleStorage <NSObject>

@optional

- (NSInteger)messageSendStateWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream;
- (id)messageWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream;

@end


@protocol XMPPAllMessageQueryModuleDelegate <NSObject>

@optional

@end

