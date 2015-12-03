//
//  XMPPLoginUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUserCoreDataStorageObject.h"


@implementation XMPPLoginUserCoreDataStorageObject

@dynamic loginIdType;
@dynamic loginId;
@dynamic streamBareJidStr;
@dynamic clientKeyData;
@dynamic serverKeyData;
@synthesize loginTime;
@synthesize autoLogin;


- (NSString *)loginId
{
    [self willAccessValueForKey:@"loginId"];
    NSString *value = [self primitiveValueForKey:@"loginId"];
    [self didAccessValueForKey:@"loginId"];
    return value;
}

- (void)setLoginId:(NSString *)value
{
    [self willChangeValueForKey:@"loginId"];
    [self setPrimitiveValue:value forKey:@"loginId"];
    [self didChangeValueForKey:@"loginId"];
}

- (NSNumber *)loginIdType
{
    [self willAccessValueForKey:@"loginIdType"];
    NSNumber *value = [self primitiveValueForKey:@"loginIdType"];
    [self didAccessValueForKey:@"loginIdType"];
    return value;
}

- (void)setLoginIdType:(NSNumber *)value
{
    [self willChangeValueForKey:@"loginIdType"];
    [self setPrimitiveValue:value forKey:@"loginIdType"];
    [self didChangeValueForKey:@"loginIdType"];
}

- (NSNumber *)autoLogin
{
    [self willAccessValueForKey:@"autoLogin"];
    NSNumber *value = [self primitiveValueForKey:@"autoLogin"];
    [self didAccessValueForKey:@"autoLogin"];
    return value;
}

- (void)setAutoLogin:(NSNumber *)value
{
    [self willChangeValueForKey:@"autoLogin"];
    [self setPrimitiveValue:value forKey:@"autoLogin"];
    [self didChangeValueForKey:@"autoLogin"];
}
- (NSDate *)loginTime
{
    [self willAccessValueForKey:@"loginTime"];
    NSDate *value = [self primitiveValueForKey:@"loginTime"];
    [self didAccessValueForKey:@"loginTime"];
    return value;
}

- (void)setLoginTime:(NSDate *)value
{
    [self willChangeValueForKey:@"loginTime"];
    [self setPrimitiveValue:value forKey:@"loginTime"];
    [self didChangeValueForKey:@"loginTime"];
}

- (NSString *)streamBareJidStr
{
    [self willAccessValueForKey:@"streamBareJidStr"];
    NSString *value = [self primitiveValueForKey:@"streamBareJidStr"];
    [self didAccessValueForKey:@"streamBareJidStr"];
    return value;
}

- (void)setStreamBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"streamBareJidStr"];
    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
    [self didChangeValueForKey:@"streamBareJidStr"];
}

- (NSData *)clientKeyData
{
    [self willAccessValueForKey:@"clientKeyData"];
    NSData *value = [self primitiveValueForKey:@"clientKeyData"];
    [self didAccessValueForKey:@"clientKeyData"];
    return value;
}

- (void)setClientKeyData:(NSData *)value
{
    [self willChangeValueForKey:@"clientKeyData"];
    [self setPrimitiveValue:value forKey:@"clientKeyData"];
    [self didChangeValueForKey:@"clientKeyData"];
}

- (NSData *)serverKeyData
{
    [self willAccessValueForKey:@"serverKeyData"];
    NSData *value = [self primitiveValueForKey:@"serverKeyData"];
    [self didAccessValueForKey:@"serverKeyData"];
    return value;
}

- (void)setServerKeyData:(NSData *)value
{
    [self willChangeValueForKey:@"serverKeyData"];
    [self setPrimitiveValue:value forKey:@"serverKeyData"];
    [self didChangeValueForKey:@"serverKeyData"];
}

#pragma mark - awake action

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"loginTime"];
}

#pragma mark - public methods

//fetch methods
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPLoginUserCoreDataStorageObject class])
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPLoginUserCoreDataStorageObject *)[results lastObject];
}

// insert methods
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           loginId:(NSString *)loginId
                       loginIdType:(LoginHelperIdType)loginIdType
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (!moc) return nil;
    
    // Before insert a new object ,delete the old object firstly
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([XMPPLoginUserCoreDataStorageObject class])
     inManagedObjectContext:moc]];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *result = [moc executeFetchRequest:fetchRequest error:nil];
    
    for (XMPPLoginUserCoreDataStorageObject *user in result) {
        
        [moc deleteObject:user];
    }
    
    // Insert new object
    XMPPLoginUserCoreDataStorageObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([XMPPLoginUserCoreDataStorageObject class])
                                                                                inManagedObjectContext:moc];
    if (newUser) {
        [newUser updateWithLoginId:loginId
                       loginIdType:loginIdType
                         autoLogin:autoLogin
                     clientKeyData:clientKeyData
                     serverkeyData:serverKeyData
                  streamBareJidStr:streamBareJidStr];
        
        return newUser;
    }
    
    return nil;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:phonenumber
                                                                loginIdType:LoginHelperIdTypePhone
                                                                  autoLogin:autoLogin
                                                              clientKeyData:nil
                                                              serverKeyData:nil
                                                           streamBareJidStr:streamBareJidStr];
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:emailaddress
                                                                loginIdType:LoginHelperIdTypeEmail
                                                                  autoLogin:autoLogin
                                                              clientKeyData:nil
                                                              serverKeyData:nil
                                                           streamBareJidStr:streamBareJidStr];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:phonenumber
                                                                loginIdType:LoginHelperIdTypePhone
                                                                  autoLogin:autoLogin
                                                              clientKeyData:clientKeyData
                                                              serverKeyData:serverKeyData
                                                           streamBareJidStr:streamBareJidStr];
}



+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:emailaddress
                                                                loginIdType:LoginHelperIdTypeEmail
                                                                  autoLogin:autoLogin
                                                              clientKeyData:clientKeyData
                                                              serverKeyData:serverKeyData
                                                           streamBareJidStr:streamBareJidStr];
}



#pragma mark - object update method
- (void)updateWithLoginId:(NSString *)loginId
              loginIdType:(LoginHelperIdType)loginIdType
                autoLogin:(BOOL)autoLogin
            clientKeyData:(NSData *)clientKeyData
            serverkeyData:(NSData *)serverkeyData
             streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL hasChanges = NO;
    if (loginId) {
        [self setLoginId:loginId];
        hasChanges = YES;
    }
    if (loginIdType) {
        [self setLoginIdType:@(loginIdType)];
        hasChanges = YES;
    }
    if (clientKeyData) {
        [self setClientKeyData:clientKeyData];
        hasChanges = YES;
    }
    if (serverkeyData) {
        [self setServerKeyData:serverkeyData];
        hasChanges = YES;
    }
    if (streamBareJidStr) {
        [self setStreamBareJidStr:streamBareJidStr];
        hasChanges = YES;
    }

    [self setAutoLogin:@(autoLogin)];
    
    if (hasChanges) [self setLoginTime:[NSDate date]];
}

@end
