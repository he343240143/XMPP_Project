//
//  XMPPMessage+ChatRoomMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/26.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

@interface XMPPMessage (ChatRoomMessage)

- (BOOL)isChatRoomMessage;
- (BOOL)isChatRoomPushMessage;
- (BOOL)isChatRoomMessageWithBody;
- (BOOL)isChatRoomMessageWithSubject;

- (BOOL)hasPushElementWithXmlns:(NSString *)xmlns;
- (NSXMLElement *)psuhElementFromChatRoomPushMessageWithXmlns:(NSString *)xmlns;

@end
