//
//  XMPPCloudCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloudCoreDataStorageObject.h"
#import "NSString+NSDate.h"


@implementation XMPPCloudCoreDataStorageObject

@dynamic cloudID;
@dynamic createTime;
@dynamic creator;
@dynamic download;
@dynamic uuid;
@dynamic folderType;
@dynamic name;
@dynamic owner;
@dynamic parent;
@dynamic project;
@dynamic size;
@dynamic folderOrFileType;
@dynamic updateTime;
@dynamic version_count;
@dynamic streamBareJidStr;
@dynamic folderIsMe;
@dynamic hasBeenDelete;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//- (NSMutableDictionary *)propertyTransformDictionary
//{
//    NSMutableDictionary *keysMapDic = [super propertyTransformDictionary];
//    return keysMapDic;
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cloudID
{
    [self willAccessValueForKey:@"cloudID"];
    NSString *value = [self primitiveValueForKey:@"cloudID"];
    [self didAccessValueForKey:@"cloudID"];
    return value;
}
- (void)setCloudID:(NSString *)value
{
    [self willChangeValueForKey:@"cloudID"];
    [self setPrimitiveValue:value forKey:@"cloudID"];
    [self didChangeValueForKey:@"cloudID"];
}

- (NSDate *)createTime
{
    [self willAccessValueForKey:@"createTime"];
    NSDate *value = [self primitiveValueForKey:@"createTime"];
    [self didAccessValueForKey:@"createTime"];
    return value;
}
- (void)setCreateTime:(NSDate *)value
{
    [self willChangeValueForKey:@"createTime"];
    [self setPrimitiveValue:value forKey:@"createTime"];
    [self didChangeValueForKey:@"createTime"];
}


- (NSString *)creator
{
    [self willAccessValueForKey:@"creator"];
    NSString *value = [self primitiveValueForKey:@"creator"];
    [self didAccessValueForKey:@"creator"];
    return value;
}
- (void)setCreator:(NSString *)value
{
    [self willChangeValueForKey:@"creator"];
    [self setPrimitiveValue:value forKey:@"creator"];
    [self didChangeValueForKey:@"creator"];
}


- (NSNumber *)folderType
{
    [self willAccessValueForKey:@"folderType"];
    NSNumber *value = [self primitiveValueForKey:@"folderType"];
    [self didAccessValueForKey:@"folderType"];
    return value;
}
- (void)setFolderType:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderType"];
    [self setPrimitiveValue:value forKey:@"folderType"];
    [self didChangeValueForKey:@"folderType"];
}

- (NSString *)name
{
    [self willAccessValueForKey:@"name"];
    NSString *value = [self primitiveValueForKey:@"name"];
    [self didAccessValueForKey:@"name"];
    return value;
}
- (void)setName:(NSString *)value
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:value forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (NSString *)owner
{
    [self willAccessValueForKey:@"owner"];
    NSString *value = [self primitiveValueForKey:@"owner"];
    [self didAccessValueForKey:@"owner"];
    return value;
}
- (void)setOwner:(NSString *)value
{
    [self willChangeValueForKey:@"owner"];
    [self setPrimitiveValue:value forKey:@"owner"];
    [self didChangeValueForKey:@"owner"];
}

- (NSNumber *)parent
{
    [self willAccessValueForKey:@"parent"];
    NSNumber *value = [self primitiveValueForKey:@"parent"];
    [self didAccessValueForKey:@"parent"];
    return value;
}
- (void)setParent:(NSNumber *)value
{
    [self willChangeValueForKey:@"parent"];
    [self setPrimitiveValue:value forKey:@"parent"];
    [self didChangeValueForKey:@"parent"];
}

