//
//  XMPPCloudCoreDataStorage.h
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

@interface XMPPCloudCoreDataStorage : XMPPCoreDataStorage
{
    // Inherits protected variables from XMPPCoreDataStorage
}

+ (instancetype)sharedInstance;

@end
