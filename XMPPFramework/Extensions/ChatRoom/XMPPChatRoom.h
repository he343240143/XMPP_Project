//
//  XMPPChatRoom.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "JSONKit.h"
#import "XMPPChatRoomCoreDataStorageObject.h"
#import "XMPPChatRoomUserCoreDataStorageObject.h"
#import "XMPPMessage+ChatRoomMessage.h"
#import "NSDictionary+KeysTransfrom.h"


#define _XMPP_CHAT_ROOM_H

@class XMPPIDTracker;
@protocol XMPPChatRoomStorage;
@protocol XMPPChatRoomDelegate;

@protocol XMPPChatRoomCoreDataStorageObject <NSObject>
@end

@protocol XMPPChatRoomUserCoreDataStorageObject <NSObject>
@end

@interface XMPPChatRoom : XMPPModule
{

    /*	Inherited from XMPPModule:
     XMPPStream *xmppStream;
     dispatch_queue_t moduleQueue;
     id multicastDelegate;
     */
    __strong id <XMPPChatRoomStorage> xmppChatRoomStorage;
    
    XMPPIDTracker *xmppIDTracker;
    
    Byte config;
    Byte flags;
}

- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage;
- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

/* Inherited from XMPPModule:
 
 - (BOOL)activate:(XMPPStream *)xmppStream;
 - (void)deactivate;
 
 @property (readonly) XMPPStream *xmppStream;
 
 - (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
 - (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
 - (void)removeDelegate:(id)delegate;
 
 - (NSString *)moduleName;
 
 */

@property (strong, readonly) id <XMPPChatRoomStorage> xmppChatRoomStorage;

/**
 * Whether or not to automatically fetch the Chat room list from the server.
 *
 * The default value is NO.
 **/
@property (assign) BOOL autoFetchChatRoomList;
/**
 *  Whether or not to automatically fetch the Chat room's user list from the server.
 *  The default value is NO.
 */
@property (assign) BOOL autoFetchChatRoomUserList;

/**
 * Whether or not to automatically clear all ChatRooms and Resources when the stream disconnects.
 * If you are using XMPPChatRoomCoreDataStorage you may want to set autoRemovePreviousDatabaseFile to NO.
 *
 * All ChatRooms and Resources will be cleared when the roster is next populated regardless of this property.
 *
 * The default value is YES.
 **/
@property (assign) BOOL autoClearAllChatRoomsAndResources;

@property (assign, getter = hasRequestedChatRoomList, readonly) BOOL requestedChatRoomList;

@property (assign, getter = isPopulating, readonly) BOOL populating;


@property (assign, readonly) BOOL hasChatRoomList;

/**
 *  fetch all the chat room list from the server, 
 *  NOTE:This method is not a method that fetch list from the CoreData system
 */
- (void)fetchChatRoomListFromServer;
/**
 *  fetch the Chat Room From Server With the given bare chat room jid string
 *
 *  @param bareChatRoomJidStr The given bare chat room jid string
 */
- (void)fetchChatRoomFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  Fetch the user list with a given bare chat room jid str
 *
 *  @param bareChatRoomJidStr The given bare chat room jid str
 */
- (void)fetchUserListFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  create room with a nick name
 *
 *  @param room_nickeName the nick name of the room which  will been created
 *
 *  @return YES:if succeed,
 *           NO:other cases
 */
- (BOOL)createChatRoomWithNickName:(NSString *)room_nickeName;
/**
 *  Create a room and invite some user join it
 *
 *  @param userArray     user jid string array
 *  @param room_nickName the nickname of the room you want to create
 *
 *  @return YES,if action finished
 *          NO,Other cases
 */
- (BOOL)inviteUser:(NSArray *)userArray andCreateChatRoomWithNickName:(NSString *)room_nickName;
/**
 *  invite other users to join the chat room
 *
 *  @param userArray user information array，Contains user‘JID mainly
 *          The Array should been a list of jid string array,such as
 *              ["123","456","789",...]
 *  @param roomJID   the chat room jid
 *
 *  @return YES,if succeed
 *           NO,other cases
 */
- (BOOL)inviteUser:(NSArray *)userArray joinChatRoom:(NSString *)roomJIDStr;
/**
 *  Self join a chat room with the given chat room
 *
 *  @param bareJidStr The given chat room bare jid string
 */
- (void)joinChatRoomWithBareJidStr:(NSString *)bareJidStr;
/**
 *  Set the chat room nickname for given nick name and bare jid string
 *
 *  @param nickName     chat room nickname
 *  @param bareJidStr   The chat room's bare jid string
 */
- (void)setChatRoomNickName:(NSString *)nickName forBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  Whether self is the chat room 's master
 *
 *  @param bareChatRoomJidStr The chat room bare jid string
 *
 *  @return YES,if self is the master of the chat room
 *          NO,if not
 */
