//
//  XMPPCloudCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, XMPPCloudCoreDataStorageObjectFolderType){
    XMPPCloudCoreDataStorageObjectFolderTypeRoot = -1,
    XMPPCloudCoreDataStorageObjectFolderTypePublic,
    XMPPCloudCoreDataStorageObjectFolderTypePublicSub,
    XMPPCloudCoreDataStorageObjectFolderTypePrivate,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateFullShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivatePartShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateSecret
};

@interface XMPPCloudCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * cloudID;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSNumber * download;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * folderType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSNumber * folderOrFileType;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * version_count;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * folderIsMe;
@property (nonatomic, retain) NSNumber * hasBeenDelete;


#pragma mark - 查找
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 更新
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateSpecialInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 新增
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 删除
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;

@end
