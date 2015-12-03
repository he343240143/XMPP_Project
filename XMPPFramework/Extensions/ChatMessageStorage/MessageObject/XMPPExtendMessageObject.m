//
//  XMPPChatMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPExtendMessageObject.h"
#import "XMPPFramework.h"
#import "XMPPLogging.h"
#import "XMPPDateTimeProfiles.h"
#import "NSData+XMPP.h"
#import "NSDate+NSString.h"
#import "NSString+NSDate.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#endif

#define MESSAGE_SENDER_ELEMENT_NAME             @"sender"

#define MESSAGE_ID_ATTRIBUTE_NAME               @"id"
#define MESSAGE_TYPE_ATTRIBUTE_NAME             @"type"

#define MESSAGE_TIME_ATTRIBUTE_NAME             @"timestamp"
#define MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME    @"groupChat"

#define EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME       @"toUser"
#define EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME     @"fromUser"
#define EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME       @"hasBeenRead"
#define EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME       @"sendFromMe"

@implementation XMPPExtendMessageObject

#pragma mark - Public Methods


#pragma mark - class methods
+ (void)initialize {
    // We use the object_setClass method below to dynamically change the class from a standard NSXMLElement.
    // The size of the two classes is expected to be the same.
    //
    // If a developer adds instance methods to this class, bad things happen at runtime that are very hard to debug.
    // This check is here to aid future developers who may make this mistake.
    //
    // For Fearless And Experienced Objective-C Developers:
    // It may be possible to support adding instance variables to this class if you seriously need it.
    // To do so, try realloc'ing self after altering the class, and then initialize your variables.
    
    size_t superSize = class_getInstanceSize([NSXMLElement class]);
    size_t ourSize   = class_getInstanceSize([XMPPExtendMessageObject class]);
    
    if (superSize != ourSize)
    {
        XMPPLogError(@"Adding instance variables to XMPPExtendMessageObject is not currently supported!");
        
        [DDLog flushLog];
        exit(15);
    }
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObject
{
    NSXMLElement *xmppExtendMessageElement = [NSXMLElement elementWithName:XMPP_MESSAGE_EXTEND];
    return [XMPPExtendMessageObject xmppExtendMessageObjectFromElement:xmppExtendMessageElement];
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPExtendMessageObject class]);
    return (XMPPExtendMessageObject *)element;
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromXMPPMessage:(XMPPMessage *)message
{
    XMPPExtendMessageObject *xmppExtendMessageObject = [XMPPExtendMessageObject xmppExtendMessageObject];
    [xmppExtendMessageObject fromXMPPMessage:message];
    return xmppExtendMessageObject;
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectCopyFromMessage:(XMPPMessage *)message
{
    return [self xmppExtendMessageObjectFromXMPPMessage:[message copy]];
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    XMPPExtendMessageObject *object = [XMPPExtendMessageObject xmppExtendMessageObject];
    
    [object setUpWithXMPPMessageCoreDataStorageObject:xmppMessageCoreDataStorageObject];
    
    return object;
}


#pragma mark - object class method

- (instancetype)init
{
    return [[XMPPExtendMessageObject alloc] initWithType:XMPPExtendMessageTextType];
}

- (instancetype)initWithType:(XMPPExtendMessageType)messageType
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        [self createMessageID];
        [self setMessageType:messageType];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        [self fromDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithXMPPMessage:(XMPPMessage *)message
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        [self fromXMPPMessage:message];
    }
    return self;
}

- (instancetype)initWithXMPPMessage:(XMPPMessage *)message  sendFromMe:(BOOL)sendFromMe hasBeenRead:(BOOL)hasBeenRead
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        self.hasBeenRead = hasBeenRead;
        self.sendFromMe = sendFromMe;
        [self fromXMPPMessage:message];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary from:(NSString *)from to:(NSString *)to hasBeenRead:(BOOL)hasBeenRead
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        self.fromUser = from;
        self.toUser = to;
        self.hasBeenRead = hasBeenRead;
        [self fromDictionary:dictionary];
    }
    return self;
}


