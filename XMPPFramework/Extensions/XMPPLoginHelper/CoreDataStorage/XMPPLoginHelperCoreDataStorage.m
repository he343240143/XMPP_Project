//
//  XMPPLoginUserCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginHelperCoreDataStorage.h"
#import "XMPP.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPLogging.h"
#import "XMPPLoginUserCoreDataStorageObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/*
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPLoginHelperCoreDataStorage

static XMPPLoginHelperCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPLoginHelperCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPLoginHelper *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    [super commonInit];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPLoginUserStorage methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveLoginId:(NSString *)loginId loginIdType:(NSUInteger)loginIdType
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        
        if (user) {
            user.loginId = loginId;
            user.loginIdType = @(loginIdType);
        }else{
            
            if (loginIdType == LoginHelperIdTypePhone) {
                [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                     phoneNumber:loginId
                                                                       autoLogin:YES
                                                                streamBareJidStr:nil];
            }else{
                [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    emailAddress:loginId
                                                                       autoLogin:YES
                                                                streamBareJidStr:nil];
            }
        }
        
    }];
}


- (void)updatePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        
        if (user != nil) {
            user.loginId = phoneNumber;
            user.loginIdType = @(LoginHelperIdTypePhone);
            user.streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                 phoneNumber:phoneNumber
                                                                   autoLogin:YES
                                                            streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        }
    }];
}
- (void)updateEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        
        if (user != nil) {
            user.loginId = emailAddress;
            user.loginIdType = @(LoginHelperIdTypeEmail);
            user.streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                 emailAddress:emailAddress
                                                                   autoLogin:YES
                                                            streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        }
        
    }];
}
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber emailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        
        if (phoneNumber.length > 0) {
    
            if (object == nil) {
                object = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                              phoneNumber:phoneNumber
                                                                                autoLogin:YES
                                                                         streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
            }else{
                object.loginId = phoneNumber;
                object.loginIdType = @(LoginHelperIdTypePhone);
                object.streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
            }
        }else if(emailAddress.length > 0){
            if (object == nil) {
                object = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                             emailAddress:emailAddress
                                                                                autoLogin:YES
                                                                         streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
            }else{
                object.loginId = emailAddress;
                object.loginIdType = @(LoginHelperIdTypeEmail);
                object.streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
            }
        }
    }];
}

- (NSString *)streamBareJidStrForCurrentUser
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user) {
            
            result = user.streamBareJidStr;
        }
        
    }];
    
    return result;
}

- (NSData *)clientDataCurrentUser
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user) {
            result = user.clientKeyData;
        }
        
    }];
    
    return result;
}

- (NSData *)serverDataCurrentUser
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user) {
            result = user.serverKeyData;
        }
        
    }];
    
    return result;
}



- (BOOL)autoLoginCurrentUser
{
    __block BOOL result = NO;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
    
        result = [user.autoLogin boolValue];
        
    }];
    
    return result;
}

- (id)currentLoginUser
{
    __block id result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        result = user;
        
    }];
    
    return result;
}

- (NSString *)currentNeedLoginIdStr
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        result = user.loginId;
    }];
    
    return result;
}
- (NSUInteger)currentNeedLoginIdType
{
    __block NSUInteger result = LoginHelperIdTypePhone;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        
        result = [user.loginIdType unsignedIntegerValue];
        
    }];
    
    return result;
}
- (NSString *)currenNeedLoginStreamBareJidStr
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        result = user.streamBareJidStr;
    }];
    
    return result;
}


- (void)deleteLoginUser
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        [moc deleteObject:user];
    }];
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user != nil) {
            user.clientKeyData = clientData;
            user.serverKeyData = serverData;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                 phoneNumber:phoneNumber
                                                                   autoLogin:YES
                                                               clientKeyData:clientData
                                                               serverKeyData:serverData
                                                            streamBareJidStr:nil];
        }
    }];
}
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user != nil) {
            user.clientKeyData = clientData;
            user.serverKeyData = serverData;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                emailAddress:emailAddress
                                                                   autoLogin:YES
                                                               clientKeyData:clientData
                                                               serverKeyData:serverData
                                                            streamBareJidStr:nil];
        }
    }];
}
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user != nil) {
            user.clientKeyData = clientData;
            user.serverKeyData = serverData;
        }else{
            user = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc phoneNumber:nil autoLogin:YES streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
            user.clientKeyData = clientData;
            user.serverKeyData = serverData;
        }
    }];
}

- (void)updateLoginTime
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (user) {
            user.loginTime = [NSDate date];
        }
    }];
}

- (void)updateAutoLogin:(BOOL)autoLogin
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc];
        if (object) {
            object.autoLogin = @(autoLogin);
        }
    }];
}
@end
