//
//  XMPPMessage+AdditionMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/27.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessage+AdditionMessage.h"
#import "XMPPAdditionalCoreDataMessageObject.h"

@implementation XMPPMessage (AdditionMessage)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//In this method there is no streamBareJidStr
-(NSMutableDictionary *)toDictionaryWithSendFromMe:(BOOL)sendFromMe active:(BOOL)active
{
    NSXMLElement *info = nil;
    
    if (!(info = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]))  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSString *bareJidStr = sendFromMe ? [[self to] bare]:[[self from] bare];
    NSString *messageID = [info attributeStringValueForName:@"id"];
    NSNumber *unReadMessageCount = [NSNumber numberWithBool:(sendFromMe ? NO:!active)];//if read is 0(NO), unread is 1(YES)
    NSUInteger messageType = [info attributeUnsignedIntegerValueForName:@"type"];
    NSDate  *messageTime = sendFromMe ? [NSDate date]:[[info attributeStringValueForName:@"timestamp"] UTCStringToLocalDate];
    NSNumber *hasBeenRead = [NSNumber numberWithBool:(sendFromMe ? (unReadMessageCount > 0):!(unReadMessageCount > 0))];
    NSNumber *isGroupChat = [NSNumber numberWithBool:[info attributeBoolValueForName:@"groupChat"]];
    
    XMPPAdditionalCoreDataMessageObject *xmppAdditionalCoreDataMessageObject = [[XMPPAdditionalCoreDataMessageObject alloc] initWithInfoXMLElement:[self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]];
    
    if (bareJidStr) [dictionary setObject:bareJidStr forKey:@"bareJidStr"];
    
    if (messageTime) [dictionary setObject:messageTime forKey:@"messageTime"];
    
    if (xmppAdditionalCoreDataMessageObject) [dictionary setObject:xmppAdditionalCoreDataMessageObject forKey:@"additionalMessage"];
    
    
    
    [dictionary setObject:[NSNumber numberWithBool:sendFromMe] forKey:@"sendFromMe"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:messageType] forKey:@"messageType"];
    
    //The readed message's hasBeenRead is 1,unread is 0
    //When is sent from me,we should note that this message is been sent failed as default 0
    //After being sent succeed,we should modify this value into 1
    [dictionary setObject:hasBeenRead forKey:@"hasBeenRead"];
    
    //If the unread message count is equal to zero,we will know that this message has been readed
    [dictionary setObject:unReadMessageCount forKey:@"unReadMessageCount"];
    
    [dictionary setObject:messageID forKey:@"messageID"];
    [dictionary setObject:isGroupChat forKey:@"isGroupChat"];
    
    return dictionary;
}

- (NSString *)messageID
{
    NSXMLElement *info = nil;
    if (!(info = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]))  return nil;
    
    return [info attributeStringValueForName:@"id"];
}
@end
