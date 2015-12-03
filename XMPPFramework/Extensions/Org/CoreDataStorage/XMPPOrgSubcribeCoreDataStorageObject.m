//
//  XMPPOrgSubcribeCoreDataStorageObject.m
//  
//
//  Created by Peter Lee on 15/6/18.
//
//

#import "XMPPOrgSubcribeCoreDataStorageObject.h"
#import "NSString+NSDate.h"


@implementation XMPPOrgSubcribeCoreDataStorageObject

@dynamic formOrgId;
@dynamic fromOrgName;
@dynamic toOrgId;
@dynamic time;
@dynamic message;
@dynamic state;
@dynamic streamBareJidStr;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formOrgId
{
    [self willAccessValueForKey:@"formOrgId"];
    NSString *value = [self primitiveValueForKey:@"formOrgId"];
    [self didAccessValueForKey:@"formOrgId"];
    
    return value;
}

- (void)setFormOrgId:(NSString *)value
{
    [self willChangeValueForKey:@"formOrgId"];
    [self setPrimitiveValue:value forKey:@"formOrgId"];
    [self didChangeValueForKey:@"formOrgId"];
}

- (NSString *)formOrgName
{
    [self willAccessValueForKey:@"formOrgName"];
    NSString *value = [self primitiveValueForKey:@"formOrgName"];
    [self didAccessValueForKey:@"formOrgName"];
    
    return value;
}

- (void)setFromOrgName:(NSString *)value
{
    [self willChangeValueForKey:@"formOrgName"];
    [self setPrimitiveValue:value forKey:@"formOrgName"];
    [self didChangeValueForKey:@"formOrgName"];
}


- (NSString *)toOrgId
{
    [self willAccessValueForKey:@"toOrgId"];
    NSString *value = [self primitiveValueForKey:@"toOrgId"];
    [self didAccessValueForKey:@"toOrgId"];
    
    return value;
}

- (void)setToOrgId:(NSString *)value
{
    [self willChangeValueForKey:@"toOrgId"];
    [self setPrimitiveValue:value forKey:@"toOrgId"];
    [self didChangeValueForKey:@"toOrgId"];
}


- (NSDate *)time
{
    [self willAccessValueForKey:@"time"];
    NSDate *value = [self primitiveValueForKey:@"time"];
    [self didAccessValueForKey:@"time"];
    
    return value;
}

- (void)setTime:(NSDate *)value
{
    [self willChangeValueForKey:@"time"];
    [self setPrimitiveValue:value forKey:@"time"];
    [self didChangeValueForKey:@"time"];
}

- (NSString *)message
{
    [self willAccessValueForKey:@"message"];
    NSString *value = [self primitiveValueForKey:@"message"];
    [self didAccessValueForKey:@"message"];
    
    return value;
}

- (void)setMessage:(NSString *)value
{
    [self willChangeValueForKey:@"formOrgId"];
    [self setPrimitiveValue:value forKey:@"formOrgId"];
    [self didChangeValueForKey:@"formOrgId"];
}


- (NSNumber *)state
{
    [self willAccessValueForKey:@"state"];
    NSNumber *value = [self primitiveValueForKey:@"state"];
    [self didAccessValueForKey:@"state"];
    
    return value;
}

- (void)setState:(NSNumber *)value
{
    [self willChangeValueForKey:@"state"];
    [self setPrimitiveValue:value forKey:@"state"];
    [self didChangeValueForKey:@"state"];
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
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"time"];
    [self setPrimitiveValue:@(XMPPOrgSubcribeStateNotHandle) forKey:@"state"];
}

- (void)awakeFromFetch
{
    // your code here ...
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempFormOrgId = [dic objectForKey:@"formOrgId"];
    NSString *tempFromOrgName = [dic objectForKey:@"fromOrgName"];
    NSNumber *tempState = [NSNumber numberWithInteger:[[dic objectForKey:@"state"] integerValue]];
    NSString *tempTime = [dic objectForKey:@"time"];
    NSString *tempToOrgId = [dic objectForKey:@"toOrgId"];
    NSString *tempMessage = [dic objectForKey:@"message"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempFormOrgId) self.formOrgId = tempFormOrgId;
    if (tempFromOrgName) self.fromOrgName = tempFromOrgName;
    if (tempState) self.state = tempState;
    if (tempTime) self.time = [tempTime StringToDate];
    if (tempToOrgId) self.toOrgId = tempToOrgId;
    if (tempMessage) self.message = tempMessage;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withFormOrgId:(NSString *)formOrgId
                           toOrgId:(NSString *)toOrgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (formOrgId == nil) return nil;
    if (toOrgId == nil) return nil;
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgSubcribeCoreDataStorageObject class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"formOrgId == %@ AND toOrgId == %@ AND streamBareJidStr == %@", formOrgId, toOrgId, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgSubcribeCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return nil;
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgSubcribeCoreDataStorageObject class]);
    
    XMPPOrgSubcribeCoreDataStorageObject *newSubcribe = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                                      inManagedObjectContext:moc];
    
    newSubcribe.streamBareJidStr = streamBareJidStr;
    
    [newSubcribe updateWithDic:dic];
    
    return newSubcribe;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    
    if (dic == nil) return result;
    if (moc == nil) return result;
    if (streamBareJidStr == nil) return result;
    
    NSString *tempFormOrgId = [dic objectForKey:@"formOrgId"];
    NSString *tempToOrgId = [dic objectForKey:@"toOrgId"];
    
    XMPPOrgSubcribeCoreDataStorageObject *subcribe = [XMPPOrgSubcribeCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                          withFormOrgId:tempFormOrgId
                                                                                                                toOrgId:tempToOrgId
                                                                                                       streamBareJidStr:streamBareJidStr];
    if (subcribe) {
        
        [subcribe updateWithDic:dic];
        result = YES;
    }
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                       withFormOrgId:(NSString *)formOrgId
                             toOrgId:(NSString *)toOrgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    
    BOOL result = NO;
    
    if (formOrgId == nil) return result;
    if (toOrgId == nil) return result;
    if (moc == nil) return result;
    if (streamBareJidStr == nil) return result;
    
    XMPPOrgSubcribeCoreDataStorageObject *subcribe = [XMPPOrgSubcribeCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                          withFormOrgId:formOrgId
                                                                                                                toOrgId:toOrgId
                                                                                                       streamBareJidStr:streamBareJidStr];
    
    if (subcribe) {
        
        [moc deleteObject:subcribe];
        
        result = YES;
    }
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *tempFormOrgId = [dic objectForKey:@"formOrgId"];
    NSString *tempToOrgId = [dic objectForKey:@"toOrgId"];
    
    return [XMPPOrgSubcribeCoreDataStorageObject deleteInManagedObjectContext:moc
                                                                withFormOrgId:tempFormOrgId
                                                                      toOrgId:tempToOrgId
                                                             streamBareJidStr:streamBareJidStr];
}

@end