- (NSString *)project
{
    [self willAccessValueForKey:@"project"];
    NSString *value = [self primitiveValueForKey:@"project"];
    [self didAccessValueForKey:@"project"];
    return value;
}
- (void)setProject:(NSString *)value
{
    [self willChangeValueForKey:@"project"];
    [self setPrimitiveValue:value forKey:@"project"];
    [self didChangeValueForKey:@"project"];
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

- (NSNumber *)folderOrFileType
{
    [self willAccessValueForKey:@"folderOrFileType"];
    NSNumber *value = [self primitiveValueForKey:@"folderOrFileType"];
    [self didAccessValueForKey:@"folderOrFileType"];
    return value;
}
- (void)setFolderOrFileType:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderOrFileType"];
    [self setPrimitiveValue:value forKey:@"folderOrFileType"];
    [self didChangeValueForKey:@"folderOrFileType"];
}

- (NSNumber *)folderIsMe
{
    [self willAccessValueForKey:@"folderIsMe"];
    NSNumber *value = [self primitiveValueForKey:@"folderIsMe"];
    [self didAccessValueForKey:@"folderIsMe"];
    return value;
}
- (void)setFolderIsMe:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderIsMe"];
    [self setPrimitiveValue:value forKey:@"folderIsMe"];
    [self didChangeValueForKey:@"folderIsMe"];
}

- (NSString *)fileID
{
    [self willAccessValueForKey:@"fileID"];
    NSString *value = [self primitiveValueForKey:@"fileID"];
    [self didAccessValueForKey:@"fileID"];
    return value;
}
- (void)setFileID:(NSString *)value
{
    [self willChangeValueForKey:@"fileID"];
    [self setPrimitiveValue:value forKey:@"fileID"];
    [self didChangeValueForKey:@"fileID"];
}

- (NSString *)size
{
    [self willAccessValueForKey:@"size"];
    NSString *value = [self primitiveValueForKey:@"size"];
    [self didAccessValueForKey:@"size"];
    return value;
}
- (void)setSize:(NSString *)value
{
    [self willChangeValueForKey:@"size"];
    [self setPrimitiveValue:value forKey:@"size"];
    [self didChangeValueForKey:@"size"];
}

- (NSString *)uuid
{
    [self willAccessValueForKey:@"uuid"];
    NSString *value = [self primitiveValueForKey:@"uuid"];
    [self didAccessValueForKey:@"uuid"];
    return value;
}
- (void)setUuid:(NSString *)value
{
    [self willChangeValueForKey:@"uuid"];
    [self setPrimitiveValue:value forKey:@"uuid"];
    [self didChangeValueForKey:@"uuid"];
}

- (NSString *)version_count
{
    [self willAccessValueForKey:@"version_count"];
    NSString *value = [self primitiveValueForKey:@"version_count"];
    [self didAccessValueForKey:@"version_count"];
    return value;
}
- (void)setVersion_count:(NSString *)value
{
    [self willChangeValueForKey:@"version_count"];
    [self setPrimitiveValue:value forKey:@"version_count"];
    [self didChangeValueForKey:@"version_count"];
}


- (NSNumber *)hasBeenDelete
{
    [self willAccessValueForKey:@"hasBeenDelete"];
    NSNumber *value = [self primitiveValueForKey:@"hasBeenDelete"];
    [self didAccessValueForKey:@"hasBeenDelete"];
    return value;
}
- (void)setHasBeenDelete:(NSNumber *)value
{
    [self willChangeValueForKey:@"hasBeenDelete"];
    [self setPrimitiveValue:value forKey:@"hasBeenDelete"];
    [self didChangeValueForKey:@"hasBeenDelete"];
}


