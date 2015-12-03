//
//  XMPPChatRoomCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/25.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPChatRoom.h"
#import "XMPPChatRoomQueryModule.h"
#import "XMPPCoreDataStorage.h" 
#import "XMPPChatRoomCoreDataStorageObject.h"
#import "XMPPChatRoomUserCoreDataStorageObject.h"

@interface XMPPChatRoomCoreDataStorage : XMPPCoreDataStorage 
{
    NSMutableSet *chatRoomPopulationSet;
}

+ (instancetype)sharedInstance;


- (XMPPChatRoomCoreDataStorageObject *)chatRoomForID:(NSString *)id
                                      xmppStream:(XMPPStream *)stream
                            managedObjectContext:(NSManagedObjectContext *)moc;

@end
