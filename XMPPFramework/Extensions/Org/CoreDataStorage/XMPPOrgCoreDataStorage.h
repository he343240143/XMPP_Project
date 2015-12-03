//
//  XMPPOrganizationCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPFramework.h"

@interface XMPPOrgCoreDataStorage : XMPPCoreDataStorage
{
    // Inherits protected variables from XMPPCoreDataStorage
}

+ (instancetype)sharedInstance;

@end
