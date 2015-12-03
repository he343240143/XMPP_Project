//
//  XMPPOrganizationCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "XMPPOrg.h"
#import "XMPPOrgCoreDataStorageObject.h"
#import "XMPPOrgPositionCoreDataStorageObject.h"
#import "XMPPOrgUserCoreDataStorageObject.h"
#import "XMPPOrgSubcribeCoreDataStorageObject.h"
#import "XMPPOrgRelationObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - extension
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPOrgCoreDataStorage ()<XMPPOrgStorage>

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation XMPPOrgCoreDataStorage

static XMPPOrgCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPOrgCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    XMPPLogTrace();
    [super commonInit];
    
    // This method is invoked by all public init methods of the superclass
    autoRemovePreviousDatabaseFile = YES;
    autoRecreateDatabaseFile = YES;
    
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (parentQueue)
        dispatch_release(parentQueue);
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPOrganizationStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)configureWithParent:(XMPPOrg *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

- (void)clearAllOrgWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K != %@",@"streamBareJidStr",streamBareJidStr, @"orgState",@(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgCoreDataStorageObject *org in allOrgs){
            
            [moc deleteObject:org];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}

- (void)clearAllTemplatesWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",streamBareJidStr, @"orgState",@(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgCoreDataStorageObject *org in allOrgs){
            
            [moc deleteObject:org];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}

- (id)allOrgTemplatesWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allTemplates = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"orgStartTime" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",
                         streamBareJidStr, @"orgState", @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            allTemplates = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allTemplates;
}

- (id)allOrgsWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allOrgs = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"orgStartTime" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K != %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgState", @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allOrgs;
}

- (id)orgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
{
    __block id org = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",
                                      streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            org = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        }
    }];
    
    return org;
}

- (id)orgPhotoWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgCoreDataStorageObject *org = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",
                                      streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            org = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        }
    }];
    
    return org.orgPhoto;
}


- (void)clearPositionsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgPositionCoreDataStorageObject *position in allUnusedPositions) {
            
            [moc deleteObject:position];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearPositionsNotInPtIds:(NSArray *)ptIds  orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@ AND NOT(ptId IN %@)",streamBareJidStr,orgId,ptIds];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgPositionCoreDataStorageObject *position in allUnusedPositions) {
            
            [moc deleteObject:position];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearUsersWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND userPtShip.orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUnusedUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearUsersNotInUserJidStrs:(NSArray *)userJidStrs orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND userPtShip.orgId == %@ AND NOT(userJidStr IN %@)",streamBareJidStr,orgId,userJidStrs];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUnusedUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)deleteUserWithUserJidStr:(NSString *)userJidStr orgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND userPtShip.orgId == %@ AND userJidStr == %@",streamBareJidStr,orgId,userJidStr];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)deleteUserWithUserBareJidStrs:(NSArray *)userBareJidStrs fromOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND userPtShip.orgId == %@ AND userJidStr IN %@",streamBareJidStr,orgId,userBareJidStrs];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearRelationsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allRelations = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgRelationObject *relation in allRelations) {
            
            [moc deleteObject:relation];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}


- (id)orgPositionsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allPositions = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"ptLeft" ascending:YES];
        NSArray *sortDescriptors = @[sd1];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orgId == %@ AND streamBareJidStr == %@", orgId, streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
            
            allPositions = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allPositions;
}

- (id)relationOrgWithRelationId:(NSString *)relationId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgRelationObject *relation = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationOrgId == %@ AND orgId == %@ AND streamBareJidStr == %@", relationId,orgId,streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
            
            relation = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        }
    }];
    return relation;
}

