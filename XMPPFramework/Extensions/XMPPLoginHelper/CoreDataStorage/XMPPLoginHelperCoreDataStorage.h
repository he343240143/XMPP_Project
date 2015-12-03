//
//  XMPPLoginUserCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPCoreDataStorage.h"
#import "XMPPLoginHelper.h"

@interface XMPPLoginHelperCoreDataStorage : XMPPCoreDataStorage<XMPPLoginHelperStorage>
{
    // Inherits protected variables from XMPPCoreDataStorage
}

+ (instancetype)sharedInstance;

@end
