//
//  XMPPOrgCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgCoreDataStorageObject.h"
#import "NSString+NSDate.h"

@implementation XMPPOrgCoreDataStorageObject

@dynamic orgId;
@dynamic orgName;
@dynamic orgPhoto;
@dynamic orgState;
@dynamic orgStartTime;
@dynamic orgEndTime;
@dynamic orgAdminJidStr;
@dynamic orgDescription;
@dynamic streamBareJidStr;
@dynamic ptTag;
@dynamic userTag;
@dynamic relationShipTag;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSMutableDictionary *)propertyTransformDictionary
{
    NSMutableDictionary *keysMapDic = [super propertyTransformDictionary];
    
    [keysMapDic setValuesForKeysWithDictionary:@{
                                                 @"orgId":@"id",
                                                 @"orgName":@"name",
                                                 @"orgState":@"status",
                                                 @"orgStartTime":@"start_time",
                                                 @"orgEndTime":@"end_time",
                                                 @"orgAdminJidStr":@"admin",
                                                 @"orgDescription":@"description",
                                                 @"ptTag":@"job_tag",
                                                 @"userTag":@"member_tag",
                                                 @"orgRelationShipTag":@"link_tag",
                                                 }];
    
    return keysMapDic;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)orgId
{
    [self willAccessValueForKey:@"orgId"];
    NSString *value = [self primitiveValueForKey:@"orgId"];
    [self didAccessValueForKey:@"orgId"];
    
    return value;
}

- (void)setOrgId:(NSString *)value
{
    [self willChangeValueForKey:@"orgId"];
    [self setPrimitiveValue:value forKey:@"orgId"];
    [self didChangeValueForKey:@"orgId"];
}
- (NSString *)orgName
{
    [self willAccessValueForKey:@"orgName"];
    NSString *value = [self primitiveValueForKey:@"orgName"];
    [self didAccessValueForKey:@"orgName"];
    
    return value;
}

- (void)setOrgName:(NSString *)value
{
    [self willChangeValueForKey:@"orgName"];
    [self setPrimitiveValue:value forKey:@"orgName"];
    [self didChangeValueForKey:@"orgName"];
}

- (NSString *)orgPhoto
{
    [self willAccessValueForKey:@"orgPhoto"];
    NSString *value = [self primitiveValueForKey:@"orgPhoto"];
    [self didAccessValueForKey:@"orgPhoto"];
    
    return value;
}

- (void)setOrgPhoto:(NSString *)value
{
    [self willChangeValueForKey:@"orgPhoto"];
    [self setPrimitiveValue:value forKey:@"orgPhoto"];
    [self didChangeValueForKey:@"orgPhoto"];
}
- (NSNumber *)orgState
{
    [self willAccessValueForKey:@"orgState"];
    NSNumber *value = [self primitiveValueForKey:@"orgState"];
    [self didAccessValueForKey:@"orgState"];
    
    return value;
}

- (void)setOrgState:(NSNumber *)value
{
    [self willChangeValueForKey:@"orgState"];
    [self setPrimitiveValue:value forKey:@"orgState"];
    [self didChangeValueForKey:@"orgState"];
}
- (NSDate *)orgStartTime
{
    [self willAccessValueForKey:@"orgStartTime"];
    NSDate *value = [self primitiveValueForKey:@"orgStartTime"];
    [self didAccessValueForKey:@"orgStartTime"];
    
    return value;
}

- (void)setOrgStartTime:(NSDate *)value
{
    [self willChangeValueForKey:@"orgStartTime"];
    [self setPrimitiveValue:value forKey:@"orgStartTime"];
    [self didChangeValueForKey:@"orgStartTime"];
}
- (NSDate *)orgEndTime
{
    [self willAccessValueForKey:@"orgEndTime"];
    NSDate *value = [self primitiveValueForKey:@"orgEndTime"];
    [self didAccessValueForKey:@"orgEndTime"];
    
    return value;
}

- (void)setOrgEndTime:(NSDate *)value
{
    [self willChangeValueForKey:@"orgEndTime"];
    [self setPrimitiveValue:value forKey:@"orgEndTime"];
    [self didChangeValueForKey:@"orgEndTime"];
}
- (NSString *)orgAdminJidStr
{
    [self willAccessValueForKey:@"orgAdminJidStr"];
    NSString *value = [self primitiveValueForKey:@"orgAdminJidStr"];
    [self didAccessValueForKey:@"orgAdminJidStr"];
    
    return value;
}

- (void)setOrgAdminJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"orgAdminJidStr"];
    [self setPrimitiveValue:value forKey:@"orgAdminJidStr"];
    [self didChangeValueForKey:@"orgAdminJidStr"];
}
- (NSString *)orgDescription
{
    [self willAccessValueForKey:@"orgDescription"];
    NSString *value = [self primitiveValueForKey:@"orgDescription"];
    [self didAccessValueForKey:@"orgDescription"];
    
    return value;
}