- (id)orgDepartmentWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allDepartments = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"ptLeft" ascending:YES];
        NSArray *sortDescriptors = @[sd1];
        
        // init a NSFetchRequest instance
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setResultType:NSDictionaryResultType];
        
        
        NSAttributeDescription *dpNameDescription = [entity.attributesByName objectForKey:@"dpName"];
        
        
        // Get the count of users...
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"ptUserShip"]; // Does not really matter
        NSExpression *ptNameExpression = [NSExpression expressionForFunction: @"count:" arguments: [NSArray arrayWithObject:keyPathExpression]];
        NSExpressionDescription *expressionDescription = [NSExpressionDescription new];
        [expressionDescription setName: @"ptUserCount"];
        [expressionDescription setExpression: ptNameExpression];
        [expressionDescription setExpressionResultType: NSInteger32AttributeType];
        
        [fetchRequest setPropertiesToFetch:@[dpNameDescription,expressionDescription]];
        
        // setting the groupby value
        [fetchRequest setPropertiesToGroupBy:@[dpNameDescription]];
        
        if (streamBareJidStr){

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orgId == %@ AND streamBareJidStr == %@", orgId, streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
            
            allDepartments = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allDepartments;
}

- (id)orgUsersWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr== %@ AND userPtShip.orgId == %@",streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allUsers;
}

- (id)subUsersWithOrgId:(NSString *)orgId superUserBareJidStr:(NSString *)superUserBareJidStr xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        XMPPOrgUserCoreDataStorageObject *superUser = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                               orgId:orgId
                                                                                                          userJidStr:superUserBareJidStr
                                                                                                    streamBareJidStr:streamBareJidStr];
        NSNumber *superLeft = superUser.userPtShip.ptLeft;
        NSNumber *superRight = superUser.userPtShip.ptRight;
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr== %@ AND userPtShip.orgId == %@ AND userPtShip.ptLeft > %@ AND userPtShip.ptRight < %@",streamBareJidStr, orgId,superLeft,superRight];
            
            [fetchRequest setPredicate:predicate];
            
            allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allUsers;
}

- (id)usersInDepartmentWithDpName:(NSString *)dpName orgId:(NSString *)orgId ascending:(BOOL)ascending xmppStream:(XMPPStream *)stream
{
    __block NSMutableArray *allUsers = [NSMutableArray array];
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"userPtShip.ptLeft" ascending:ascending];
        NSArray *sortDescriptors = @[sd1];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND userPtShip.orgId == %@ AND userPtShip.dpName == %@",streamBareJidStr, orgId, dpName];
            
            [fetchRequest setPredicate:predicate];
            
            NSArray *users = [moc executeFetchRequest:fetchRequest error:nil];
            
            [allUsers addObjectsFromArray:users];
        }
    }];
    
    return allUsers;
}

- (id)positionsInDepartmentWithDpName:(NSString *)dpName
                                orgId:(NSString *)orgId
                            ascending:(BOOL)ascending
                           xmppStream:(XMPPStream *)stream
{
    __block NSArray *allPositions = nil;
    
    [self executeBlock:^{
    
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"ptLeft" ascending:ascending];
        NSArray *sortDescriptors = @[sd1];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@ AND dpName == %@",streamBareJidStr, orgId, dpName];
            [fetchRequest setPredicate:predicate];
            
            
            allPositions = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allPositions;
}

- (id)newUsersWithOrgId:(NSString *)orgId userIds:(NSArray *)userIds xmppStream:(XMPPStream *)stream
{
    __block NSArray *newUsers = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userJidStr in %@ AND streamBareJidStr == %@ && userPtShip.orgId == %@",userIds,
                                      streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            newUsers = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return newUsers;
}

- (void)clearOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        [XMPPOrgCoreDataStorageObject deleteInManagedObjectContext:moc
                                                         withOrgId:orgId
                                                  streamBareJidStr:streamBareJidStr];
        
    }];
    
    [self clearUsersWithOrgId:orgId xmppStream:stream];
    [self clearPositionsWithOrgId:orgId xmppStream:stream];
}

- (void)clearOrgsNotInOrgIds:(NSArray *)orgIds isTemplate:(BOOL)isTemplate xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:(isTemplate ? @"NOT(orgId IN %@) AND streamBareJidStr == %@ AND orgState == %@":@"NOT(orgId IN %@) AND streamBareJidStr == %@ AND orgState != %@"), orgIds,
                                      streamBareJidStr, @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            NSArray *deleteOrgs = [moc executeFetchRequest:fetchRequest error:nil];
            
            NSUInteger unsavedCount = [self numberOfUnsavedChanges];
            
            for (XMPPOrgCoreDataStorageObject *org in deleteOrgs){
                
                [moc deleteObject:org];
                
                if (++unsavedCount >= saveThreshold){
                    [self save];
                    unsavedCount = 0;
                }
            }
        }
        
    }];
}

