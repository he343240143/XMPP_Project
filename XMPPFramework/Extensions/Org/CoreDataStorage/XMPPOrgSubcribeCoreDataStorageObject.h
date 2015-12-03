//
//  XMPPOrgSubcribeCoreDataStorageObject.h
//  
//
//  Created by Peter Lee on 15/6/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, XMPPOrgSubcribeState) {
    XMPPOrgSubcribeStateNotHandle = 0,
    XMPPOrgSubcribeStateAccept,
    XMPPOrgSubcribeStateRefuse
};

@interface XMPPOrgSubcribeCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * formOrgId;
@property (nonatomic, retain) NSString * fromOrgName;
@property (nonatomic, retain) NSString * toOrgId;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * streamBareJidStr;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withFormOrgId:(NSString *)formOrgId
                           toOrgId:(NSString *)toOrgId
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                       withFormOrgId:(NSString *)formOrgId
                             toOrgId:(NSString *)toOrgId
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDic:(NSDictionary *)dic;

@end
