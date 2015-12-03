//
//  XMPPChatRoomUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/4.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPChatRoomUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * chatRoomBareJidStr;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * streamBareJidStr;
/**
 *  Insert a new XMPPChatRoomUserCoreDataStorageObject into the CoraData System
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The id of user
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                            withID:(NSString *)id
                            chatRoomJid:(NSString*)roomJid
streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Insert a new XMPPChatRoomUserCoreDataStorageObject into the CoraData System
 *  with the info Dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the user
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withNSDictionary:(NSDictionary *)Dic
                  chatRoomJid:(NSString*)roomJid
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
                              withID:(NSString *)id
                              chatRoomJid:(NSString*)roomJid
                              streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Delete the user info Which info  is equal to the given info dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the user
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                    withNSDictionary:(NSDictionary *)Dic
                    chatRoomJid:(NSString*)roomJid
                    streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the user info Which info is equal to the given info dictionary
 *  If the useris not is not existed, do nothing
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                    withNSDictionary:(NSDictionary *)Dic
                    chatRoomJid:(NSString*)roomJid
                    streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the user info Which info is equal to the given info dictionary
 *  If the user is not is not existed, We will insert the new object into
 *  the CoreData syetem
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the user
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for other cases
 */
+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                  withNSDictionary:(NSDictionary *)Dic
                                  chatRoomJid:(NSString*)roomJid
                                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Fetch the user info from the CoreData system with user's jid
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return Fetched object,if succeed,nil for other cases
 */
+ (id)fetchObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 withBareJidStr:(NSString *)bareJidStr
                                 chatRoomJid:(NSString*)roomJid
                               streamBareJidStr:(NSString *)streamBareJidStr;

+ (XMPPChatRoomUserCoreDataStorageObject *)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                                                         withBareJidStr:(NSString *)bareJidStr
                                                         chatRoomJid:(NSString*)roomJid
                                                       streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDictionary:(NSDictionary *)Dic;

@end
