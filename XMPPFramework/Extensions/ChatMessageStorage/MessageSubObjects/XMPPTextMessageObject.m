//
//  XMPPTextMessageObject.m
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPTextMessageObject.h"
#import <objc/runtime.h>




@implementation XMPPTextMessageObject


+ (XMPPTextMessageObject *)xmppTextMessageObject
{
    NSXMLElement *textElement = [NSXMLElement elementWithName:TEXT_ELEMENT_NAME];
    return [XMPPTextMessageObject xmppTextMessageObjectFromElement:textElement];
}
+ (XMPPTextMessageObject *)xmppTextMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPTextMessageObject class]);
    return (XMPPTextMessageObject *)element;
}
+ (XMPPTextMessageObject *)xmppTextMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    XMPPTextMessageObject *xmppTextMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:TEXT_ELEMENT_NAME];
    if (element) {
        xmppTextMessageObject = [XMPPTextMessageObject xmppTextMessageObjectFromElement:element];
    }
    
    return xmppTextMessageObject;
}
-(instancetype)initWithText:(NSString*)text
{
    self = [super initWithName:TEXT_ELEMENT_NAME];
    if (self) {
        
        [self setText:text];
    }
    return self;
}
+(XMPPTextMessageObject *)xmppTextMessageObjectWithText:(NSString*)text;

{
    return [[XMPPTextMessageObject alloc ] initWithText:text];
}

#pragma mark - getters and setters
-(void)setText:(NSString *)text
{
    [self setStringValue:text];
}
-(NSString*)text
{
    return [self stringValue];
}
@end