- (void)clearUnusedPositionWithOrgIds:(NSArray *)orgIds xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND NOT(orgId IN %@)",streamBareJidStr,orgIds];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgPositionCoreDataStorageObject *position in allUnusedPositions) {
            
            [moc deleteObject:position];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }

    }];
}

- (void)clearUnusedUserWithOrgIds:(NSArray *)orgIds xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND NOT(userPtShip.orgId IN %@)",streamBareJidStr,orgIds];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUnusedUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)comparePositionInfoWithOrgId:(NSString *)orgId
                         positionTag:(NSString *)positionTag
                          xmppStream:(XMPPStream *)stream
                        refreshBlock:(void (^)(NSString *orgId))refreshBlock
{
    [self scheduleBlock:^{
    
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgCoreDataStorageObject *org = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                             withOrgId:orgId
                                                                                      streamBareJidStr:streamBareJidStr];
        if (org) {
            if (![org.ptTag isEqualToString:positionTag]) {
                
                org.ptTag = positionTag;
                
                if (refreshBlock) {
                    refreshBlock(org.orgId);
                }
            }
        }
    }];
}

- (void)updateUserTagWithOrgId:(NSString *)orgId
                       userTag:(NSString *)userTag
                    xmppStream:(XMPPStream *)stream
                  pullOrgBlock:(void (^)(NSString *orgId))pullOrgBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgCoreDataStorageObject *org = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                             withOrgId:orgId
                                                                                      streamBareJidStr:streamBareJidStr];
        if (org) {
            
            org.userTag = userTag;
            
        }else{
            if (pullOrgBlock) {
                pullOrgBlock(orgId);
            }
        }
    }];
}

- (void)updateRelationShipTagWithOrgId:(NSString *)orgId
                       relationShipTag:(NSString *)relationShipTag
                            xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgCoreDataStorageObject *org = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                             withOrgId:orgId
                                                                                      streamBareJidStr:streamBareJidStr];
        if (org) org.relationShipTag = relationShipTag;
    }];
}

- (void)insertNewCreateOrgnDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *orgId = [dic objectForKey:@"orgId"];
        
        // find the give object info is whether existed
        XMPPOrgCoreDataStorageObject *orgObject = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   withOrgId:orgId
                                                                                            streamBareJidStr:streamBareJidStr];
        
        if (orgObject == nil) {
            
            orgObject = [XMPPOrgCoreDataStorageObject insertInManagedObjectContext:moc
                                                                           withDic:dic
                                                                  streamBareJidStr:streamBareJidStr];
            orgObject.orgAdminJidStr = streamBareJidStr;
            orgObject.orgState = @(XMPPOrgCoreDataStorageObjectStateActive);
            
            if (userBlock) userBlock(orgId);
            if (positionBlock) positionBlock(orgId);
            if (relationBlock) relationBlock(orgId);
            
        }else{
            
            NSString *userTag = [dic objectForKey:@"userTag"];
            NSString *ptTag = [dic objectForKey:@"ptTag"];
            NSString *orgRelationShipTag = [dic objectForKey:@"orgRelationShipTag"];
            
            if (![orgObject.userTag isEqualToString:userTag])
                if (userBlock) userBlock(orgId);
            
            if (![orgObject.ptTag isEqualToString:ptTag])
                if (positionBlock) positionBlock(orgId);
            
            if (![orgObject.relationShipTag isEqualToString:orgRelationShipTag])
                if (relationBlock) relationBlock(orgId);
            
            [orgObject updateWithDic:dic];
            
            orgObject.orgAdminJidStr = streamBareJidStr;
            orgObject.orgState = @(XMPPOrgCoreDataStorageObjectStateActive);
        }
        
    }];
}

- (void)insertOrUpdateOrgInDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream 
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *orgId = [dic objectForKey:@"orgId"];
        
        // find the give object info is whether existed
        XMPPOrgCoreDataStorageObject *orgObject = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   withOrgId:orgId
                                                                                            streamBareJidStr:streamBareJidStr];
        
        if (orgObject == nil) {
            
            orgObject = [XMPPOrgCoreDataStorageObject insertInManagedObjectContext:moc
                                                                           withDic:dic
                                                                  streamBareJidStr:streamBareJidStr];
            
            if (userBlock) userBlock(orgId);
            if (positionBlock) positionBlock(orgId);
            if (relationBlock) relationBlock(orgId);
            
        }else{
            
            NSString *userTag = [dic objectForKey:@"userTag"];
            NSString *ptTag = [dic objectForKey:@"ptTag"];
            NSString *orgRelationShipTag = [dic objectForKey:@"orgRelationShipTag"];
            
            if (![orgObject.userTag isEqualToString:userTag])
                if (userBlock) userBlock(orgId);
            
            if (![orgObject.ptTag isEqualToString:ptTag])
                if (positionBlock) positionBlock(orgId);
            
            if (![orgObject.relationShipTag isEqualToString:orgRelationShipTag])
                if (relationBlock) relationBlock(orgId);
            
            [orgObject updateWithDic:dic];
            
        }
    
    }];

}

- (void)insertOrUpdatePositionInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        
        NSString *ptId = [dic objectForKey:@"ptId"];
        
        // find the give object info is whether existed
        XMPPOrgPositionCoreDataStorageObject *position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                   withPtId:ptId
                                                                                                                      orgId:orgId
                                                                                                           streamBareJidStr:streamBareJidStr];

        if (position == nil) {
            
            position = [XMPPOrgPositionCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                  withDic:dic
                                                                         streamBareJidStr:streamBareJidStr];
        }else{
            
            [position updateWithDic:dic];

        }
        
        position.orgId = orgId;
        
    }];
}
- (void)insertOrUpdateUserInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        // find the give object info is whether existed
        [XMPPOrgUserCoreDataStorageObject updateInManagedObjectContext:moc
                                                               withDic:dic
                                                                 orgId:orgId
                                                      streamBareJidStr:streamBareJidStr];
        
    }];
}
/*
- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgRelationObject *relation = [XMPPOrgRelationObject insertOrUpdateInManagedObjectContext:moc
                                                                                            selfOrgId:orgId
                                                                                              withDic:dic
                                                                                     streamBareJidStr:streamBareJidStr];
        relation.orgId = orgId;
    }];
}
*/
- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId
                                        dic:(NSDictionary *)dic
                                 xmppStream:(XMPPStream *)stream
                                  userBlock:(void (^)(NSString *orgId, NSString *relationOrgId))userBlock
                              positionBlock:(void (^)(NSString *orgId,  NSString *relationOrgId))positionBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *relationOrgId = dic[@"relationOrgId"];
        
        XMPPOrgRelationObject *relation = [XMPPOrgRelationObject objectInManagedObjectContext:moc
                                                                                withSelfOrgId:orgId
                                                                                relationOrgId:relationOrgId
                                                                             streamBareJidStr:streamBareJidStr];
        
        if (relation == nil) {
            
            relation = [XMPPOrgRelationObject insertOrUpdateInManagedObjectContext:moc
                                                                         selfOrgId:orgId
                                                                           withDic:dic
                                                                  streamBareJidStr:streamBareJidStr];
            
            if (userBlock) userBlock(orgId, relationOrgId);
            if (positionBlock) positionBlock(orgId, relationOrgId);

            
        }else{
            
            NSString *userTag = [dic objectForKey:@"relationUserTag"];
            NSString *ptTag = [dic objectForKey:@"relationPtTag"];
            
            if (![relation.relationUserTag isEqualToString:userTag])
                if (userBlock) userBlock(orgId, relation.relationOrgId);
            
            if (![relation.relationPtTag isEqualToString:ptTag])
                if (positionBlock) positionBlock(orgId, relation.relationOrgId);
            
            [relation updateWithDic:dic];
            
        }
        relation.orgId = orgId;
    }];
}

- (id)orgRelationsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allRelations = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            allRelations = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allRelations;
}

