//
//  XMPPLoginUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, LoginHelperIdType) {
    LoginHelperIdTypePhone = 0,
    LoginHelperIdTypeEmail
};

@interface XMPPLoginUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSNumber * loginIdType;
@property (nonatomic, retain) NSString * loginId;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * autoLogin;
@property (nonatomic, retain) NSData * clientKeyData;
@property (nonatomic, retain) NSData * serverKeyData;
@property (nonatomic, retain) NSDate * loginTime;

//fetch
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc;

//add
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           loginId:(NSString *)loginId
                       loginIdType:(LoginHelperIdType)loginIdType
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithLoginId:(NSString *)loginId
              loginIdType:(LoginHelperIdType)loginIdType
                autoLogin:(BOOL)autoLogin
            clientKeyData:(NSData *)clientKeyData
            serverkeyData:(NSData *)serverkeyData
         streamBareJidStr:(NSString *)streamBareJidStr;

@end