- (BOOL)isMasterForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  Whether self is a memeber of the chat room
 *
 *  @param chatRoomBareJidStr The chat room bare jid str
 *
 *  @return YES,if is,other is NO
 */
- (BOOL)isSelfAMemberOfChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr;
/**
 *  Whether the user is a member of the given chat room
 *
 *  @param bareJidStr         The user bare jid string
 *  @param bareChatRoomJidStr The bare chat room jid string
 *
 *  @return YES,if it is
 *          NO,other case
 */
- (BOOL)isUserWithBareJidStr:(NSString *)bareJidStr aMemberOfChatRoom:(NSString *)bareChatRoomJidStr;
/**
 *  Whether the chat room is existed with the given bare jid string
 *
 *  @param bareJidStr The given chat room bare jid string
 *
 *  @return YES,if exist,Other case return NO;
 */
- (BOOL)existChatRoomWithBareJidStr:(NSString *)bareJidStr;
/**
 *  Exit from a chat room
 *
 *  @param chatRoomBareJidStr The chat room bare jid string
 */
- (void)exitFromChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr;
/**
 *  Delete a chat room which is created by self
 *
 *  @param bareChatRoomJidStr The chat room bare jid str which will been delete
 */
- (void)deleteChatRoomWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  Set self nick name which will been display in the chat room user list
 *
 *  @param bareChatRoomJidStr The chat room bare jid string
 *  @param newNickName        Your new nick name
 */
- (void)setMyNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr withNickName:(NSString *)newNickName;
/**
 *  Delete some users from the chat room which is created by yourself,
 *  Note.you must been the master of the chat room
 *
 *  @param bareJidStrArray         The user's bare jid string array which will been delete
 *  @param bareChatRoomJidStr The chat room's bare jid string
 */
- (void)DeleteUserWithBareJidStrArray:(NSArray  *)bareJidStrArray fromChatRoomWithBareJidStr:(NSString *)bareChatRoomJidStr;
/**
 *  Get all the list from the local core datasystem
 */
- (NSArray<XMPPChatRoomCoreDataStorageObject> *)fetchChatRoomListFromLocal;
/**
 *  Fetch a chat room's all user with the given chat room bare jid string,
 *
 *
 *  @param bareChatRoomJidStr The given chat room bare jid string
 *  @param requestFromServer  Whether request from the server if there is no data in local
 *                            Note:
 *                                  1.When we set it into "YES",the system will pull the user list from the server when it not exist in loacal
 *                                  2.When we set it into "NO",the system will not pull the user list from the server when it not exist in loacal
 *
 *  @return The result array which contain some XMPPChatRoomUserCoreDataStorageObject obejct in it
 */
- (NSArray<XMPPChatRoomUserCoreDataStorageObject> *)fetchUserListFromLocalWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr requestFromServerIfNotExist:(BOOL)requestFromServer;
/**
 *  Get a XMPPChatRoomCoreDataStorageObject with given bare Jid string and bare Chat Room Jid string
 *
 *  @param bareJidStr The given bare Jid string
 *
 *  @return The XMPPChatRoomCoreDataStorageObject
 */
- (XMPPChatRoomCoreDataStorageObject *)chatRoomWithBareJidStr:(NSString *)bareJidStr;
/**
 *  Get a XMPPChatRoomUserCoreDataStorageObject with given bareChatRoomJidStr and bareJidStr
 *
 *  @param bareChatRoomJidStr The given bareChatRoomJidStr
 *  @param bareJidStr         The given bareJidStr
 *
 *  @return XMPPChatRoomUserCoreDataStorageObject
 */
- (XMPPChatRoomUserCoreDataStorageObject *)userInfoFromChatRoom:(NSString *)bareChatRoomJidStr withBareJidStr:(NSString *)bareJidStr;


#pragma mark - 创建聊天室或者任务或者事件或者文件收发
// 通用创建聊天室方法
- (void)createChatRoomWithName:(NSString *)chatRoomName
                          type:(XMPPChatRoomType)type
                         orgId:(NSString *)orgId
                   bareJidStrs:(NSArray*)bareJidStrs
               completionBlock:(CompletionBlock)completionBlock;

- (void)createChatRoomWithName:(NSString *)chatRoomName
                          type:(XMPPChatRoomType)type
                         orgId:(NSString *)orgId
               completionBlock:(CompletionBlock)completionBlock;
// 创建任务
- (void)createTask:(NSString *)taskName
             orgId:(NSString *)orgId
       bareJidStrs:(NSArray*)bareJidStrs
   completionBlock:(CompletionBlock)completionBlock;

- (void)createTask:(NSString *)taskName
             orgId:(NSString *)orgId
   completionBlock:(CompletionBlock)completionBlock;

// 创建事件
- (void)createEvent:(NSString *)eventName
        bareJidStrs:(NSArray*)bareJidStrs
    completionBlock:(CompletionBlock)completionBlock;

