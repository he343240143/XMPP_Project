//
//  XMPPAllMessageQueryModule.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPAllMessageQueryModule.h"
#import "XMPPStream.h"
#import "XMPPAllMessage.h"
#import "XMPPLogging.h"


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

@implementation XMPPAllMessageQueryModule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Getter/setter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@synthesize xmppAllMessage = _xmppAllMessage;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init/dealloc
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPvCardAvatarModule.h are supported.
    
    return [self initWithAllMessage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPRosterQueryModule.h are supported.
    
    return [self initWithAllMessage:nil dispatchQueue:NULL];
}

- (id)initWithAllMessage:(XMPPAllMessage *)xmppAllMessage
{
    return [self initWithAllMessage:xmppAllMessage dispatchQueue:NULL];
}

- (id)initWithAllMessage:(XMPPAllMessage *)xmppAllMessage  dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(xmppAllMessage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])) {
        _xmppAllMessage = xmppAllMessage;
        
        // we don't need to call the storage configureWithParent:queue: method,
        // because the vCardTempModule already did that.
        _moduleStorage = (id <XMPPAllMessageQueryModuleStorage>)xmppAllMessage.xmppMessageStorage;
        
        [_xmppAllMessage addDelegate:self delegateQueue:moduleQueue];
        
    }
    return self;
}

- (void)dealloc {
    
    [_xmppAllMessage removeDelegate:self];
    
    _moduleStorage = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObjectWithMessageID:(NSString *)messageID
{
    __block XMPPMessageCoreDataStorageObject *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage messageWithID:messageID xmppStream:xmppStream];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (XMPPMessageSendStatusType)xmppMessageSendStatusWithMessageID:(NSString *)messageID
{
    __block XMPPMessageSendStatusType result = XMPPMessageSendingType;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage messageSendStateWithID:messageID xmppStream:xmppStream];
        
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
