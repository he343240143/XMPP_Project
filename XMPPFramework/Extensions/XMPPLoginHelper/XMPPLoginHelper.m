//
//  XMPPLoginUser.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginHelper.h"
#import "XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"

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

@implementation XMPPLoginHelper
@synthesize xmppLoginHelperStorage = _xmppLoginHelperStorage;

- (id)init
{
    return [self initWithLoginHelperStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithLoginHelperStorage:nil dispatchQueue:queue];
}

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage
{
    return [self initWithLoginHelperStorage:storage dispatchQueue:NULL];
}

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppLoginHelperStorage = storage;
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

- (void)deactivate
{
    XMPPLogTrace();
    
    // Reserved for future potential use
    
    [super deactivate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may optionally be used by XMPPLoginUserStorage classes (declared in XMPPLoginUserPrivate.h).
 **/
- (GCDMulticastDelegate *)multicastDelegate
{
    return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPLoginHelperStorage>)xmppLoginHelperStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppLoginHelperStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - setter/getter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
- (void)setActiveUserID:(NSString *)activeuserid
{
    dispatch_block_t block = ^{
        activeUserID = [activeuserid copy];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (NSString *)activeUserID
{
    if (!activeUserID) {
        activeUserID = [self userIDWithBareJIDStr:[[xmppStream myJID] bare]];
    }
    
    return activeUserID;
}
 */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveLoginId:(NSString *)loginId loginIdType:(NSUInteger)loginIdType
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveLoginId:loginId loginIdType:loginIdType];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updatePhoneNumberCurrentLoginUser:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updatePhoneNumber:phoneNumber xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateEmailAddressCurrentLoginUser:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateEmailAddress:emailAddress xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateStreamBareJidStrWithPhoneNumber:phoneNumber emailAddress:nil xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateStreamBareJidStrWithEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateStreamBareJidStrWithPhoneNumber:nil emailAddress:emailAddress xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)deleteCurrentLoginUser
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage deleteLoginUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}



- (NSString *)streamBareJidStrForCurrentUser
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage streamBareJidStrForCurrentUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSString *)currentLoginIdStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage currentNeedLoginIdStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSUInteger)currentLoginIdType
{
    __block NSUInteger result = 0;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage currentNeedLoginIdType];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSString *)currentUserBareJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage currenNeedLoginStreamBareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSData *)clientDataCurrentLoginUser
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage clientDataCurrentUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSData *)serverDataCurrentLoginUser
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage serverDataCurrentUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}


- (BOOL)autoLoginCurrentUser
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage autoLoginCurrentUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (BOOL)hasPasswordForCurrentUser
{
    return ([self clientDataCurrentLoginUser] && [self serverDataCurrentLoginUser]);
}

- (id)currentLoginUser
{
    __block id currentLoginUser = nil;
    
    dispatch_block_t block = ^{
        currentLoginUser = [_xmppLoginHelperStorage currentLoginUser];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return currentLoginUser;
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveClientData:clientData serverData:serverData forPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveClientData:clientData serverData:serverData forEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveCurrentUserClientData:clientData serverData:serverData xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateLoginTimeCurrentLoginUser
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateLoginTime];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateAutoLogin:autoLogin];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPLogTrace();
    switch (sender.authenticateType) {
        case XMPPLoginTypePhone:
        {
            [self saveLoginId:[[XMPPJID jidWithString:sender.authenticateStr] user] loginIdType:LoginHelperIdTypePhone];
        }
            break;
        case XMPPLoginTypeEmail:
        {
            [self saveLoginId:[[XMPPJID jidWithString:sender.authenticateStr] user] loginIdType:LoginHelperIdTypeEmail];
        }
            break;
        default:
            break;
    }
}

- (void)xmppStreamDidChangeMyJID:(XMPPStream *)sender
{
    XMPPLogTrace();
    
    if (sender.hasMyJIDFromServer) {
        switch (sender.authenticateType) {
            case XMPPLoginTypePhone:
                [self updateStreamBareJidStrWithPhoneNumber:[[XMPPJID jidWithString:sender.authenticateStr] user]];
                break;
            case XMPPLoginTypeEmail:
                [self updateStreamBareJidStrWithEmailAddress:[[XMPPJID jidWithString:sender.authenticateStr] user]];
                break;
            default:
                break;
        }
    }
}

- (NSString *)streamBareJidStrWithXMPPStream:(XMPPStream *)sender
{
    return [_xmppLoginHelperStorage streamBareJidStrForCurrentUser];;
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)sender
{
    switch (sender.authenticateType) {
        case XMPPLoginTypePhone:
            [self saveClientData:clientData serverData:serverData forPhoneNumber:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        case XMPPLoginTypeEmail:
            [self saveClientData:clientData serverData:serverData forEmailAddress:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        default:
            [self saveCurrentUserClientData:clientData serverData:serverData];
            break;
    }
}

- (NSData *)clientKeyDataInDatabaseWithXMPPStream:(XMPPStream *)sender
{
    return [self clientDataCurrentLoginUser];
}

- (NSData *)serverKeyDataInDatabaseWithXMPPStream:(XMPPStream *)sender
{
    return [self serverDataCurrentLoginUser];
}

- (NSString *)currentUserBareJidStrWithXMPPStream:(XMPPStream *)sender
{
    return [self currentUserBareJidStr];
}
- (NSString *)currentUserLoginIdStrWithXMPPStream:(XMPPStream *)sender
{
    return [self currentLoginIdStr];
}

- (NSInteger)currentUserLoginIdTypeWithXMPPStream:(XMPPStream *)sender
{
    return [self currentLoginIdType];
}


@end
