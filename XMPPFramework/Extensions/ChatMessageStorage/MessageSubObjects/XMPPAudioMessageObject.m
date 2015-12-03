//
//  XMPPAudioMessageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPAudioMessageObject.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>

#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_DATA_ATTRIBUTE_NAME            @"fileData"
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"
#define TIME_LENGTH_ATTRIBUTE_NAME          @"timeLength"

@implementation XMPPAudioMessageObject

#pragma mark - class methods

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPAudioMessageObject class]);
    return (XMPPAudioMessageObject *)element;
}

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    XMPPAudioMessageObject *xmppAudioMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:AUDIO_ELEMENT_NAME];
    if (element) {
        xmppAudioMessageObject = [XMPPAudioMessageObject xmppAudioMessageObjectFromElement:element];
    }
    
    return xmppAudioMessageObject;
}

+ (XMPPAudioMessageObject *)xmppAudioMessageObject
{
    NSXMLElement *audioElement = [NSXMLElement elementWithName:AUDIO_ELEMENT_NAME];
    return [XMPPAudioMessageObject xmppAudioMessageObjectFromElement:audioElement];
}

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFilePath:(NSString *)filePath time:(NSTimeInterval)time
{
    return [XMPPAudioMessageObject xmppAudioMessageObjectWithFilePath:filePath fileData:nil time:time];
}
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFileData:(NSData *)fileData time:(NSTimeInterval)time
{
    return [XMPPAudioMessageObject xmppAudioMessageObjectWithFilePath:nil fileData:fileData time:time];
}

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time
{
    return [XMPPAudioMessageObject xmppAudioMessageObjectWithFileName:nil filePath:filePath fileData:fileData time:time];
}

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time
{
    XMPPAudioMessageObject *xmppAudioMessageObject = nil;
    
    NSXMLElement *element = [NSXMLElement elementWithName:AUDIO_ELEMENT_NAME];
    
    xmppAudioMessageObject = [XMPPAudioMessageObject xmppAudioMessageObjectFromElement:element];
    
    [xmppAudioMessageObject setFileName:fileName];
    [xmppAudioMessageObject setFilePath:filePath];
    [xmppAudioMessageObject setFileData:fileData];
    [xmppAudioMessageObject setTimeLength:time];
    
    return xmppAudioMessageObject;
}

//object init methods
- (instancetype)init
{
    return [self initWitFileData:nil time:0.0];
}

- (instancetype)initWitFileData:(NSData *)fileData time:(NSTimeInterval)time
{
    return [self initWithFileName:nil fileData:fileData time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData time:(NSTimeInterval)time
{
    return [self initWithFileName:fileName filePath:nil fileData:fileData time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time
{
    self = [super initWithName:AUDIO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
        [self setFileData:fileData];
        [self setTimeLength:time];
    }
    return self;
}

#pragma mark - getters and setters
- (NSString *)fileName
{
    return [self attributeStringValueForName:FILE_NAME_ATTRIBUTE_NAME];
}

- (void)setFileName:(NSString *)fileName
{
    if (!fileName) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileName, FILE_NAME_ATTRIBUTE_NAME);
}

- (NSString *)filePath
{
    return [self attributeStringValueForName:FILE_PATH_ATTRIBUTE_NAME];
}

- (void)setFilePath:(NSString *)filePath
{
    if (!filePath) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(filePath, FILE_PATH_ATTRIBUTE_NAME);
}

- (NSData *)fileData
{
    NSData *data = nil;
    
    NSString *dataString = [self stringValue];
    
    if (dataString) {
        NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        data = [base64Data xmpp_base64Decoded];
    }
    
    return data;
}

- (void)setFileData:(NSData *)fileData
{
    XMPP_SUB_MSG_SET_STRING_VALUE([fileData xmpp_base64Encoded]);
}

- (NSTimeInterval)timeLength
{
    return [self attributeDoubleValueForName:TIME_LENGTH_ATTRIBUTE_NAME];
}

- (void)setTimeLength:(NSTimeInterval)timeLength
{
    XMPP_SUB_MSG_SET_DOUBLE_ATTRIBUTE(timeLength, TIME_LENGTH_ATTRIBUTE_NAME);
}

@end