- (instancetype)initWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        [self setUpWithXMPPMessageCoreDataStorageObject:xmppMessageCoreDataStorageObject];
    }
    return self;
}
- (instancetype)initWithFromUser:(NSString *)fromUser toUser:(NSString *)toUser type:(XMPPExtendMessageType)type sendFromMe:(BOOL)sendFromMe hasBeenRead:(NSInteger)hasBeenRead groupChat:(BOOL)groupChat sender:(NSString *)sender time:(NSDate *)time subObject:(id)subObject
{
    self = [super initWithName:XMPP_MESSAGE_EXTEND];
    if (self) {
        [self createMessageID];
        [self setMessageType:type];
        [self setFromUser:fromUser];
        [self setToUser:self.toUser];
        [self setSendFromMe:sendFromMe];
        [self setIsGroupChat:groupChat];
        [self setHasBeenRead:hasBeenRead];
        [self setSender:sender];
        [self setMessageTime:time];
        
        if (subObject != nil) {
            
            if ([subObject isKindOfClass:[XMPPTextMessageObject class]]) {
                [self setText:subObject];
            }else if ([subObject isKindOfClass:[XMPPAudioMessageObject class]]){
                [self setAudio:subObject];
            }else if ([subObject isKindOfClass:[XMPPVideoMessageObject class]]) {
                [self setVideo:subObject];
            }else if ([subObject isKindOfClass:[XMPPPictureMessageObject class]]){
                [self setPicture:subObject];
            }else if ([subObject isKindOfClass:[XMPPLocationMessageObject class]]){
                [self setLocation:subObject];
            }
        }
    }
    return self;
}
#pragma mark - switch methods
- (XMPPMessage *)toXMPPMessage
{
    NSXMLElement *info = [[self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS] copy];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:self.toUser] elementID:nil child:info];

    return message;
}

//This method has no Parameter hasBeenRead,sendFromMe...
- (void)fromXMPPMessage:(XMPPMessage *)message
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    //If this element is existed,we should remove it brefore
    if (infoElement) {
        [self removeChildAtIndex:[[self children] indexOfObject:infoElement]];
    }
    infoElement = [[message elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS] copy];
    [self addChild:infoElement];
    [self setFromUser:message.from.bare];
    [self setToUser:message.to.bare];
  
}

