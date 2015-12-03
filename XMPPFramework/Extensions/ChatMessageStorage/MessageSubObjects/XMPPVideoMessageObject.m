//
//  XMPPVideoMessageObject.m
//  XMPP_Project
//
//  Created by yoolo on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPVideoMessageObject.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_DATA_ATTRIBUTE_NAME            @"fileData"
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"
#define TIME_LENGTH_ATTRIBUTE_NAME          @"timeLength"

@implementation XMPPVideoMessageObject


+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromElement:(NSXMLElement *)element{
    
    object_setClass(element, [XMPPVideoMessageObject class]);
    return (XMPPVideoMessageObject *)element;
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromInfoElement:(NSXMLElement *)infoElement{
    
    XMPPVideoMessageObject *xmppVideoMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:VIDEO_ELEMENT_NAME];
    if (element) {
    
        xmppVideoMessageObject =         [XMPPVideoMessageObject xmppVideoMessageObjectFromInfoElement:element];
    }
    
    return xmppVideoMessageObject;
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObject{
    
    NSXMLElement *videoElement = [NSXMLElement elementWithName:VIDEO_ELEMENT_NAME];
    return [XMPPVideoMessageObject xmppVideoMessageObjectFromInfoElement:videoElement];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileData:(NSData *)fileData time:(NSTimeInterval)time{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFilePath:nil fileData:fileData time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFilePath:(NSString *)filePath time:(NSTimeInterval)time{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFilePath:filePath fileData:nil time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:nil filePath:filePath fileData:fileData time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time{
    
    XMPPVideoMessageObject *xmppVideoMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:VIDEO_ELEMENT_NAME];
    xmppVideoMessageObject = [XMPPVideoMessageObject xmppVideoMessageObjectFromElement:element];
    
    [xmppVideoMessageObject setFileName:fileName ];
    [xmppVideoMessageObject setFilePath:filePath];
    [xmppVideoMessageObject setFileData:fileData];
    [xmppVideoMessageObject setTimeLength:time];
    return xmppVideoMessageObject;
}



- (instancetype)init{
    return [self initWithFileData:nil time:0.0];
}
- (instancetype)initWithFileData:(NSData *)fileData time:(NSTimeInterval)time{
    return [self initWithFileName:nil fileData:fileData time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData time:(NSTimeInterval)time{
    return [self initWithFileName:fileName filePath:nil fileData:fileData time:time];
    
}
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time{
    
    self = [super initWithName:VIDEO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
        [self setFileData:fileData];
        [self setTimeLength:time];
        
    }
    return  self;
}



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
