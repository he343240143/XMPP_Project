//
//  XMPPRosterQueryModule.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/4.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPRosterQueryModule.h"
#import "NSData+XMPP.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPLogging.h"
#import "XMPPPresence.h"
#import "XMPPStream.h"
#import "XMPPRoster.h"
//#import "XMPPvCardTemp.h"

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


@implementation XMPPRosterQueryModule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Getter/setter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@synthesize xmppRoster = _xmppRoster;
@synthesize xmppRosterFetchStatus = _xmppRosterFetchStatus;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init/dealloc
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPvCardAvatarModule.h are supported.
    
    return [self initWithRoster:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPRosterQueryModule.h are supported.
    
    return [self initWithRoster:nil dispatchQueue:NULL];
}

- (id)initWithRoster:(XMPPRoster *)roster
{
    return [self initWithRoster:roster dispatchQueue:NULL];
}

- (id)initWithRoster:(XMPPRoster *)roster dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(roster != nil);
    
    if ((self = [super initWithDispatchQueue:queue])) {
        _xmppRoster = roster;
        
        // we don't need to call the storage configureWithParent:queue: method,
        // because the vCardTempModule already did that.
        _moduleStorage = (id <XMPPRosterQueryModuleStorage>)roster.xmppRosterStorage;
        _xmppRosterFetchStatus = XMPPRosterFetchAvailable;
        
        [_xmppRoster addDelegate:self delegateQueue:moduleQueue];
        
    }
    return self;
}


- (void)dealloc {
    
    [_xmppRoster removeDelegate:self];
    
    _moduleStorage = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPRosterFetchStatus)xmppRosterFetchStatus
{
    __block XMPPRosterFetchStatus result = XMPPRosterFetchAvailable;
    
    dispatch_block_t block = ^{
        result = _xmppRosterFetchStatus;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)nickNameForJID:(XMPPJID *)jid
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage nickNameForJID:jid xmppStream:xmppStream];
        
        if (result == nil && _xmppRosterFetchStatus == XMPPRosterFetchPrep){
            [_xmppRoster fetchRoster];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
    
}
- (NSString *)displayNameForJID:(XMPPJID *)jid
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage displayNameForJID:jid xmppStream:xmppStream];
        
        if (result == nil && _xmppRosterFetchStatus == XMPPRosterFetchPrep){
            [_xmppRoster fetchRoster];
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
    
}

- (BOOL)privateModelForJID:(XMPPJID *)jid
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage privateModelForJID:jid xmppStream:xmppStream];
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (BOOL)userExistInRosterForJID:(XMPPJID *)jid
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        result = [_moduleStorage userExistInRosterForJID:jid xmppStream:xmppStream];
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

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPLogTrace();
    _xmppRosterFetchStatus = XMPPRosterFetchPrep;
}
//- (void)xmppStreamDidConnect:(XMPPStream *)sender {
//    XMPPLogTrace();
//
//    if(self.autoClearMyvcard)
//    {
//        /*
//         * XEP-0153 Section 4.2 rule 1
//         *
//         * A client MUST NOT advertise an avatar image without first downloading the current vCard.
//         * Once it has done this, it MAY advertise an image.
//         */
//        [_moduleStorage clearvCardTempForJID:[sender myJID] xmppStream:sender];
//    }
//}
//
//
//
//
//- (XMPPPresence *)xmppStream:(XMPPStream *)sender willSendPresence:(XMPPPresence *)presence {
//    XMPPLogTrace();
//    
//    NSXMLElement *currentXElement = [presence elementForName:kXMPPvCardAvatarElement xmlns:kXMPPvCardAvatarNS];
//    
//    //If there is already a x element then remove it
//    if(currentXElement)
//    {
//        NSUInteger currentXElementIndex = [[presence children] indexOfObject:currentXElement];
//        
//        if(currentXElementIndex != NSNotFound)
//        {
//            [presence removeChildAtIndex:currentXElementIndex];
//        }
//    }
//    // add our photo info to the presence stanza
//    NSXMLElement *photoElement = nil;
//    NSXMLElement *xElement = [NSXMLElement elementWithName:kXMPPvCardAvatarElement xmlns:kXMPPvCardAvatarNS];
//    
//    NSString *photoHash = [_moduleStorage photoHashForJID:[sender myJID] xmppStream:sender];
//    
//    if (photoHash != nil)
//    {
//        photoElement = [NSXMLElement elementWithName:kXMPPvCardAvatarPhotoElement stringValue:photoHash];
//    } else {
//        photoElement = [NSXMLElement elementWithName:kXMPPvCardAvatarPhotoElement];
//    }
//    
//    [xElement addChild:photoElement];
//    [presence addChild:xElement];
//    
//    // Question: If photoElement is nil, should we be adding xElement?
//    
//    return presence;
//}
//
//
//- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence  {
//    XMPPLogTrace();
//    
//    NSXMLElement *xElement = [presence elementForName:kXMPPvCardAvatarElement xmlns:kXMPPvCardAvatarNS];
//    
//    if (xElement == nil) {
//        return;
//    }
//    
//    NSXMLElement *photoElement = [xElement elementForName:kXMPPvCardAvatarPhotoElement];
//    
//    if (photoElement == nil) {
//        return;
//    }
//    
//    NSString *photoHash = [photoElement stringValue];
//    
//    XMPPJID *jid = [presence from];
//    
//    NSString *savedPhotoHash = [_moduleStorage photoHashForJID:jid xmppStream:xmppStream];
//    
//    // check the hash
//    if (![photoHash isEqualToString:[_moduleStorage photoHashForJID:jid xmppStream:xmppStream]]
//        && !([photoHash length] == 0 && [savedPhotoHash length] == 0)) {
//        [_xmppvCardTempModule fetchvCardTempForJID:jid ignoreStorage:YES];
//    }
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    XMPPLogTrace();
    _xmppRosterFetchStatus = XMPPRosterFetching;
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    XMPPLogTrace();
    _xmppRosterFetchStatus = XMPPRosterFetchEnd;
}
@end