//- (NSNumber *)download
//{
//    [self willAccessValueForKey:@"download"];
//    NSNumber *value = [self primitiveValueForKey:@"download"];
//    [self didAccessValueForKey:@"download"];
//    return value;
//}
//- (void)setDownload:(NSString *)value
//{
//    [self willChangeValueForKey:@"download"];
//    [self setPrimitiveValue:value forKey:@"download"];
//    [self didChangeValueForKey:@"download"];
//}
//
//- (NSDate *)updateTime
//{
//    [self willAccessValueForKey:@"updateTime"];
//    NSDate *value = [self primitiveValueForKey:@"updateTime"];
//    [self didAccessValueForKey:@"updateTime"];
//    return value;
//}
//- (void)setUpdateTime:(NSString *)value
//{
//    [self willChangeValueForKey:@"updateTime"];
//    [self setPrimitiveValue:value forKey:@"updateTime"];
//    [self didChangeValueForKey:@"updateTime"];
//}
//
//



- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 查找
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND cloudID == %@", streamBareJidStr, cloudID];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    return (XMPPCloudCoreDataStorageObject *)[results firstObject];
}

#pragma mark - 特殊情况 -- 有了自己的私人文件夹要删除掉之前所有的假的文件夹
+ (BOOL)deleteOriginalPrivateFolderObjectInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    NSString *name = [dic objectForKey:@"name"];
    NSString *cloudID = [dic objectForKey:@"id"];
    NSString *project = [dic objectForKey:@"project"];
    if (!name) return result;
    if (!cloudID) return result;
    if (!project) return result;
    
    // 自己的创建的 name 和 空id
    NSString *original_name = @"工作";
    NSString *original_cloudID = @"";
    
    // 找到自己创建的私人文件夹 (还有其他人的)
    if ([name isEqualToString:@""] && ![cloudID isEqualToString:original_cloudID]) {
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND cloudID == %@ AND name == %@", streamBareJidStr, project, original_cloudID, original_name];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setIncludesPendingChanges:YES];
        [fetchRequest setFetchLimit:1];
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        
        for ( XMPPCloudCoreDataStorageObject *cloud in results ) {
            [XMPPCloudCoreDataStorageObject deleteInManagedObjectContext:moc cloudID:cloud.cloudID streamBareJidStr:streamBareJidStr];
        }
        result = YES;
    }
    return result;
}

#pragma mark - 更新
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    NSString *cloudID = [dic objectForKey:@"id"];
    NSString *parent = [dic objectForKey:@"parent"];
    NSNumber *type = [dic objectForKey:@"type"];
    if (!cloudID) return result;
    if (!parent) return result;
    
    // 有了自己的私人文件夹 删除以前自己创建的私人文件夹
    if ( [parent isEqualToString:@"-1"] && (type.integerValue == 2) ) {
        result = [XMPPCloudCoreDataStorageObject deleteOriginalPrivateFolderObjectInManagedObjectContext:moc dic:dic streamBareJidStr:streamBareJidStr];
    }
    
    
    XMPPCloudCoreDataStorageObject *newCloud = [XMPPCloudCoreDataStorageObject objectInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    if (newCloud) {
        [newCloud updateWithDic:dic];
        result = YES;
    } else {
        XMPPCloudCoreDataStorageObject *newCloud = [XMPPCloudCoreDataStorageObject insertInManagedObjectContext:moc dic:dic streamBareJidStr:streamBareJidStr];
        if (newCloud) result = YES;
    }
    return result;
}

+ (BOOL)updateSpecialInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    NSString *cloudID = [dic objectForKey:@"id"];
    if (!cloudID) return result;
    
    XMPPCloudCoreDataStorageObject *newCloud = [XMPPCloudCoreDataStorageObject objectInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    if (newCloud) {
        for ( NSString *key in dic.allKeys ) {
            if ([key isEqualToString:@"type"]) {
                NSNumber *tempFolderType = [NSNumber numberWithInteger:[[dic objectForKey:key] integerValue]];
                newCloud.folderType = tempFolderType;
            } else if ([key isEqualToString:@"name"]) {
                NSString *tempName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
                newCloud.name = tempName;
            } else if ([key isEqualToString:@"dest_parent"]) {
                NSNumber *tempParent = [NSNumber numberWithInteger:[[dic objectForKey:@"dest_parent"] integerValue]];
                newCloud.parent = tempParent;
            } else if ([key isEqualToString:@"hasBeenDelete"]) {
                NSNumber *tempHasBeenDelete = [NSNumber numberWithInteger:[[dic objectForKey:@"hasBeenDelete"] integerValue]];
                newCloud.hasBeenDelete = tempHasBeenDelete;
            }
        }
        result = YES;
    } else {
        XMPPCloudCoreDataStorageObject *newCloud = [XMPPCloudCoreDataStorageObject insertInManagedObjectContext:moc dic:dic streamBareJidStr:streamBareJidStr];
        if (newCloud) result = YES;
    }
    return result;
}

