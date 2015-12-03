//
//  XMPPLocationMessageObject.m
//  XMPP_Project
//
//  Created by yoolo on 14-11-19.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLocationMessageObject.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>

#define LONGITUDE_ATTRIBUTE_NAME          @"longitude"
#define LATITUDE_ATTRIBUTE_NAME           @"latitude"
#define CONTENT_ATTRIBUTE_NAME            @"content"

//longitude atitude;  content


@implementation XMPPLocationMessageObject

+ (XMPPLocationMessageObject *)xmppLocationMessageObjectFromElement:(NSXMLElement *)element
{
    
    object_setClass(element, [XMPPLocationMessageObject class]);
    return (XMPPLocationMessageObject *)element;
}

+ (XMPPLocationMessageObject *)xmppLocationMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    
    XMPPLocationMessageObject *xmppLocationMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:LOCATION_ELEMENT_NAME];
    if (element) {
        
        xmppLocationMessageObject = [XMPPLocationMessageObject xmppLocationMessageObjectFromElement:element];
    }
    
    return xmppLocationMessageObject;
}

+ (XMPPLocationMessageObject *)xmppLocationMessageObject
{
    
    NSXMLElement *locationElement = [NSXMLElement elementWithName:LOCATION_ELEMENT_NAME];
    return [XMPPLocationMessageObject xmppLocationMessageObjectFromInfoElement:locationElement];
}

+ (XMPPLocationMessageObject *)xmppLocationMessageObjectWithLongitude:(NSString *)longitude latitude:(NSString *)latitude
{
    
    return [XMPPLocationMessageObject xmppLocationMessageObjectWithLongitude:longitude latitude:latitude content:nil];
}

+ (XMPPLocationMessageObject *)xmppLocationMessageObjectWithLongitude:(NSString *)longitude latitude:(NSString *)latitude content:(NSString *)content{
    
    XMPPLocationMessageObject *xmppLocationMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:LOCATION_ELEMENT_NAME];
    xmppLocationMessageObject = [XMPPLocationMessageObject xmppLocationMessageObjectFromElement:element];
    
    [xmppLocationMessageObject setLongitude:longitude];
    [xmppLocationMessageObject setLatitude:latitude];
    [xmppLocationMessageObject setContent:content];
    return xmppLocationMessageObject;
    
}
- (instancetype)init
{
    return  [self initWithLongitude:nil latitude:nil content:nil];
}

- (instancetype)initWithLongitude:(NSString *)longitude latitude:(NSString *)latitude
{
    
    return  [self initWithLongitude:longitude latitude:latitude content:nil];
    
}

- (instancetype)initWithLongitude:(NSString *)longitude latitude:(NSString *)latitude content:(NSString *)content
{
    self = [super initWithName:LONGITUDE_ATTRIBUTE_NAME];
    if (self) {
        [self setLongitude:longitude];
        [self setLatitude:latitude];
        [self setContent:content];
    }
    return  self;
    
}

- (NSString *)longitude
{
    return [self attributeStringValueForName:LONGITUDE_ATTRIBUTE_NAME];
}

- (void)setLongitude:(NSString *)longitude
{
    if (!longitude) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(longitude, LONGITUDE_ATTRIBUTE_NAME);
}

- (NSString *)latitude
{
    return [self attributeStringValueForName:LATITUDE_ATTRIBUTE_NAME];
}

- (void)setLatitude:(NSString *)latitude
{
    if (!latitude) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(latitude, LATITUDE_ATTRIBUTE_NAME);
}

- (NSString *)content
{
    return [self stringValue];
}

- (void)setContent:(NSString *)content
{
    if (!content) {
        return;
    }
    [self setStringValue:content];
}

@end
