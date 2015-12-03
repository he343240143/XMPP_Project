//
//  XMPPChatRoomQueryModule.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import "XMPP.h"

@class XMPPChatRoom;
@protocol XMPPChatRoomQueryModuleStorage;

@interface XMPPChatRoomQueryModule : XMPPModule
{
    __strong XMPPChatRoom *_xmppChatRoom;
    __strong id <XMPPChatRoomQueryModuleStorage> _moduleStorage;
}

@property(nonatomic, strong, readonly) XMPPChatRoom *xmppChatRoom;

- (id)initWithChatRoom:(XMPPChatRoom *)xmppChatRoom;
- (id)initWithChatRoom:(XMPPChatRoom *)xmppChatRoom  dispatchQueue:(dispatch_queue_t)queue;

- (BOOL)privateCharRoomForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
- (NSString *)chatRoomNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
- (NSString *)userNickNameForBareJidStr:(NSString *)bareJidStr withBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPChatRoomQueryModuleDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomQueryModuleDelegate <NSObject>
/*
 #if TARGET_OS_IPHONE
 - (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
 didReceivePhoto:(UIImage *)photo
 forJID:(XMPPJID *)jid;
 #else
 - (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
 didReceivePhoto:(NSImage *)photo
 forJID:(XMPPJID *)jid;
 #endif
 */
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPChatRoomQueryModuleStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomQueryModuleStorage <NSObject>

- (BOOL)privateChatRoomForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;
- (NSString *)chatRoomNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;
- (NSString *)userNickNameForBareJidStr:(NSString *)bareJidStr withBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;

@end