- (void)createEvent:(NSString *)eventName
   completionBlock:(CompletionBlock)completionBlock;

// 资料收发
- (void)createFileTransfer:(NSString *)fileTransferName
                   bareJidStrs:(NSArray*)bareJidStrs
               completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取所有聊天室信息
- (void)fetchAllChatRoomsWithType:(XMPPChatRoomType)type completionBlock:(void(^)(NSArray<XMPPChatRoomCoreDataStorageObject> *data, NSError *error))completionBlock;
- (NSArray<XMPPChatRoomCoreDataStorageObject> *)fetchAllChatRoomsWithType:(XMPPChatRoomType)type;

#pragma mark - 获取所有人员信息


#pragma mark - 指定聊天室信息
- (void)fetchChatRoomFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
                                      completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 指定聊天室人员列表信息
- (void)fetchChatRoomUserListFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
                                              completionBlock:(CompletionBlock)completionBlock;


#pragma mark - 获取聊天室头像
- (NSArray *)jidsWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomStorage <NSObject>

@required

- (BOOL)configureWithParent:(id)aParent queue:(dispatch_queue_t)queue;
- (void)beginChatRoomPopulationForXMPPStream:(XMPPStream *)stream;
- (void)endChatRoomPopulationForXMPPStream:(XMPPStream *)stream;

- (void)handleChatRoomDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;
//- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)stream;

- (BOOL)chatRoomExistsWithID:(NSString *)id xmppStream:(XMPPStream *)stream;
- (BOOL)isMasterForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;
- (BOOL)isMemberOfChatRoomWithBareJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;
- (BOOL)isUserWithBareJidStr:(NSString *)bareJidStr aMemberOfChatRoom:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;
- (BOOL)existChatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream;
- (void)clearAllChatRoomsForXMPPStream:(XMPPStream *)stream;
- (void)clearAllUserForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;

- (NSArray *)idsForXMPPStream:(XMPPStream *)stream;
- (NSArray *)userListForChatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream;
- (NSArray *)chatRoomListWithType:(XMPPChatRoomType)type xmppStream:(XMPPStream *)stream;

- (id)chatRoomWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream;
- (id)userInfoFromChatRoom:(NSString *)bareChatRoomJidStr withBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream;

- (void)InsertOrUpdateChatRoomWith:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;
- (void)deleteChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr xmppStream:(XMPPStream *)stream;
- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr  xmppStream:(XMPPStream *)stream;

- (void)deleteUserWithBareJidStr:(NSString *)bareJidStr fromChatRoomWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr xmppStream:(XMPPStream *)stream;

@optional


#if TARGET_OS_IPHONE
- (void)setPhoto:(UIImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream;
#else
- (void)setPhoto:(NSImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream;
#endif

- (void)handleChatRoomUserDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdateUserWithChatRoomBareJidStr:(NSString *)chatRoomBareJidStr dic:(NSDictionary *)userDic xmppStream:(XMPPStream *)stream;

- (void)insertChatRoomWithDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;
- (void)handleChatRoomUserChatRoomBareJidStr:(NSString *)chatRoomBareJidStr dictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomDelegate <NSObject>

@required

@optional

- (void)xmppChatRoom:(XMPPChatRoom *)sender didCreateChatRoomID:(NSString *)roomID roomNickName:(NSString *)nickname;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didCreateChatRoomError:(NSXMLElement *)errorElement;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didAlterChatRoomNickNameWithID:(NSString *)roomID roomNickName:(NSString *)nickname;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didAlterChatRoomNickNameError:(NSXMLElement *)errorElement;

- (void)xmppChatRoom:(XMPPChatRoom *)sender didDeleteChatRoomError:(NSXMLElement *)errorElement;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didDeleteChatRoomIDWith:(NSString *)roomID;

- (void)xmppChatRoom:(XMPPChatRoom *)sender didInviteFriendError:(NSXMLElement *)errorElement;

- (void)xmppChatRoom:(XMPPChatRoom *)sender willDeleteChatRoomWithBareJidStr:(NSString *)bareJidStr;
/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 **/
- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveChatRoomPush:(XMPPIQ *)iq;

- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveSeiverPush:(XMPPMessage *)message;

/**
 * Sent when the initial roster is received.
 **/
- (void)xmppChatRoomDidBeginPopulating:(XMPPChatRoom *)sender;

/**
 * Sent when the initial roster has been populated into storage.
 **/
- (void)xmppChatRoomDidEndPopulating:(XMPPChatRoom *)sender;

/**
 * Sent when the roster receives a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 **/
- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveChatRoomItem:(NSXMLElement *)item;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didAlterNickName:(NSString *)newNickName withBareJidStr:(NSString *)bareJidStr;


@end

