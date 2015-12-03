//
//  XMPPChatMesageCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPCoreDataStorage.h"

@protocol XMPPAllMessageStorage;
@protocol XMPPAllMessageQueryModuleStorage;


@interface XMPPMessageCoreDataStorage : XMPPCoreDataStorage

+ (instancetype)sharedInstance;

@end
