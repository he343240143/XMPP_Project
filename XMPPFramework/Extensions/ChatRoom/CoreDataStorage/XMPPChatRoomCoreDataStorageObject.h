//
//  XMPPChatRoomCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/25.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, XMPPChatRoomType) {
    XMPPChatRoomTypeDefault = 0,
    XMPPChatRoomTypeWork,
    XMPPChatRoomTypeEvent,
    XMPPChatRoomTypeFileTransfer
};

typedef NS_ENUM(NSUInteger, XMPPChatRoomProgressType) {
    XMPPChatRoomProgressTypeDuring,
    XMPPChatRoomProgressTypeEnd
};

@interface XMPPChatRoomCoreDataStorageObject : NSManagedObject
{
    NSString * jid;
    NSString * nickName;
    NSString  * photo;
    NSString * streamBareJidStr;
    NSString * subscription;
    NSString * masterBareJidStr;
    
    NSNumber * type;
    NSNumber * progressType;
    NSDate * startTime;
    NSDate * endTime;
}
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * masterBareJidStr;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSString * subscription;

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * progressType;
@property (nonatomic, retain) NSString * orgId;
/**
 *  Insert a new XMPPChatRoomCoreDataStorageObject into the CoraData System
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The id of chatroom
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withID:(NSString *)chatRoomId
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Insert a new XMPPChatRoomCoreDataStorageObject into the CoraData System
 *  with the info Dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withNSDictionary:(NSDictionary *)Dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Delete the chat room info Which jid is equal to the given id
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                            withID:(NSString *)chatRoomId
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Delete the chat room info Which info  is equal to the given info dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                  withNSDictionary:(NSDictionary *)Dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the chat room info Which info is equal to the given info dictionary
 *  If the chat room is not is not existed, do nothing
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                    withNSDictionary:(NSDictionary *)Dic
                    streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the chat room info Which info is equal to the given info dictionary
 *  If the chat room is not is not existed, We will insert the new object into
 *  the CoreData syetem
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for other cases
 */
+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                  withNSDictionary:(NSDictionary *)Dic
                                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Fetch the chat room info from the CoreData system with room's jid
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return Fetched object,if succeed,nil for other cases
 */
+ (id)fetchObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 withID:(NSString *)chatRoomId
                       streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Fetch the XMPPChatRoomCoreDataStorageObject object from the CoreData system with room's jid
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return XMPPChatRoomCoreDataStorageObject object,if succeed,nil for other cases
 */
+ (XMPPChatRoomCoreDataStorageObject *)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                                                             withID:(NSString *)chatRoomId
                                                   streamBareJidStr:(NSString *)streamBareJidStr;

/**
 *  Update a XMPPChatRoomCoreDataStorageObject object with the chat room info dictionary
 *
 *  @param Dic The given dictionary
 */
- (void)updateWithDictionary:(NSDictionary *)Dic;
/**
 *  Compare two XMPPChatRoomCoreDataStorageObject object
 *
 *  @param another Another XMPPChatRoomCoreDataStorageObject object
 *
 *  @return Compare result
 */
- (NSComparisonResult)compareByName:(XMPPChatRoomCoreDataStorageObject *)another;
- (NSComparisonResult)compareByName:(XMPPChatRoomCoreDataStorageObject *)another options:(NSStringCompareOptions)mask;

/*
- (NSComparisonResult)compareByAvailabilityName:(XMPPChatRoomCoreDataStorageObject *)another;
- (NSComparisonResult)compareByAvailabilityName:(XMPPChatRoomCoreDataStorageObject *)another
                                        options:(NSStringCompareOptions)mask;
 */


@end
