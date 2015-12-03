//
//  XMPPTextMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//


#import "XMPPBaseMessageSubObject.h"
#define TEXT_ELEMENT_NAME                  @"text"
@interface XMPPTextMessageObject : XMPPBaseMessageSubObject
@property (nonatomic, strong) NSString * text;
//class init methods

+ (XMPPTextMessageObject *)xmppTextMessageObject;
+ (XMPPTextMessageObject *)xmppTextMessageObjectWithText:(NSString*)text;
+ (XMPPTextMessageObject *)xmppTextMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPTextMessageObject *)xmppTextMessageObjectFromInfoElement:(NSXMLElement *)infoElement;

//object init objects
-(instancetype)initWithText:(NSString*)text ;

@end