- (void)setUpWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    BOOL sendfromme = [xmppMessageCoreDataStorageObject.sendFromMe boolValue];
    [self setFromUser:(sendfromme ? xmppMessageCoreDataStorageObject.streamBareJidStr: xmppMessageCoreDataStorageObject.bareJidStr)];
    [self setToUser:(sendfromme ? xmppMessageCoreDataStorageObject.bareJidStr: xmppMessageCoreDataStorageObject.streamBareJidStr)];
    [self setHasBeenRead:[xmppMessageCoreDataStorageObject.hasBeenRead integerValue]];
    [self setSendFromMe:sendfromme];
    [self setMessageType:[xmppMessageCoreDataStorageObject.messageType unsignedIntegerValue]];
    [self setMessageID:xmppMessageCoreDataStorageObject.messageID];
    [self setIsGroupChat:[xmppMessageCoreDataStorageObject.isGroupChat boolValue]];
    [self setMessageTime:xmppMessageCoreDataStorageObject.messageTime];
    
    if (self.isGroupChat) {
        [self setSender:xmppMessageCoreDataStorageObject.additionalMessage.groupUserJid];
    }
    
    switch (self.messageType) {
        case XMPPExtendMessageTextType:
            self.text = [XMPPTextMessageObject xmppTextMessageObjectWithText:xmppMessageCoreDataStorageObject.additionalMessage.messageText];
            break;
        case XMPPExtendMessageAudioType:
            self.audio = [XMPPAudioMessageObject xmppAudioMessageObjectWithFilePath:xmppMessageCoreDataStorageObject.additionalMessage.filePath fileData:xmppMessageCoreDataStorageObject.additionalMessage.fileData  time:xmppMessageCoreDataStorageObject.additionalMessage.timeLength];
            break;
        case XMPPExtendMessageVideoType:
            self.video = [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:xmppMessageCoreDataStorageObject.additionalMessage.fileName
                                                                           filePath:xmppMessageCoreDataStorageObject.additionalMessage.filePath
                                                                           fileData:xmppMessageCoreDataStorageObject.additionalMessage.fileData
                                                                               time:xmppMessageCoreDataStorageObject.additionalMessage.timeLength];
            break;
        case XMPPExtendMessagePictureType:
            self.picture = [XMPPPictureMessageObject xmppPictureMessageObjectWithFileName:xmppMessageCoreDataStorageObject.additionalMessage.fileName
                                                                                 filePath:xmppMessageCoreDataStorageObject.additionalMessage.filePath
                                                                                 fileData:xmppMessageCoreDataStorageObject.additionalMessage.fileData
                                                                              aspectRatio:xmppMessageCoreDataStorageObject.additionalMessage.aspectRatio];
            break;
        case XMPPExtendMessagePositionType:
            self.location = [XMPPLocationMessageObject xmppLocationMessageObjectWithLongitude:xmppMessageCoreDataStorageObject.additionalMessage.longitude
                                                                                     latitude:xmppMessageCoreDataStorageObject.additionalMessage.latitude
                                                                                      content:xmppMessageCoreDataStorageObject.additionalMessage.messageText];
            break;
        case XMPPExtendMessageControlType: 
            
            break;
        case XMPPExtendMessageMediaRequestType:
            
            break;
            
        default:
            break;
    }
    
}

 -(NSMutableDictionary *)toDictionary
 {
     NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
     if (self.messageID)
         [dictionary setObject:self.messageID forKey:@"messageID"];
     if (self.messageTime)
         [dictionary setObject:self.messageTime forKey:@"messageTime"];
     if (self.sender) {
         [dictionary setObject:self.messageTime forKey:@"sender"];
     }
     if (self.fromUser) {
         [dictionary setObject:self.messageTime forKey:@"fromUser"];
     }
     if (self.toUser) {
         [dictionary setObject:self.messageTime forKey:@"toUser"];
     }
     if (self.audio) {
         [dictionary setObject:self.audio forKey:@"audio"];
     }
     if (self.text) {
         [dictionary setObject:self.text forKey:@"text"];
     }
     if (self.video) {
         [dictionary setObject:self.video forKey:@"video"];
     }
     if (self.picture) {
         [dictionary setObject:self.picture forKey:@"picture"];
     }
     if (self.location) {
         [dictionary setObject:self.location forKey:@"location"];
     }
     

     //TODO:text here
     [dictionary setObject:[NSNumber numberWithInteger:self.hasBeenRead] forKey:@"hasBeenRead"];
     [dictionary setObject:[NSNumber numberWithBool:self.sendFromMe] forKey:@"sendFromMe"];
     [dictionary setObject:[NSNumber numberWithBool:self.isGroupChat] forKey:@"isGroupChat"];
     [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    
     return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary*)message
{
    self.messageID = [message objectForKey:@"messageID"];
    self.messageTime = [message objectForKey:@"sendTime"];
    self.sender = [message objectForKey:@"sender"];
    self.fromUser = [message objectForKey:@"fromUser"];
    self.toUser = [message objectForKey:@"toUser"];
    self.audio = [message objectForKey:@"audio"];
    self.text = [message objectForKey:@"text"];
    self.video = [message objectForKey:@"video"];
    self.picture = [message objectForKey:@"picture"];
    self.location = [message objectForKey:@"location"];
 
    self.hasBeenRead = [(NSNumber *)[message objectForKey:@"hasBeenRead"] integerValue];
    self.sendFromMe = [(NSNumber *)[message objectForKey:@"sendFromMe"] boolValue];
    self.isGroupChat = [(NSNumber *)[message objectForKey:@"isGroupChat"] boolValue];
    self.messageType = [(NSNumber *)[message objectForKey:@"messageType"] unsignedIntegerValue];
}

- (NSMutableDictionary *)toDictionaryWithActive:(BOOL)active
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSString *bareJidStr = self.sendFromMe ? self.toUser:self.fromUser;
    NSNumber *unReadMessageCount = [NSNumber numberWithBool:(self.sendFromMe ? NO:!active)];//if read is 0(NO), unread is 1(YES)
    NSNumber *hasBeenRead = [NSNumber numberWithBool:(self.sendFromMe ? ([unReadMessageCount integerValue] > 0):!([unReadMessageCount integerValue] > 0))];
    NSNumber *isGroupChat = [NSNumber numberWithBool:self.isGroupChat];
    
    XMPPAdditionalCoreDataMessageObject *xmppAdditionalCoreDataMessageObject = [[XMPPAdditionalCoreDataMessageObject alloc] initWithInfoXMLElement:[self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]];
    
    if (bareJidStr) [dictionary setObject:bareJidStr forKey:@"bareJidStr"];
    
    if (self.messageTime) [dictionary setObject:self.messageTime forKey:@"messageTime"];
    
    if (xmppAdditionalCoreDataMessageObject) [dictionary setObject:xmppAdditionalCoreDataMessageObject forKey:@"additionalMessage"];
    
    
    [dictionary setObject:[NSNumber numberWithBool:self.sendFromMe] forKey:@"sendFromMe"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    
    //The readed message's hasBeenRead is 1,unread is 0
    //When is sent from me,we should note that this message is been sent failed as default 0
    //After being sent succeed,we should modify this value into 1
    [dictionary setObject:hasBeenRead forKey:@"hasBeenRead"];
    
    //If the unread message count is equal to zero,we will know that this message has been readed
    [dictionary setObject:unReadMessageCount forKey:@"unReadMessageCount"];
    
    [dictionary setObject:self.messageID forKey:@"messageID"];
    [dictionary setObject:isGroupChat forKey:@"isGroupChat"];
    
    return dictionary;
}

#pragma mark - tools methods
-(void)createMessageID
{
    self.messageID = [self UUIDString];
    self.sendFromMe = YES;
}

/**
 *  Get the unique string in system
 *
 *  @return The unique string we want
 */
-(NSString *)UUIDString
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    return (__bridge NSString *)uuidStringRef;
}

