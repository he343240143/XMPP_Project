//
//  XMPPOrgUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgUserCoreDataStorageObject.h"
#import "XMPPOrgPositionCoreDataStorageObject.h"
#import "XMPPOrgCoreDataStorageObject.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation XMPPOrgUserCoreDataStorageObject

@dynamic streamBareJidStr;
@dynamic userPtShip;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSMutableDictionary *)propertyTransformDictionary
{
    return [super propertyTransformDictionary];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)userJidStr
{
    [self willAccessValueForKey:@"userJidStr"];
    NSString *value = [self primitiveValueForKey:@"userJidStr"];
    [self didAccessValueForKey:@"userJidStr"];
    
    return value;
}

- (void)setUserJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"userJidStr"];
    [self setPrimitiveValue:value forKey:@"userJidStr"];
    [self didChangeValueForKey:@"userJidStr"];
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSManagedObject
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromInsert
{
    // your code here ...
}

- (void)awakeFromFetch
{
    // your code here ...
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                             orgId:(NSString *)orgId
                        userJidStr:(NSString *)userJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return nil;
    if (userJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userPtShip.orgId == %@ AND streamBareJidStr == %@ AND userJidStr == %@",orgId, streamBareJidStr, userJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgUserCoreDataStorageObject *)[results lastObject];
}


+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    
    if (moc == nil) return nil;
    if (dic == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    
    XMPPOrgUserCoreDataStorageObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPOrgUserCoreDataStorageObject"
                                                                              inManagedObjectContext:moc];
    
    newUser.streamBareJidStr = streamBareJidStr;
    
    [newUser updateWithDic:dic];
    
    return newUser;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    
    NSString *tempOrgId = orgId ? :dic[@"orgId"];
    NSString *temuserJidStr = dic[@"userJidStr"];
    NSString *tempPtId = dic[@"ptId"];
    
    if (tempOrgId == nil)  return result;
    if (temuserJidStr == nil)  return result;
    if (moc == nil)  return result;
    
    XMPPOrgUserCoreDataStorageObject *user = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         orgId:tempOrgId
                                                                                                    userJidStr:temuserJidStr
                                                                                              streamBareJidStr:streamBareJidStr];
    if (user != nil) {
        
        [user updateWithDic:dic];
        result = YES;
        
    }else{
        
        user = [XMPPOrgUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      withDic:dic
                                                             streamBareJidStr:streamBareJidStr];
        
        XMPPOrgPositionCoreDataStorageObject *position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                   withPtId:tempPtId
                                                                                                                      orgId:tempOrgId
                                                                                                           streamBareJidStr:streamBareJidStr];
        
        if (!position) position = [XMPPOrgPositionCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                             withDic:@{
                                                                                                       @"ptId":tempPtId,
                                                                                                       @"orgId":tempOrgId
                                                                                                       }
                                                                                    streamBareJidStr:streamBareJidStr];
        
        [position addPtUserShipObject:user];
     
        result = YES;
    }
    
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                               orgId:(NSString *)orgId
                          userJidStr:(NSString *)userJidStr
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return NO;
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPOrgUserCoreDataStorageObject *deleteObject = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              orgId:orgId
                                                                                                         userJidStr:userJidStr
                                                                                                   streamBareJidStr:streamBareJidStr];
    if (deleteObject){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    NSString *tempOrgId = orgId ? :[dic objectForKey:@"orgId"];
    NSString *temuserJidStr = [dic objectForKey:@"userJidStr"];
    
    
    return [XMPPOrgUserCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                    orgId:tempOrgId
                                                               userJidStr:temuserJidStr
                                                         streamBareJidStr:streamBareJidStr];
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempUserJidStr = [dic objectForKey:@"userJidStr"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempUserJidStr) self.userJidStr = tempUserJidStr;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

@end
