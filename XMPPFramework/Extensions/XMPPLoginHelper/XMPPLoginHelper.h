 //
//  XMPPLoginHelper.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPModule.h"

@protocol XMPPLoginHelperStorage;
@protocol XMPPLoginHelperDelegate;


@interface XMPPLoginHelper : XMPPModule
{
    __strong id <XMPPLoginHelperStorage> _xmppLoginHelperStorage;
}

@property (strong, readonly) id <XMPPLoginHelperStorage> xmppLoginHelperStorage;

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage;
- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

- (void)saveLoginId:(NSString *)loginId loginIdType:(NSUInteger)loginIdType;

- (void)updatePhoneNumberCurrentLoginUser:(NSString *)phoneNumber;
- (void)updateEmailAddressCurrentLoginUser:(NSString *)emailAddress;
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (void)updateStreamBareJidStrWithEmailAddress:(NSString *)emailAddress;

- (void)deleteCurrentLoginUser;

- (NSString *)streamBareJidStrForCurrentUser;

- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr;
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr;

- (NSString *)currentLoginIdStr;
- (NSUInteger)currentLoginIdType;
- (NSString *)currentUserBareJidStr;

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber;
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress;
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData;

- (NSData *)clientDataCurrentLoginUser;

- (NSData *)serverDataCurrentLoginUser;

- (void)updateLoginTimeCurrentLoginUser;

- (BOOL)autoLoginCurrentUser;

- (BOOL)hasPasswordForCurrentUser;

- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin;

- (id)currentLoginUser;

@end


@protocol XMPPLoginHelperStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPLoginHelper *)aParent queue:(dispatch_queue_t)queue;

@optional

- (void)updatePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream;
- (void)updateEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream;
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber emailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream;

- (NSString *)streamBareJidStrForCurrentUser;

- (NSString *)currentNeedLoginIdStr;
- (NSUInteger)currentNeedLoginIdType;
- (NSString *)currenNeedLoginStreamBareJidStr;

- (void)saveLoginId:(NSString *)loginId loginIdType:(NSUInteger)loginIdType;

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber;
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress;
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)stream;

- (NSData *)clientDataCurrentUser;
- (NSData *)serverDataCurrentUser;

- (BOOL)autoLoginCurrentUser;

- (id)currentLoginUser;

- (void)deleteLoginUser;
- (void)updateLoginTime;
- (void)updateAutoLogin:(BOOL)autoLogin;

@end

@protocol XMPPLoginHelperDelegate <NSObject>

@required

@optional

@end