- (id)endOrgWithOrgId:(NSString *)orgId orgEndTime:(NSDate *)orgEndTime xmppStream:(XMPPStream *)stream
{
    __block id org = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        // find the give object info is whether existed
        
        XMPPOrgCoreDataStorageObject *_org = [ XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                               withOrgId:orgId
                                                                                        streamBareJidStr:streamBareJidStr];
        
        if (_org) {
            
            _org.orgState = @(XMPPOrgCoreDataStorageObjectStateEnd);
            _org.orgEndTime = orgEndTime;
            org = _org;
        }
        
    }];
    
    return org;
}

- (id)subPositionsWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *subPositions = nil;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        XMPPOrgPositionCoreDataStorageObject *superPosition = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                        withPtId:ptId
                                                                                                                           orgId:orgId
                                                                                                                streamBareJidStr:streamBareJidStr];
        NSNumber *superLeft = superPosition.ptLeft;
        NSNumber *superRight = superPosition.ptRight;
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@ AND ptLeft > %@ AND ptRight < %@",streamBareJidStr,orgId,superLeft,superRight];
            [fetchRequest setPredicate:predicate];
            
        }
        
        subPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
    }];

    return subPositions;
}

- (id)positionWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgPositionCoreDataStorageObject *position = nil;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                             withPtId:ptId
                                                                                orgId:orgId
                                                                     streamBareJidStr:streamBareJidStr];
        
    }];
    
    return position;
}

- (BOOL)existedUserWithBareJidStr:(NSString *)bareJidStr orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block BOOL existed = NO;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgUserCoreDataStorageObject *user = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                          orgId:orgId
                                                                                                     userJidStr:bareJidStr
                                                                                               streamBareJidStr:streamBareJidStr];
        
        if (user) existed = YES;
    }];
    
    return existed;
}

- (BOOL)isAdminWithUser:(NSString *)userBareJidStr orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block BOOL isAndmin = NO;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgCoreDataStorageObject *org = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                             withOrgId:orgId
                                                                                      streamBareJidStr:streamBareJidStr];
        
        if (org && [org.orgAdminJidStr isEqualToString:userBareJidStr]) {
            isAndmin = YES;
        }
    }];
    
    return isAndmin;
}

- (void)insertSubcribeObjectWithDic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        [XMPPOrgSubcribeCoreDataStorageObject insertInManagedObjectContext:moc
                                                                   withDic:dic
                                                          streamBareJidStr:streamBareJidStr];
    }];
}

- (void)updateSubcribeObjectWithDic:(NSDictionary *)dic accept:(BOOL)accept xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *fromOrgId = [dic objectForKey:@"formOrgId"];
        NSString *toOrgId = [dic objectForKey:@"toOrgId"];
        
        XMPPOrgSubcribeCoreDataStorageObject *subcribe = [XMPPOrgSubcribeCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withFormOrgId:fromOrgId
                                                                                                                    toOrgId:toOrgId
                                                                                                           streamBareJidStr:streamBareJidStr];
        if (subcribe) {
            
            subcribe.state = accept ?  @(XMPPOrgSubcribeStateAccept):@(XMPPOrgSubcribeStateRefuse);
        }
    }];
}

- (void)addOrgId:(NSString *)fromOrgId orgName:(NSString *)formOrgName toOrgId:(NSString *)toTogId xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        [XMPPOrgRelationObject insertOrUpdateInManagedObjectContext:moc
                                                          selfOrgId:toTogId
                                                            withDic:@{
                                                                      @"relationOrgId":fromOrgId,
                                                                      @"relationOrgName":formOrgName
                                                                      }
                                                   streamBareJidStr:streamBareJidStr];
    }];
}

- (void)removeOrgId:(NSString *)removeOrgId fromOrgId:(NSString *)fromOrgId xmppStream:(XMPPStream *)stream;
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgRelationObject *relation = [XMPPOrgRelationObject objectInManagedObjectContext:moc
                                                                                withSelfOrgId:fromOrgId
                                                                                relationOrgId:removeOrgId
                                                                             streamBareJidStr:streamBareJidStr];
        if (relation) {
            NSUInteger unsavedCount = [self numberOfUnsavedChanges];
            
            [moc deleteObject:relation];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }

        }
        
    }];
}

@end