#pragma mark - Setters and getters

- (NSString *)toUser
{
    return [self attributeStringValueForName:EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME];
}

- (void)setToUser:(NSString *)toUser
{
    if (toUser) {
        [self addAttributeWithName:EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME stringValue:toUser];
    }
}

- (NSString *)fromUser
{
    return [self attributeStringValueForName:EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME];
}

- (void)setFromUser:(NSString *)fromUser
{
    if (fromUser) {
        [self addAttributeWithName:EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME stringValue:fromUser];
    }
}

- (NSInteger)hasBeenRead
{
    return [self attributeIntegerValueForName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME];
}

- (void)setHasBeenRead:(NSInteger)hasBeenRead
{
    [self addAttributeWithName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME integerValue:hasBeenRead];
}

- (BOOL)sendFromMe
{
    return [self attributeBoolValueForName:EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME];
}

- (void)setSendFromMe:(BOOL)sendFromMe
{
    [self addAttributeWithName:EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME boolValue:sendFromMe];
}

//The info element
- (NSUInteger)messageType
{
    NSUInteger result = 0;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [infoElement attributeUnsignedIntegerValueForName:MESSAGE_TYPE_ATTRIBUTE_NAME];
        
    }
    
    return result;
}

- (void)setMessageType:(NSUInteger)messageType
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    //If the info element is already existed,wo should add the value to it
    if (infoElement) {
        [infoElement addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:messageType];
        return;
    }
    //Otherwise,we should create a new info element
    infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    [infoElement addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:messageType];
    [self addChild:infoElement];
}

- (NSString *)messageID
{
    NSString *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [infoElement attributeStringValueForName:MESSAGE_ID_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMessageID:(NSString *)messageID
{
    if (messageID) {
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:messageID];
            return;
        }
        //Otherwise,we should create a new info element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:messageID];
        [self addChild:infoElement];
    }
}

- (NSDate *)messageTime
{
    NSDate *result = nil;
    
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [[infoElement attributeStringValueForName:MESSAGE_TIME_ATTRIBUTE_NAME] UTCStringToLocalDate];//UTCStringToLocalDate
    }
    
    return result;
}

//The messageTime must been a local time
- (void)setMessageTime:(NSDate *)messageTime
{
    if (messageTime) {
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            [infoElement addAttributeWithName:MESSAGE_TIME_ATTRIBUTE_NAME stringValue:[messageTime LocalDateToUTCString]];
            return;
        }
        //Otherwise,we should create a new info element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:[messageTime DateToString]];
        [self addChild:infoElement];
    }
}