- (void)setOrgDescription:(NSString *)value
{
    [self willChangeValueForKey:@"orgDescription"];
    [self setPrimitiveValue:value forKey:@"orgDescription"];
    [self didChangeValueForKey:@"orgDescription"];
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

- (NSString *)ptTag
{
    [self willAccessValueForKey:@"ptTag"];
    NSString *value = [self primitiveValueForKey:@"ptTag"];
    [self didAccessValueForKey:@"ptTag"];
    
    return value;
}

- (void)setPtTag:(NSString *)value
{
    [self willChangeValueForKey:@"ptTag"];
    [self setPrimitiveValue:value forKey:@"ptTag"];
    [self didChangeValueForKey:@"ptTag"];
}

- (NSString *)userTag
{
    [self willAccessValueForKey:@"userTag"];
    NSString *value = [self primitiveValueForKey:@"userTag"];
    [self didAccessValueForKey:@"userTag"];
    
    return value;
}

- (void)setUserTag:(NSString *)value
{
    [self willChangeValueForKey:@"userTag"];
    [self setPrimitiveValue:value forKey:@"userTag"];
    [self didChangeValueForKey:@"userTag"];
}

- (NSString *)relationShipTag
{
    [self willAccessValueForKey:@"relationShipTag"];
    NSString *value = [self primitiveValueForKey:@"relationShipTag"];
    [self didAccessValueForKey:@"relationShipTag"];
    
    return value;
}

- (void)setRelationShipTag:(NSString *)value
{
    [self willChangeValueForKey:@"relationShipTag"];
    [self setPrimitiveValue:value forKey:@"relationShipTag"];
    [self didChangeValueForKey:@"relationShipTag"];
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
                         withOrgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"orgId", orgId, @"streamBareJidStr", streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (dic == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
    
    XMPPOrgCoreDataStorageObject *newOrg = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                         inManagedObjectContext:moc];
    
    newOrg.streamBareJidStr = streamBareJidStr;
    
    [newOrg updateWithDic:dic];
    
    return newOrg;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    if (moc == nil) return result;
    if (dic == nil) return result;
    if (streamBareJidStr == nil) return result;
    
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    if (tempOrgId == nil)  return result;

    
    XMPPOrgCoreDataStorageObject *newOrg = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                            withOrgId:tempOrgId
                                                                                     streamBareJidStr:streamBareJidStr];
    if (newOrg != nil) {
        
        [newOrg updateWithDic:dic];
        result = YES;
        
    }else{
        [XMPPOrgCoreDataStorageObject insertInManagedObjectContext:moc
                                                               withDic:dic
                                                      streamBareJidStr:streamBareJidStr];
        result = YES;
    }
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                           withOrgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return NO;
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPOrgCoreDataStorageObject *deleteObject = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                  withOrgId:orgId
                                                                                           streamBareJidStr:streamBareJidStr];
    if (deleteObject){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;

}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    return [XMPPOrgCoreDataStorageObject deleteInManagedObjectContext:moc
                                                            withOrgId:tempOrgId
                                                     streamBareJidStr:streamBareJidStr];
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    NSString *tempOrgName = [dic objectForKey:@"orgName"];
    NSString *temoOrgPhoto = dic[@"orgPhoto"];
    NSNumber *tempOrgState = [NSNumber numberWithInteger:[[dic objectForKey:@"orgState"] integerValue]];
    NSString *tempOrgStartTime = [dic objectForKey:@"orgStartTime"];
    NSString *tempOrgEndTime = [dic objectForKey:@"orgEndTime"];
    NSString *tempOrgAdminJidStr = [dic objectForKey:@"orgAdminJidStr"];
    NSString *tempOrgDescription = [dic objectForKey:@"orgDescription"];
    NSString *tempPtTag = [dic objectForKey:@"ptTag"];
    NSString *tempUserTag = [dic objectForKey:@"userTag"];
    NSString *tempRelationShipTag = [dic objectForKey:@"orgRelationShipTag"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempOrgId) self.orgId = tempOrgId;
    if (tempOrgName) self.orgName = tempOrgName;
    if (temoOrgPhoto) self.orgPhoto = temoOrgPhoto;
    if (tempOrgState) self.orgState = tempOrgState;
    if (tempOrgStartTime) self.orgStartTime = [tempOrgStartTime StringToDate];
    if (tempOrgEndTime) self.orgEndTime = [tempOrgEndTime StringToDate];
    if (tempOrgAdminJidStr) self.orgAdminJidStr = tempOrgAdminJidStr;
    if (tempOrgDescription) self.orgDescription = tempOrgDescription;
    if (tempPtTag) self.ptTag = tempPtTag;
    if (tempUserTag) self.userTag = tempUserTag;
    if (tempRelationShipTag) self.relationShipTag = tempRelationShipTag;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

@end
