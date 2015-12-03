//
//  XMPPPictureMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"
#define PICTURE_ELEMENT_NAME                  @"picture"

@interface XMPPPictureMessageObject : XMPPBaseMessageSubObject
@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *filePath;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) CGFloat           aspectRatio;      //Picture width&height

//class init methods
+ (XMPPPictureMessageObject *)xmppPictureMessageObject;
+ (XMPPPictureMessageObject*)xmppPictureMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectFromInfoElement:(NSXMLElement *)infoElement;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData  aspectRatio:(CGFloat)aspectRatio;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio;

//object init objects
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio;
- (instancetype)initWithFlePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio;
- (instancetype)initWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio;
@end
