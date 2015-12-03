//
//  XMPPPictureMessageObject.m
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPPictureMessageObject.h"
#import <objc/runtime.h>
#import "NSData+XMPP.h"


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_DATA_ATTRIBUTE_NAME            @"fileData"
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"
#define ASPECT__RATIO_ATTRIBUTE_NAME        @"aspectRatio"

@implementation XMPPPictureMessageObject
//class init methods

+ (XMPPPictureMessageObject *)xmppPictureMessageObject
{
    NSXMLElement *audioElement = [NSXMLElement elementWithName:PICTURE_ELEMENT_NAME];
    return [XMPPPictureMessageObject xmppPictureMessageObjectFromElement:audioElement];
}
+(XMPPPictureMessageObject*)xmppPictureMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPPictureMessageObject class]);
    return (XMPPPictureMessageObject *)element;
}
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    XMPPPictureMessageObject *xmppPictureMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:PICTURE_ELEMENT_NAME];
    if (element) {
        xmppPictureMessageObject = [XMPPPictureMessageObject xmppPictureMessageObjectFromElement:element];
    }
    
    return xmppPictureMessageObject;
}

+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [XMPPPictureMessageObject xmppPictureMessageObjectWithFileName:nil filePath:filePath fileData:fileData aspectRatio:aspectRatio];
}
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [XMPPPictureMessageObject xmppPictureMessageObjectWithFileName:nil filePath:nil fileData:fileData aspectRatio:aspectRatio];
}

+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    XMPPPictureMessageObject *xmppPictureMessageObject = nil;
    xmppPictureMessageObject = [[XMPPPictureMessageObject alloc] initWithFileName:fileName filePath:filePath fileData:fileData aspectRatio:aspectRatio];
    [xmppPictureMessageObject setFileName:fileName];
    [xmppPictureMessageObject setFilePath:filePath];
    [xmppPictureMessageObject setFileData:fileData];
    [xmppPictureMessageObject setAspectRatio:aspectRatio];
    
    return xmppPictureMessageObject;
}

//object init objects
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    self = [super initWithName:PICTURE_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
        [self setFileData:fileData];
        
    }
    return self;
}
- (instancetype)initWithFlePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    return [self initWithFileName:nil filePath:filePath fileData:fileData aspectRatio:aspectRatio];
}
- (instancetype)initWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return  [self initWithFlePath:nil fileData:fileData aspectRatio:aspectRatio];
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
-(void)setAspectRatio:(CGFloat)aspectRatio
{
   
    XMPP_SUB_MSG_SET_FLOAT_ATTRIBUTE(aspectRatio, ASPECT__RATIO_ATTRIBUTE_NAME);
}
-(CGFloat)aspectRatio
{
    return [self attributeFloatValueForName:ASPECT__RATIO_ATTRIBUTE_NAME];
}


@end
