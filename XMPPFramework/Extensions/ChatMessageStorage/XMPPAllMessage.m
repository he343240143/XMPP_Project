//
//  XMPPChatMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/29.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
#import "XMPPAllMessage.h"
#import "XMPPFramework.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define XMLNS_XMPP_ARCHIVE @"urn:xmpp:archive"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wunused-variable"

@implementation XMPPAllMessage


- (id)init
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPMessageArchiving.h are supported.
    
    return [self initWithMessageStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    // This will cause a crash - it's designed to.
    // Only the init methods listed in XMPPMessageArchiving.h are supported.
    
    return [self initWithMessageStorage:nil dispatchQueue:queue];
}

- (id)initWithMessageStorage:(id <XMPPAllMessageStorage>)storage
{
    return [self initWithMessageStorage:storage dispatchQueue:NULL];
}

- (id)initWithMessageStorage:(id <XMPPAllMessageStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            xmppMessageStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        receiveSystemPushMessage = YES;
        receiveUserRequestMessage = YES;
        clientSideMessageArchivingOnly = NO;
        
        activeUser = nil;
        
        NSXMLElement *_default = [NSXMLElement elementWithName:@"default"];
        [_default addAttributeWithName:@"expire" stringValue:@"604800"];
        [_default addAttributeWithName:@"save" stringValue:@"body"];
        
        NSXMLElement *pref = [NSXMLElement elementWithName:@"pref" xmlns:XMLNS_XMPP_ARCHIVE];
        [pref addChild:_default];
        
        preferences = pref;
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    XMPPLogTrace();
    
    if ([super activate:aXmppStream])
    {
        XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
        // Reserved for future potential use
        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    XMPPLogTrace();
    
    // Reserved for future potential use
    
    [super deactivate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties' getters and setters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPAllMessageStorage>)xmppMessageStorage
{
    // Note: The xmppMessageStorage variable is read-only (set in the init method)
    
    return xmppMessageStorage;
}

- (BOOL)clientSideMessageArchivingOnly
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = clientSideMessageArchivingOnly;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setClientSideMessageArchivingOnly:(BOOL)flag
{
    dispatch_block_t block = ^{
        clientSideMessageArchivingOnly = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)receiveUserRequestMessage
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = receiveUserRequestMessage;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setReceiveUserRequestMessage:(BOOL)flag
{
    dispatch_block_t block = ^{
        receiveUserRequestMessage = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)receiveSystemPushMessage
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = receiveSystemPushMessage;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setReceiveSystemPushMessage:(BOOL)flag
{
    dispatch_block_t block = ^{
        receiveSystemPushMessage = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (NSString *)activeUser
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        
        result = [activeUser copy];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setActiveUser:(NSString *)userBareJidStr
{
    dispatch_block_t block = ^{
        activeUser = [userBareJidStr copy];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (NSXMLElement *)preferences
{
    __block NSXMLElement *result = nil;
    
    dispatch_block_t block = ^{
        
        result = [preferences copy];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setPreferences:(NSXMLElement *)newPreferences
{
    dispatch_block_t block = ^{ @autoreleasepool {
        
        // Update cached value
        
        preferences = [newPreferences copy];
        
        // Update storage
        
        if ([xmppMessageStorage respondsToSelector:@selector(setPreferences:forUser:)])
        {
            XMPPJID *myBareJid = [[xmppStream myJID] bareJID];
            //???:Here
            //[xmppMessageStorage setPreferences:preferences forUser:myBareJid];
        }
        
        //  
        // 
        //  - Send new pref to server (if changed)
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - comment method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addActiveUser:(NSString *)userBareJidStr Delegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    // Asynchronous operation (if outside xmppQueue)
    
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
        [self setActiveUser:userBareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)removeActiveUserAndDelegate:(id)delegate
{
    [self setActiveUser:nil];
    [self removeDelegate:delegate];
}

- (void)saveXMPPMessage:(XMPPMessage *)message
{
    XMPPLogTrace();
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            XMPPExtendMessageObject *newMessage = [XMPPExtendMessageObject xmppExtendMessageObjectFromXMPPMessage:message];
            [self saveMessageWithXMPPStream:xmppStream message:newMessage sendFromMe:YES];
            [multicastDelegate xmppAllMessage:self willSendXMPPMessage:message];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)clearAllChatHistorysAndMessages
{
    dispatch_block_t block = ^{

        [xmppMessageStorage clearAllChatHistoryAndMessageWithXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)clearChatHistoryWithUserJid:(XMPPJID *)userJid
{
    if (!userJid) return;
    
    dispatch_block_t block = ^{
        NSString *bareUserJidStr = [[userJid copy] bare];
        [self clearChatHistoryWithBareUserJidStr:bareUserJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)readAllUnreadMessageWithUserJid:(XMPPJID *)userJid
{
    if (!userJid) return;
    
    dispatch_block_t block = ^{
        NSString *bareUserJidStr = [[userJid copy] bare];
        [self readAllUnreadMessageWithBareUserJidStr:bareUserJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)readMessageWithMessageID:(NSString *)messageID
{
    if (!messageID) return;
    
    dispatch_block_t block = ^{
        NSString *messageid = [messageID copy];
        [self readMessageFromStorgeWithMessageID:messageid xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)deleteMessageWithMessageID:(NSString *)messageID
{
    if (!messageID) return;
    
    dispatch_block_t block = ^{
        NSString *messageid = [messageID copy];
        [self deleteMessageFromStorgeWithMessageID:messageid xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID sendSucceed:(XMPPMessageSendStatusType)sendType
{
    if (!messageID) return;
    
    dispatch_block_t block = ^{
        NSString *messageid = [messageID copy];
        [self updateMessageSendStatusFromStorgeWithMessageID:messageid sendSucceed:sendType xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message
{
    if (!message) return;
    dispatch_block_t block = ^{
        [self readMessageFromStorgeWithMessage:message xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message
{
    if (!message) return;
    dispatch_block_t block = ^{
        
        [self deleteMessageFromStorgeWithMessage:message xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message
{
    if (!message) return;
    dispatch_block_t block = ^{
        [self updateMessageSendStatusFromStorgeWithMessage:message xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)addFilePath:(NSString *)filePath toXMPPExtendMessageObject:(XMPPExtendMessageObject *)message
{
    [self updateFilePath:filePath toXMPPExtendMessageObjectWithMessageID:message.messageID];
}
- (void)addFilePath:(NSString *)filePath toXMPPExtendMessageObjectWithMessageID:(NSString *)messageID
{
    [self updateFilePath:filePath toXMPPExtendMessageObjectWithMessageID:messageID];
}
- (void)updateFilePath:(NSString *)filePath toXMPPExtendMessageObject:(XMPPExtendMessageObject *)message
{
    [self updateFilePath:filePath toXMPPExtendMessageObjectWithMessageID:message.messageID];
}
- (void)updateFilePath:(NSString *)filePath toXMPPExtendMessageObjectWithMessageID:(NSString *)messageID
{
    if (!messageID || !filePath) return;
    
    dispatch_block_t block = ^{
        
        [self updateNewFilePath:filePath toMessageWithID:messageID xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (XMPPMessageCoreDataStorageObject *)lastMessageWithBareJidStr:(NSString *)bareJidStr
{
    if (!bareJidStr) return nil;
    
    __block XMPPMessageCoreDataStorageObject *result = nil;
    
    dispatch_block_t block = ^{
        
        result = [xmppMessageStorage lastMessageWithBareJidStr:bareJidStr xmppStream:xmppStream];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset
{
    if (!bareJidStr) return nil;
    
    __block NSArray *results = nil;
    
    dispatch_block_t block = ^{
        
        results = [xmppMessageStorage fetchMessagesWithBareJidStr:bareJidStr fetchSize:fetchSize fetchOffset:fetchOffset xmppStream:xmppStream];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    return  results;
}

- (void)saveAndSendXMPPExtendMessageObject:(XMPPExtendMessageObject *)message
{
    dispatch_block_t block = ^{
        
        XMPPMessage *newMessage = [[message toXMPPMessage] copy];
        //we should stroage this message firstly
        [self saveMessageWithXMPPStream:xmppStream message:message sendFromMe:YES];
        //send the message
        [xmppStream sendElement:newMessage];
        
        //Call the delegate
        [multicastDelegate xmppAllMessage:self didReceiveXMPPMessage:newMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_NEW_XMPP_MESSAGE object:newMessage];
      
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)saveXMPPExtendMessageObject:(XMPPExtendMessageObject *)message
{
    dispatch_block_t block = ^{
        
        BOOL sendFromMe = message.sendFromMe;
        //we should stroage this message firstly
        [self saveMessageWithXMPPStream:xmppStream message:[message copy] sendFromMe:sendFromMe];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}
- (void)sendXMPPExtendMessageObject:(XMPPExtendMessageObject *)message
{
    dispatch_block_t block = ^{
        
        XMPPMessage *newMessage = [[message toXMPPMessage] copy];
        
        //send the message
        [xmppStream sendElement:newMessage];
        
        //Call the delegate
        [multicastDelegate xmppAllMessage:self didReceiveXMPPMessage:newMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_NEW_XMPP_MESSAGE object:newMessage];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)setAllSendingStateMessagesToFailureState
{
    dispatch_block_t block = ^{
        [xmppMessageStorage setAllSendingStateMessagesToFailureStateWithXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)fetchAllSendingStateMessages:(CompletionBlock) completionBlock
{
    dispatch_block_t block = ^{
        
        NSArray *allSendingStateMessages = [xmppMessageStorage allSendingStateMessagesWithXMPPStream:xmppStream];
        
        if (completionBlock != NULL) {
            
            dispatch_main_async_safe(^{
                completionBlock(allSendingStateMessages, nil);
            });
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark operate the message
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)saveMessageWithXMPPStream:(XMPPStream *)sender message:(XMPPExtendMessageObject *)message sendFromMe:(BOOL)sendFromMe
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    //save the message
    BOOL activeMessage = sendFromMe ? NO:[[self activeUser] isEqualToString:message.fromUser];
    [message setSendFromMe:sendFromMe];

    [xmppMessageStorage archiveMessage:message active:activeMessage xmppStream:sender];
    
    //send the message to the UI
    //Call the delegate
    [multicastDelegate xmppAllMessage:self didReceiveXMPPExtendMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_NEW_XMPP_EXTEND_CHAT_MESSAGE object:message];
    
}

- (void)clearChatHistoryWithBareUserJidStr:(NSString *)userJidStr xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [xmppMessageStorage clearChatHistoryWithBareUserJid:userJidStr xmppStream:stream];
}

- (void)readAllUnreadMessageWithBareUserJidStr:(NSString *)userJidStr xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [xmppMessageStorage readAllUnreadMessageWithBareUserJid:userJidStr xmppStream:stream];
}

- (void)readMessageFromStorgeWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage readMessageWithMessageID:messageID xmppStream:stream];
}

- (void)deleteMessageFromStorgeWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage deleteMessageWithMessageID:messageID xmppStream:stream];
}
- (void)updateMessageSendStatusFromStorgeWithMessageID:(NSString *)messageID sendSucceed:(XMPPMessageSendStatusType)sendType xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage updateMessageSendStatusWithMessageID:messageID sendSucceed:sendType xmppStream:stream];
}

- (void)readMessageFromStorgeWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage readMessageWithMessage:message xmppStream:stream];
}

- (void)deleteMessageFromStorgeWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage deleteMessageWithMessage:message xmppStream:stream];
}

- (void)updateMessageSendStatusFromStorgeWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage updateMessageSendStatusWithMessage:message success:YES xmppStream:stream];
}

- (void)updateNewFilePath:(NSString *)filePath toMessageWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    [xmppMessageStorage updateMessageWithNewFilePath:filePath messageID:messageID xmppStream:stream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPLogTrace();
    /*
    if (clientSideMessageArchivingOnly) return;
    
    // Fetch most recent preferences
    
    if ([xmppMessageStorage respondsToSelector:@selector(preferencesForUser:)])
    {
        XMPPJID *myBareJid = [[xmppStream myJID] bareJID];
        
        //preferences = [xmppMessageStorage preferencesForUser:myBareJid];
    }
    
    // Request archiving preferences from server
    //
    // <iq type='get'>
    //   <pref xmlns='urn:xmpp:archive'/>
    // </iq>
    
    NSXMLElement *pref = [NSXMLElement elementWithName:@"pref" xmlns:XMLNS_XMPP_ARCHIVE];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:nil elementID:nil child:pref];
    
    [sender sendElement:iq];
     */
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //operate the IQ here
    //Your coding ...
    return YES;
}
/*
 * We should stroage the message when sending and set its hasBeenRead into NO;
 * If the message id sent from me and the hasBeenRead is NO,Indicate that this
 * message has already send succeed,if the hasBeenRead is YES,Indicate that this
 * message has already send failed.
 *
 * So,when we send the message succeed,we should modify the hasBeenRead into YES,
 * and notice all the observers that this message has been sended succeed
 *
 * Otherwise,we should notice all the observers that this message has been sended failed
 *
 */
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    XMPPLogTrace();
    // Asynchronous operation (if outside xmppQueue)
    
    if ([message isChatMessageWithInfo]) {
        
        NSString *messageID = [message messageID];
        [self updateMessageSendStatusWithMessageID:messageID sendSucceed:XMPPMessageSendSucceedType];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            // code to be executed on the main queue after delay
            
            XMPPExtendMessageObject *newMessage = [XMPPExtendMessageObject xmppExtendMessageObjectFromXMPPMessage:[message copy]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SEND_XMPP_EXTEND_CHAT_MESSAGE_SUCCEED object:newMessage];
        });
        
    }
    
}



- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    XMPPLogTrace();
    
    if ([message isChatMessageWithInfo]) {
        
        NSString *messageID = [message messageID];
        
        [self updateMessageSendStatusWithMessageID:messageID sendSucceed:XMPPMessageSendFailedType];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            // code to be executed on the main queue after delay
            
            XMPPExtendMessageObject *newMessage = [XMPPExtendMessageObject xmppExtendMessageObjectFromXMPPMessage:[message copy]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SEND_XMPP_EXTEND_CHAT_MESSAGE_FAILED object:newMessage];
        });
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    XMPPLogTrace();
    
    if ([message isChatMessageWithInfo]) {
        
        //save the message
        XMPPExtendMessageObject *newMessage = [XMPPExtendMessageObject xmppExtendMessageObjectFromXMPPMessage:[message copy]];
        
        if (newMessage.messageType == XMPPExtendMessageAudioType) {
            
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(globalModuleQueue, ^{
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                NSData *fileData = newMessage.audio.fileData;
                NSString *filePath = [strongSelf filePathWithName:newMessage.audio.fileName];
                if (fileData.length > 0 &&
                    [fileData writeToFile:filePath atomically:YES]) {
                    newMessage.audio.fileData = nil;
                    newMessage.audio.filePath = filePath;
                    
                    dispatch_block_t block = ^{
                        
                        [strongSelf saveMessageWithXMPPStream:sender message:newMessage sendFromMe:NO];
                        [multicastDelegate xmppAllMessage:strongSelf didReceiveXMPPMessage:message];
                        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_NEW_XMPP_MESSAGE object:message];
                    };
                    
                    if (dispatch_get_specific(moduleQueueTag))
                        block();
                    else
                        dispatch_async(moduleQueue, block);
                }
            });
            
        }else{
            [self saveMessageWithXMPPStream:sender message:newMessage sendFromMe:NO];
            [multicastDelegate xmppAllMessage:self didReceiveXMPPMessage:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_NEW_XMPP_MESSAGE object:message];
        }
        
    }
}

- (NSString *)filePathWithName:(NSString *)fileName
{
    __block NSString *name = nil;
    
    dispatch_block_t block = ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *voiceDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",[[xmppStream myJID] user],@"voice"]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyyMMdd_HHmmss_SSS"];
        
       name = [voiceDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spx", [dateFormatter stringFromDate:[NSDate date]]]];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return name;
}

@end

#pragma clang diagnostic pop
