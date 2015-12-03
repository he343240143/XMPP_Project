//
//  XMPPBaseMessageSubObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"
#import "XMPPLogging.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#endif

#define CODER_KEY @"messageSubElementXMLString"

@implementation XMPPBaseMessageSubObject

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
    size_t ourSize   = class_getInstanceSize([self class]);
    
    if (superSize != ourSize)
    {
        XMPPLogError(@"Adding instance variables to XMPPBaseMessageSubObject is not currently supported!");
        
        [DDLog flushLog];
        exit(15);
    }
}

#if ! TARGET_OS_IPHONE
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
    if([encoder isBycopy])
        return self;
    else
        return [super replacementObjectForPortCoder:encoder];
}
#endif

#pragma mark - NSCopying methods
- (id)initWithCoder:(NSCoder *)coder
{
    NSString *xmlString;
    if([coder allowsKeyedCoding])
    {
        xmlString = [coder decodeObjectForKey:CODER_KEY];
    }
    else
    {
        xmlString = [coder decodeObject];
    }
    
    // The method [super initWithXMLString:error:] may return a different self.
    // In other words, it may [self release], and alloc/init/return a new self.
    //
    // So to maintain the proper class (XMPPvCardTempEmail, XMPPvCardTempTel, etc)
    // we need to get a reference to the class before invoking super.
    
    Class selfClass = [self class];
    
    if ((self = [super initWithXMLString:xmlString error:nil]))
    {
        object_setClass(self, selfClass);
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    NSString *xmlString = [self XMLString];
    
    if([coder allowsKeyedCoding])
    {
        [coder encodeObject:xmlString forKey:CODER_KEY];
    }
    else
    {
        [coder encodeObject:xmlString];
    }
}

#pragma mark - NSCopying methods
- (id)copyWithZone:(NSZone *)zone
{
    NSXMLElement *elementCopy = [super copyWithZone:zone];
    object_setClass(elementCopy, [self class]);
    
    return elementCopy;
}


@end
