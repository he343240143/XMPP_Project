//
//  XMPPAudioMessageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

#define AUDIO_ELEMENT_NAME                  @"audio"

@interface XMPPAudioMessageObject : XMPPBaseMessageSubObject

@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *filePath;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) NSTimeInterval    timeLength;

//class init methods
+ (XMPPAudioMessageObject *)xmppAudioMessageObject;
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFileData:(NSData *)fileData time:(NSTimeInterval)time;
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFilePath:(NSString *)filePath time:(NSTimeInterval)time;
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPAudioMessageObject *)xmppAudioMessageObjectFromInfoElement:(NSXMLElement *)infoElement;

//object init objects
- (instancetype)init;
- (instancetype)initWitFileData:(NSData *)fileData time:(NSTimeInterval)time;
- (instancetype)initWithFileName:(NSString *)fileName fileData:(NSData *)fileData time:(NSTimeInterval)time;
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData time:(NSTimeInterval)time;

@end
