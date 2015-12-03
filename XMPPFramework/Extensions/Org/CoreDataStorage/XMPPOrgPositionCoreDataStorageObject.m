//
//  XMPPOrgPositionCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgPositionCoreDataStorageObject.h"
#import "XMPPOrgUserCoreDataStorageObject.h"


@implementation XMPPOrgPositionCoreDataStorageObject

@dynamic ptId;
@dynamic ptName;
@dynamic ptLeft;
@dynamic ptRight;
@dynamic dpId;
@dynamic dpName;
@dynamic orgId;
@dynamic streamBareJidStr;
@dynamic ptUserShip;

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

- (NSString *)ptId
{
    [self willAccessValueForKey:@"ptId"];
    NSString *value = [self primitiveValueForKey:@"ptId"];
    [self didAccessValueForKey:@"ptId"];
    
    return value;
}

- (void)setPtId:(NSString *)value
{
    [self willChangeValueForKey:@"ptId"];
    [self setPrimitiveValue:value forKey:@"ptId"];
    [self didChangeValueForKey:@"ptId"];
}

- (NSString *)ptName
{
    [self willAccessValueForKey:@"ptName"];
    NSString *value = [self primitiveValueForKey:@"ptName"];
    [self didAccessValueForKey:@"ptName"];
    
    return value;
}

- (void)setPtName:(NSString *)value
{
    [self willChangeValueForKey:@"ptName"];
    [self setPrimitiveValue:value forKey:@"ptName"];
    [self didChangeValueForKey:@"ptName"];
}

- (NSNumber *)ptLeft
{
    [self willAccessValueForKey:@"ptLeft"];
    NSNumber *value = [self primitiveValueForKey:@"ptLeft"];
    [self didAccessValueForKey:@"ptLeft"];
    
    return value;
}

- (void)setPtLeft:(NSNumber *)value
{
    [self willChangeValueForKey:@"ptLeft"];
    [self setPrimitiveValue:value forKey:@"ptLeft"];
    [self didChangeValueForKey:@"ptLeft"];
}

- (NSNumber *)ptRight
{
    [self willAccessValueForKey:@"ptRight"];
    NSNumber *value = [self primitiveValueForKey:@"ptRight"];
    [self didAccessValueForKey:@"ptRight"];
    
    return value;
}

- (void)setPtRight:(NSNumber *)value
{
    [self willChangeValueForKey:@"ptRight"];
    [self setPrimitiveValue:value forKey:@"ptRight"];
    [self didChangeValueForKey:@"ptRight"];
}

- (NSString *)dpId
{
    [self willAccessValueForKey:@"dpId"];
    NSString *value = [self primitiveValueForKey:@"dpId"];
    [self didAccessValueForKey:@"dpId"];
    
    return value;
}

- (void)setDpId:(NSString *)value
{
    [self willChangeValueForKey:@"dpId"];
    [self setPrimitiveValue:value forKey:@"dpId"];
    [self didChangeValueForKey:@"dpId"];
}

- (NSString *)dpName
{
    [self willAccessValueForKey:@"dpName"];
    NSString *value = [self primitiveValueForKey:@"dpName"];
    [self didAccessValueForKey:@"dpName"];
    
    return value;
}

- (void)setDpName:(NSString *)value
{
    [self willChangeValueForKey:@"dpName"];
    [self setPrimitiveValue:value forKey:@"dpName"];
    [self didChangeValueForKey:@"dpName"];
}
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
                          withPtId:(NSString *)ptId
                             orgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (ptId == nil) return nil;
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgPositionCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ptId == %@ AND streamBareJidStr == %@ AND orgId == %@", ptId, streamBareJidStr, orgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    
    return (XMPPOrgPositionCoreDataStorageObject *)[results lastObject];
}


+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    
    if (moc == nil) return nil;
    if (dic == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    
    XMPPOrgPositionCoreDataStorageObject *newPosition;
    newPosition = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPOrgPositionCoreDataStorageObject"
                                            inManagedObjectContext:moc];
    
    newPosition.streamBareJidStr = streamBareJidStr;
    
    [newPosition updateWithDic:dic];
    
    return newPosition;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    
    NSString *tempPtId = [dic objectForKey:@"ptId"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    if (tempPtId == nil)  return result;
    if (tempOrgId == nil)  return result;
    if (moc == nil)  return result;
    
    XMPPOrgPositionCoreDataStorageObject *position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withPtId:tempPtId
                                                                                                                 orgId:tempOrgId
                                                                                                      streamBareJidStr:streamBareJidStr];
    if (position != nil) {
        
        [position updateWithDic:dic];
        result = YES;
        
    }else{
        
        position = [XMPPOrgPositionCoreDataStorageObject insertInManagedObjectContext:moc
                                                                              withDic:dic
                                                                     streamBareJidStr:streamBareJidStr];
        result = YES;
    }
    
    position.orgId = tempOrgId;
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                            withPtId:(NSString *)ptId
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (ptId == nil) return NO;
    if (orgId == nil) return NO;
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPOrgPositionCoreDataStorageObject *deleteObject = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                   withPtId:ptId
                                                                                                                      orgId:orgId
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
    
    NSString *tempPtId = [dic objectForKey:@"ptId"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    return [XMPPOrgPositionCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                     withPtId:tempPtId
                                                                        orgId:tempOrgId
                                                             streamBareJidStr:streamBareJidStr];
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempPtId = [dic objectForKey:@"ptId"];
    NSString *tempPtName = [dic objectForKey:@"ptName"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    NSNumber *tempPtLeft = [NSNumber numberWithInteger:[[dic objectForKey:@"ptLeft"] integerValue]];
    NSNumber *tempPtRight = [NSNumber numberWithInteger:[[dic objectForKey:@"ptRight"] integerValue]];
    NSString *tempDpId = [dic objectForKey:@"dpId"];
    NSString *tempDpName = [dic objectForKey:@"dpName"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempPtId) self.ptId = tempPtId;
    if (tempPtName) self.ptName = tempPtName;
    if (tempOrgId) self.orgId = tempOrgId;
    if ([tempPtLeft integerValue] > 0) self.ptLeft = tempPtLeft;
    if ([tempPtRight integerValue] > 0) self.ptRight = tempPtRight;
    if (tempDpId) self.dpId = tempDpId;
    if (tempDpName) self.dpName = tempDpName;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

@end
