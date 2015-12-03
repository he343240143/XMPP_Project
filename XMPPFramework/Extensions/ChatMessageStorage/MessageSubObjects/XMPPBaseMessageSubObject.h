//
//  XMPPBaseMessageSubObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSXMLElement+XMPP.h"

#define XMPP_SUB_MSG_SET_BOOL_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name boolValue:Value]
#define XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  stringValue:Value]
#define XMPP_SUB_MSG_SET_FLOAT_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  floatValue:Value]
#define XMPP_SUB_MSG_SET_DOUBLE_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  doubleValue:Value]
#define XMPP_SUB_MSG_SET_UNSIGEND_INREGER_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  unsignedIntegerValue:Value]
#define XMPP_SUB_MSG_SET_INREGER_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  integerValue:Value]
#define XMPP_SUB_MSG_SET_OBJECT_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  objectValue:Value]

#define XMPP_SUB_MSG_SET_STRING_VALUE(Value) [self setStringValue:Value]

#define XMPP_SUB_MSG_SET_EMPTY_CHILD(Set, Name)                                                                 \
                    if (Set) {                                                                                  \
                        [self addChild:[NSXMLElement elementWithName:(Name)]];                                  \
                    }                                                                                           \
                    else if (!(Set)) {                                                                          \
                        [self removeChildAtIndex:[[self children] indexOfObject:[self elementForName:(Name)]]]; \
                    }


#define XMPP_SUB_MSG_SET_STRING_CHILD(elementName , attributeKeys, attributeValues, Value)                                                                                           \
                    NSXMLElement *elem = [self elementForName:(Name)];                                          \
                    if (elem != nil) {                                                                          \
                        [self removeChildAtIndex:[[self children] indexOfObject:elem]];                         \
                    }                                                                                           \
                    elem = [NSXMLElement elementWithName:(Name)];                                               \
                    if (attributeKeys && attributeValues)                                                       \
                    {                                                                                           \
                        for (int index = 0; index < [attributeKeys count]; ++index) {                           \
                            [elem addAttributeWithName:[attributeKeys objectAtIndex:index] objectValue:[attributeValues objectAtIndex:index]];\
                        }                                                                                       \
                    }                                                                                           \
                    if ((Value) != nil)                                                                         \
                    {                                                                                           \
                        [elem setStringValue:(Value)];                                                          \
                    }                                                                                           \
                    [self addChild:elem];                                                                       \


@interface XMPPBaseMessageSubObject : NSXMLElement<NSCoding, NSCopying>

@end
