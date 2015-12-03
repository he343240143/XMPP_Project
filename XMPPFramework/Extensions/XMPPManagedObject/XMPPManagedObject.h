//
//  XMPPManagedObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/6/4.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface XMPPManagedObject : NSManagedObject

- (NSMutableDictionary *)propertyTransformDictionary;

@end
