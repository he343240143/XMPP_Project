//
//  XMPPRosterQueryModule.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/4.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import "XMPP.h"
#import "XMPPRoster.h"

typedef NS_ENUM(NSUInteger, XMPPRosterFetchStatus){
    XMPPRosterFetchAvailable = 0,
    XMPPRosterFetchPrep = 1,
    XMPPRosterFetching = 2,
    XMPPRosterFetchEnd = 3
};

@protocol XMPPRosterQueryModuleStorage;


@interface XMPPRosterQueryModule : XMPPModule <XMPPRosterDelegate>
{
    __strong XMPPRoster *_xmppRoster;
    __strong id <XMPPRosterQueryModuleStorage> _moduleStorage;
    
    XMPPRosterFetchStatus _xmppRosterFetchStatus;
}

@property(nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (assign, nonatomic, readonly) XMPPRosterFetchStatus xmppRosterFetchStatus;

- (id)initWithRoster:(XMPPRoster *)xmppRoster;
- (id)initWithRoster:(XMPPRoster *)xmppRoster  dispatchQueue:(dispatch_queue_t)queue;

- (BOOL)privateModelForJID:(XMPPJID *)jid;
- (BOOL)userExistInRosterForJID:(XMPPJID *)jid;
- (NSString *)nickNameForJID:(XMPPJID *)jid;
- (NSString *)displayNameForJID:(XMPPJID *)jid;


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPRosterQueryModuleDelegate <NSObject>
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
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPRosterQueryModuleStorage <NSObject>

- (BOOL)privateModelForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (BOOL)userExistInRosterForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)nickNameForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)displayNameForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;

/**
 * Clears the roster from the store.
 * This is used so we can clear any cached roster for the JID.
 **/
- (void)clearRosterForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;

@end