- (BOOL)isGroupChat
{
    BOOL result = NO;
    
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [infoElement attributeBoolValueForName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setIsGroupChat:(BOOL)isGroupChat
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    //If the info element is already existed,wo should add the value to it
    if (infoElement) {
        [infoElement addAttributeWithName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME boolValue:isGroupChat];
        return;
    }
    //Otherwise,we should create a new info element
    infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    [infoElement addAttributeWithName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME boolValue:isGroupChat];
    [self addChild:infoElement];
}

- (NSString *)sender
{
    NSString *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [[infoElement elementForName:MESSAGE_SENDER_ELEMENT_NAME] stringValue];
    }
    
    return result;
}

- (void)setSender:(NSString *)sender
{
    if (sender) {
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *senderElement = [infoElement elementForName:MESSAGE_SENDER_ELEMENT_NAME];
            if (senderElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:senderElement]];
            }
            
            senderElement = [NSXMLElement elementWithName:MESSAGE_SENDER_ELEMENT_NAME];
            [senderElement setStringValue:sender];
            
            [infoElement addChild:senderElement];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //init a new sender xml element
        NSXMLElement *senderElement = [NSXMLElement elementWithName:MESSAGE_SENDER_ELEMENT_NAME];
        [senderElement setStringValue:sender];
        
        [infoElement addChild:senderElement];
        [self addChild:infoElement];
    }
}

- (XMPPAudioMessageObject *)audio
{
    XMPPAudioMessageObject *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [XMPPAudioMessageObject xmppAudioMessageObjectFromElement:[infoElement elementForName:AUDIO_ELEMENT_NAME]];
    }
    
    return result;
}

- (void)setAudio:(XMPPAudioMessageObject *)audio
{
    if (audio) {
        
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *audioElement = [infoElement elementForName:AUDIO_ELEMENT_NAME];
            
            if (audioElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:audioElement]];
            }
            
            [infoElement addChild:audio];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];

        [infoElement addChild:audio];
        [self addChild:infoElement];
    }
}
- (XMPPTextMessageObject *)text
{
    XMPPTextMessageObject *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [XMPPTextMessageObject xmppTextMessageObjectFromElement:[infoElement elementForName:TEXT_ELEMENT_NAME]];
    }
    
    return result;
}

- (void)setText:(XMPPTextMessageObject *)text
{
    if (text) {
        
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *textElement = [infoElement elementForName:TEXT_ELEMENT_NAME];
            
            if (textElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:textElement]];
            }
            
            [infoElement addChild:text];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        [infoElement addChild:text];
        [self addChild:infoElement];
    }
}

- (XMPPVideoMessageObject *)video
{
    XMPPVideoMessageObject *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [XMPPVideoMessageObject xmppVideoMessageObjectFromElement:[infoElement elementForName:VIDEO_ELEMENT_NAME]];
    }
    
    return result;
}

- (void)setVideo:(XMPPVideoMessageObject *)video
{
    if (video) {
        
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *videoElement = [infoElement elementForName:VIDEO_ELEMENT_NAME];
            
            if (videoElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:videoElement]];
            }
            
            [infoElement addChild:video];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        [infoElement addChild:video];
        [self addChild:infoElement];
    }
}


- (XMPPPictureMessageObject *)picture
{
    XMPPPictureMessageObject *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [XMPPPictureMessageObject xmppPictureMessageObjectFromElement:[infoElement elementForName:PICTURE_ELEMENT_NAME]];
    }
    
    return result;
}

- (void)setPicture:(XMPPPictureMessageObject *)picture
{
    if (picture) {
        
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *pictureElement = [infoElement elementForName:PICTURE_ELEMENT_NAME];
            
            if (pictureElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:pictureElement]];
            }
            
            [infoElement addChild:picture];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        [infoElement addChild:picture];
        [self addChild:infoElement];
    }
}

- (XMPPLocationMessageObject *)location
{
    XMPPLocationMessageObject *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [XMPPLocationMessageObject xmppLocationMessageObjectFromElement:[infoElement elementForName:LOCATION_ELEMENT_NAME]];
    }
    
    return result;
}

- (void)setLocation:(XMPPLocationMessageObject *)location
{
    if (location) {
        
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            
            NSXMLElement *locationElement = [infoElement elementForName:LOCATION_ELEMENT_NAME];
            
            if (locationElement) {
                [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:locationElement]];
            }
            
            [infoElement addChild:location];
            
            return;
        }
        //Otherwise,we should create a new info element
        //init a new info XML element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        
        [infoElement addChild:location];
        [self addChild:infoElement];
    }
}


@end
