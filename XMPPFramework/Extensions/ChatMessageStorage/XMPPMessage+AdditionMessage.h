//
//  XMPPMessage+AdditionMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/27.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPFramework.h"

@interface XMPPMessage (AdditionMessage)

- (NSString *)messageID;
- (NSMutableDictionary *)toDictionaryWithSendFromMe:(BOOL)sendFromMe active:(BOOL)active;

@end
