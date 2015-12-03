//
//  XMPPMessage+ChatRoomMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/26.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessage+ChatRoomMessage.h"

#define PUSH_ELEMNET @"push"
#define PUSH_ELEMENT_XMLNS @"aft:groupchat"

@implementation XMPPMessage (ChatRoomMessage)

- (BOOL)isChatRoomMessage
{
    return ([[[self attributeForName:@"type"] stringValue] isEqualToString:@"chat"] & ([self attributeStringValueForName:@"user"] != nil));
}

- (BOOL)isChatRoomMessageWithBody
{
    if ([self isChatRoomMessage])
    {
        NSString *body = [[self elementForName:@"body"] stringValue];
        
        return ([body length] > 0);
    }
    
    return NO;
}


- (BOOL)isChatRoomPushMessage
{
    return ([self elementForName:PUSH_ELEMNET xmlns:PUSH_ELEMENT_XMLNS] != nil);
}


- (BOOL)isChatRoomMessageWithSubject
{
    if ([self isChatRoomMessage])
    {
        NSString *subject = [[self elementForName:@"subject"] stringValue];
        
        return ([subject length] > 0);
    }
    
    return NO;
}

- (BOOL)hasPushElementWithXmlns:(NSString *)xmlns
{
    BOOL result = NO;
    
    NSXMLElement *push = [self elementForName:PUSH_ELEMNET xmlns:xmlns];
    if (push != nil) {
        result = YES;
    }
    
    return result;
}

- (NSXMLElement *)psuhElementFromChatRoomPushMessageWithXmlns:(NSString *)xmlns
{
    NSXMLElement *push = nil;
    
    push = [self elementForName:PUSH_ELEMNET xmlns:xmlns];

    return push;
}


@end
