//
//  SimpleMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPAdditionalCoreDataMessageObject.h"
#import "XMPPFramework.h"
#import "NSData+XMPP.h"

#define MESSAGE_TEXT_ELEMENT_NAME           @"messageText"
#define FILE_PATH_ELEMENT_NAME              @"filePath"
#define FILE_NAME_ELEMENT_NAME              @"fileName"
#define FILE_DATA_ELEMENT_NAME              @"fileData"
#define LATITUDE_ELEMENT_NAME               @"latitude"
#define LONGITUDE_ELEMENT_NAME              @"longitude"
#define GROUP_USERJID_ELEMENT_NAME          @"groupUserJid"
#define TIME_LENGTH_ELEMENT_NAME            @"timeLength"
#define ASPECT_RATIO_USERJID_ELEMENT_NAME   @"aspectRatio"
#define MESSAGE_TAG_ELEMENT_NAME            @"messageTag"

@implementation XMPPAdditionalCoreDataMessageObject

#pragma mark -
#pragma mark - Public  Methods

-(instancetype)initWithDictionary:(NSMutableDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self fromDictionary:dictionary];
    }
    return self;
}
-(instancetype)initWithInfoXMLElement:(NSXMLElement *)element
{
    self = [super init];
    if (self) {
        [self fromInfoXMLElement:element];
    }
    return self;
}
-(NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.messageText)
        [dictionary setObject:self.messageText forKey:@"messageText"];
    
    if (self.filePath)
        [dictionary setObject:self.filePath forKey:@"filePath"];
    
    if (self.longitude)
        [dictionary setObject:self.longitude forKey:@"longitude"];
    if (self.latitude)
        [dictionary setObject:self.latitude forKey:@"latitude"];
    if (self.fileName)
        [dictionary setObject:self.fileName forKey:@"fileName"];
    if (self.fileData)
        [dictionary setObject:[self.fileData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"fileData"];
    if (self.groupUserJid)
        [dictionary setObject:self.groupUserJid forKey:@"groupUserJid"];
    
    [dictionary setObject:[NSNumber numberWithDouble:self.timeLength] forKey:@"timeLength"];
    [dictionary setObject:[NSNumber numberWithFloat:self.aspectRatio] forKey:@"aspectRatio"];
    [dictionary setObject:[NSNumber numberWithBool:self.messageTag] forKey:@"messageTag"];
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary *)message
{
    self.messageText = [message objectForKey:@"messageText"];
    self.filePath = [message objectForKey:@"filePath"];
    self.timeLength = [(NSNumber *)[message objectForKey:@"timeLength"] doubleValue];
    self.longitude = [message objectForKey:@"longitude"];
    self.latitude = [message objectForKey:@"latitude"];
    self.fileName = [message objectForKey:@"fileName"];
    self.groupUserJid = [message objectForKey:@"groupUserJid"];
#warning initWithBase64Encoding only used in the system version more than 7.0
    if ([message objectForKey:@"fileData"])
        self.fileData = [[NSData alloc] initWithBase64EncodedString:[message objectForKey:@"fileData"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    self.aspectRatio = [(NSNumber *)[message objectForKey:@"aspectRatio"] floatValue];
    self.messageTag = [(NSNumber *)[message objectForKey:@"messageTag"] boolValue];
}

-(void)fromInfoXMLElement:(NSXMLElement *)infoXMLElement
{
    if (![[infoXMLElement name] isEqualToString:MESSAGE_ELEMENT_NAME] || ![[infoXMLElement xmlns] isEqualToString:MESSAGE_ELEMENT_XMLNS]) {
        return;
    }
    
    NSUInteger messageType = [infoXMLElement attributeUnsignedIntegerValueForName:@"type"];
    BOOL isGroupChat = [infoXMLElement attributeBoolValueForName:@"groupChat"];
    
    if (isGroupChat) {
        self.groupUserJid = [[infoXMLElement elementForName:@"sender"] stringValue];
    }
    
    switch (messageType) {
        case XMPPExtendMessageTextType:
        {
        
            NSXMLElement *text = [infoXMLElement elementForName:TEXT_ELEMENT_NAME];
            self.messageText = [text stringValue];
        }
            break;
        case XMPPExtendMessageAudioType:
        {
            NSXMLElement *audio = [infoXMLElement elementForName:AUDIO_ELEMENT_NAME];
            self.fileName = [audio attributeStringValueForName:@"fileName"];
            self.filePath = [audio attributeStringValueForName:@"filePath"];
            self.timeLength = [audio attributeDoubleValueForName:@"timeLength"];
            
            NSString *dataString = [audio stringValue];
            
            if (dataString) {
                NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
                self.fileData = [base64Data xmpp_base64Decoded];
            }
        }
            break;
        case XMPPExtendMessageVideoType:
        {
            
            NSXMLElement *video = [infoXMLElement elementForName:VIDEO_ELEMENT_NAME];
            self.fileName = [video attributeStringValueForName:@"fileName"];
            self.filePath = [video attributeStringValueForName:@"filePath"];
            self.timeLength = [video attributeDoubleValueForName:@"timeLength"];
            
            NSString *dataString = [video stringValue];
            
            if (dataString) {
                NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
                self.fileData = [base64Data xmpp_base64Decoded];
            }
        }
            break;
        case XMPPExtendMessagePictureType:
        {
            
            NSXMLElement *picture = [infoXMLElement elementForName:PICTURE_ELEMENT_NAME];
            self.fileName = [picture attributeStringValueForName:@"fileName"];
            self.filePath = [picture attributeStringValueForName:@"filePath"];
            self.aspectRatio = [picture attributeDoubleValueForName:@"aspectRatio"];
            
            NSString *dataString = [picture stringValue];
            
            if (dataString) {
                NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
                self.fileData = [base64Data xmpp_base64Decoded];
            }
        }
            break;
        case XMPPExtendMessagePositionType:
        {
            
            NSXMLElement *location = [infoXMLElement elementForName:LOCATION_ELEMENT_NAME];
            self.longitude = [location attributeStringValueForName:@"longitude"];
            self.latitude = [location attributeStringValueForName:@"latitude"];
            self.messageText = [location stringValue];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    XMPPAdditionalCoreDataMessageObject *newObject = [[[self class] allocWithZone:zone] init];
    
    [newObject setMessageText:self.messageText];
    [newObject setMessageTag:self.messageTag];
    [newObject setFileData:self.fileData];
    [newObject setFileName:self.fileName];
    [newObject setFilePath:self.filePath];
    [newObject setTimeLength:self.timeLength];
    [newObject setGroupUserJid:self.groupUserJid];
    [newObject setLongitude:self.longitude];
    [newObject setLatitude:self.latitude];
    [newObject setAspectRatio:self.aspectRatio];
    
    return newObject;
}
#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.messageText forKey:@"messageText"];
    [aCoder encodeObject:self.fileData forKey:@"fileData"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.groupUserJid forKey:@"groupUserJid"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.messageTag] forKey:@"messageTag"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.timeLength] forKey:@"timeLength"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.aspectRatio] forKey:@"aspectRatio"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.messageText = [aDecoder decodeObjectForKey:@"messageText"];
        self.fileData = [aDecoder decodeObjectForKey:@"fileData"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
        self.groupUserJid = [aDecoder decodeObjectForKey:@"groupUserJid"];
        self.messageTag = [((NSNumber *)[aDecoder decodeObjectForKey:@"messageTag"]) boolValue];
        self.timeLength = [((NSNumber *)[aDecoder decodeObjectForKey:@"timeLength"]) doubleValue];
        self.aspectRatio = [((NSNumber *)[aDecoder decodeObjectForKey:@"aspectRatio"]) floatValue];
    }
    return  self;
}


@end
