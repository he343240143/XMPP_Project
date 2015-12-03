//
//  XMPPRosterVersionCoreDataStorageObject.m
//  
//
//  Created by Peter Lee on 15/8/3.
//
//

#import "XMPPRosterVersionCoreDataStorageObject.h"


@implementation XMPPRosterVersionCoreDataStorageObject

@dynamic version;
@dynamic streamBareJidStr;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)version
{
    [self willAccessValueForKey:@"version"];
    NSString *value = [self primitiveValueForKey:@"version"];
    [self didAccessValueForKey:@"version"];
    
    return value;
}

- (void)setVersion:(NSString *)value
{
    [self willChangeValueForKey:@"version"];
    [self setPrimitiveValue:value forKey:@"version"];
    [self didChangeValueForKey:@"version"];
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
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPRosterVersionCoreDataStorageObject class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPRosterVersionCoreDataStorageObject *)[results lastObject];
}

+ (id)versionInManagedObjectContext:(NSManagedObjectContext *)moc
                   streamBareJidStr:(NSString *)streamBareJidStr
{
    return [[XMPPRosterVersionCoreDataStorageObject objectInManagedObjectContext:moc streamBareJidStr:streamBareJidStr] valueForKeyPath:@"version"];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           version:(NSString *)version
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPRosterVersionCoreDataStorageObject class]);
    
    XMPPRosterVersionCoreDataStorageObject *newVersion = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                                       inManagedObjectContext:moc];
    
    newVersion.streamBareJidStr = streamBareJidStr;
    
    newVersion.version = version;
    
    return newVersion;
}

+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                     version:(NSString *)version
                            streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    
    XMPPRosterVersionCoreDataStorageObject *rosterVersion = [XMPPRosterVersionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                streamBareJidStr:streamBareJidStr];
    if (rosterVersion == nil) {
        rosterVersion = [XMPPRosterVersionCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                     version:version
                                                                            streamBareJidStr:streamBareJidStr];
        result = YES;
        
    }else{
        rosterVersion.version = version;
        result = YES;
    }
    
    return  result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPRosterVersionCoreDataStorageObject *rosterVersion = [XMPPRosterVersionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                streamBareJidStr:streamBareJidStr];
    if (rosterVersion){
        
        [moc deleteObject:rosterVersion];
        return YES;
    }
    
    return NO;
}

@end
