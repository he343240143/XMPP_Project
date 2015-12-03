//
//  XMPPRosterVersionCoreDataStorageObject.h
//  
//
//  Created by Peter Lee on 15/8/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPP.h"


@interface XMPPRosterVersionCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * streamBareJidStr;

+ (id)versionInManagedObjectContext:(NSManagedObjectContext *)moc
                   streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           version:(NSString *)version
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                     version:(NSString *)version
                            streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                    streamBareJidStr:(NSString *)streamBareJidStr;

@end
