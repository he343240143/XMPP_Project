//
//  XMPPChatRoomQueryModule.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatRoomQueryModule.h"
#import "NSData+XMPP.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPLogging.h"
#import "XMPPPresence.h"
#import "XMPPStream.h"
#import "XMPPChatRoom.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/*
// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif
*/

@implementation XMPPChatRoomQueryModule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Getter/setter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@synthesize xmppChatRoom = _xmppChatRoom;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init/dealloc
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPvCardAvatarModule.h are supported.
    
    return [self initWithChatRoom:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPRosterQueryModule.h are supported.
    
    return [self initWithChatRoom:nil dispatchQueue:NULL];
}

- (id)initWithChatRoom:(XMPPChatRoom *)xmppChatRoom
{
    return [self initWithChatRoom:xmppChatRoom dispatchQueue:NULL];
}

- (id)initWithChatRoom:(XMPPChatRoom *)xmppChatRoom dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(xmppChatRoom != nil);
    
    if ((self = [super initWithDispatchQueue:queue])) {
        _xmppChatRoom = xmppChatRoom;
        
        // we don't need to call the storage configureWithParent:queue: method,
        // because the vCardTempModule already did that.
        _moduleStorage = (id <XMPPChatRoomQueryModuleStorage>)xmppChatRoom.xmppChatRoomStorage;
      
        [_xmppChatRoom addDelegate:self delegateQueue:moduleQueue];
        
    }
    return self;
}


- (void)dealloc {
    
    [_xmppChatRoom removeDelegate:self];
    
    _moduleStorage = nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)chatRoomNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage chatRoomNickNameForBareChatRoomJidStr:bareChatRoomJidStr xmppStream:xmppStream];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
    
}
- (NSString *)userNickNameForBareJidStr:(NSString *)bareJidStr withBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage userNickNameForBareJidStr:bareJidStr withBareChatRoomJidStr:bareChatRoomJidStr xmppStream:xmppStream];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
    
}

- (BOOL)privateCharRoomForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage privateChatRoomForBareChatRoomJidStr:bareChatRoomJidStr xmppStream:xmppStream];
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@end

