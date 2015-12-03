//
//  XMPPChatMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "XMPPMessage.h"
#import "XMPPBaseMessageObject.h"
#import "XMPPAdditionalCoreDataMessageObject.h"
#import "XMPPMessageCoreDataStorageObject.h"

#import "XMPPAudioMessageObject.h"
#import "XMPPTextMessageObject.h"
#import "XMPPVideoMessageObject.h"
#import "XMPPPictureMessageObject.h"
#import "XMPPLocationMessageObject.h"


#define XMPP_MESSAGE_EXTEND                     @"ExtendMessage"

#define MESSAGE_ELEMENT_NAME                    @"info"
#define MESSAGE_ELEMENT_XMLNS                   @"aft:message"

/**
 *  The type of a message
 */
typedef NS_ENUM(NSUInteger, XMPPExtendMessageType){
    /**
     *  The default message is a text message
     */
    XMPPExtendMessageTextType = 0,
    /**
     *  a voice message
     */
    XMPPExtendMessageAudioType,
    /**
     *  a video file message
     */
    XMPPExtendMessageVideoType,
    /**
     *  a picture file message
     */
    XMPPExtendMessagePictureType,
    /**
     *  a Positio information message
     */
    XMPPExtendMessagePositionType,
    /**
     *  a control message to control the speak
     */
    XMPPExtendMessageControlType,
    /**
     *  a request message to request for media chat
     */
    XMPPExtendMessageMediaRequestType
};

typedef NS_ENUM(NSInteger, XMPPMessageSendStatusType)
{
    XMPPMessageSendFailedType = -1,
    XMPPMessageSendingType = 0,
    XMPPMessageSendSucceedType = 1
};

@interface XMPPExtendMessageObject : XMPPBaseMessageObject

@property (assign, nonatomic) NSUInteger                        messageType;      //The message type
@property (strong, nonatomic) NSString                          *messageID;       //message ID,used to find the appointed message
@property (strong, nonatomic) NSString                          *fromUser;        //The user id of Who send the message
@property (strong, nonatomic) NSString                          *toUser;          //The user id of who the message will been send to
@property (strong, nonatomic) NSDate                            *messageTime;     //The message send time,this message is a local time

@property (assign, nonatomic) NSInteger                         hasBeenRead;      //The mark to  distinguish whether the message has been read
@property (assign, nonatomic) BOOL                              isGroupChat;      //Mark value 4,Wether is a chat room chat
@property (assign, nonatomic) BOOL                              sendFromMe;       //Whether the message is send from myself
@property (strong, nonatomic) NSString                          *sender;          //The user in the chat room who sender this message

@property (strong, nonatomic) XMPPTextMessageObject             *text;            //The text object which has all the text info
@property (strong, nonatomic) XMPPAudioMessageObject            *audio;           //The audio object which has all the audio info
@property (strong, nonatomic) XMPPVideoMessageObject            *video;           //The video object which has all the audio info
@property (strong, nonatomic) XMPPPictureMessageObject          *picture;         //The picture object which has all the audio info
@property (strong, nonatomic) XMPPLocationMessageObject         *location;        //The location object which has all the audio info


+ (XMPPExtendMessageObject *)xmppExtendMessageObject;
+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromXMPPMessage:(XMPPMessage *)message;
+ (XMPPExtendMessageObject *)xmppExtendMessageObjectCopyFromMessage:(XMPPMessage *)message;
+ (XMPPExtendMessageObject *)xmppExtendMessageObjectWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;

- (instancetype)init;
- (instancetype)initWithType:(XMPPExtendMessageType)messageType;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)message;
- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary;
- (instancetype)initWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)message  sendFromMe:(BOOL)sendFromMe hasBeenRead:(BOOL)hasBeenRead;

- (instancetype)initWithFromUser:(NSString *)fromUser
                          toUser:(NSString *)toUser
                            type:(XMPPExtendMessageType)type
                      sendFromMe:(BOOL)sendFromMe
                     hasBeenRead:(NSInteger)hasBeenRead
                       groupChat:(BOOL)groupChat
                          sender:(NSString *)sender
                            time:(NSDate *)time
                       subObject:(id)subObject;

/**
 *  Create the message id,we must do this before send this message
 */
- (void)createMessageID;
/**
 *  Get a XMPPMessage from the XMPPChatMessageObject
 *
 *  @return The XMPPMessage element we will get
 */
- (XMPPMessage *)toXMPPMessage;
/**
 *  Get the XMPPChatMessageObject from a xml element
 *
 *  @param xmlElement The xml element
 */
- (void)fromXMPPMessage:(XMPPMessage *)message;

///**
// *  Transform the Message object into a Dictionary Object
// *
// *  @return A message dictionary
// */
//- (NSMutableDictionary *)toDictionary;
///**
// *  Get the message object from the Dictionary which contains the whole info of the message
// *
// *  @param message The message object
// */
//- (void)fromDictionary:(NSMutableDictionary*)message;

- (NSMutableDictionary *)toDictionaryWithActive:(BOOL)active;

@end