#pragma mark - 新增
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
    XMPPCloudCoreDataStorageObject *newCloud = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    newCloud.streamBareJidStr = streamBareJidStr;
    [newCloud updateWithDic:dic];
    return newCloud;
}


#pragma mark - 删除
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr
{
    XMPPCloudCoreDataStorageObject *deleteObject = [XMPPCloudCoreDataStorageObject objectInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    if (deleteObject) {
        [moc deleteObject:deleteObject];
        return YES;
    }
    return NO;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempCloudID = [dic objectForKey:@"id"];
    NSString *tempCreateTime = [NSString stringWithFormat:@"%@", [dic objectForKey:@"Time"]];
    NSString *tempCreator = [dic objectForKey:@"creator"];
    NSNumber *tempFolderType = [NSNumber numberWithInteger:[[dic objectForKey:@"type"] integerValue]];
    NSString *tempName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
    NSString *tempOwner = [dic objectForKey:@"owner"];
    NSNumber *tempParent = [NSNumber numberWithInteger:[[dic objectForKey:@"parent"] integerValue]];
    NSString *tempProject = [dic objectForKey:@"project"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    NSNumber *tempFolderOrFileType = [NSNumber numberWithInteger:[[dic objectForKey:@"folderOrFileType"] integerValue]];
    NSNumber *tempFolderIsMe = [NSNumber numberWithInteger:[[dic objectForKey:@"folderIsMe"] integerValue]];
    NSString *tempUuid = [dic objectForKey:@"uuid"];
    NSString *tempSize = [dic objectForKey:@"size"];
    NSString *tempVersion_count = [dic objectForKey:@"version_count"];
    NSNumber *tempHasBeenDelete = [dic objectForKey:@"hasBeenDelete"];
    
    //    NSString *tempUpdateTime = [dic objectForKey:@"updateTime"];
    //    NSNumber *tempDownload = [NSNumber numberWithInteger:[[dic objectForKey:@"download"] boolValue]];
    
    
    if (tempCloudID)            self.cloudID = tempCloudID;
    if (tempCreateTime)         self.createTime = [tempCreateTime StringToDate];
    if (tempCreator)            self.creator = tempCreator;
    if (tempFolderType)         self.folderType = tempFolderType;
    if (tempName)               self.name = tempName;
    if (tempOwner)              self.owner = tempOwner;
    if (tempParent)             self.parent = tempParent;
    if (tempProject)            self.project = tempProject;
    if (tempStreamBareJidStr)   self.streamBareJidStr = tempStreamBareJidStr;
    if (tempFolderOrFileType)   self.folderOrFileType = tempFolderOrFileType;
    if (tempFolderIsMe)         self.folderIsMe = tempFolderIsMe;
    if (tempUuid)               self.uuid = tempUuid;
    if (tempSize)               self.size = tempSize;
    if (tempVersion_count)      self.version_count = tempVersion_count;
    if (tempHasBeenDelete)      self.hasBeenDelete = tempHasBeenDelete;
    
    //    if (tempDownload)           self.download = tempDownload;
    //    if (tempUpdateTime)         self.updateTime = [tempUpdateTime StringToDate];
}

@end
