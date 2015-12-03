//
//  XMPPVideoMessageObject.h
//  XMPP_Project
//
//  Created by yoolo on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

#define VIDEO_ELEMENT_NAME                  @"video"

@interface XMPPVideoMessageObject : XMPPBaseMessageSubObject

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSData *fileData;
@property (assign, nonatomic) NSTimeInterval timeLength;

//class init methods
+ (XMPPVideoMessageObject *)xmppVideoMessageObject;
+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileData:(NSData *)fileData time:(NSTimeInterval)time;
+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFilePath:(NSString *)filePath time:(NSTimeInterval)time;
+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;
+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;


+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromInfoElement:(NSXMLElement *)infoElement;

- (instancetype)init;
- (instancetype)initWithFileData:(NSData *)fileData time:(NSTimeInterval)time;
- (instancetype)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData time:(NSTimeInterval)time;
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;

@end
