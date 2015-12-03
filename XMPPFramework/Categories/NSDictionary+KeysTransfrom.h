//
//  NSDictionary+KeysTransfrom.h
//  NSDictionaryTransformation
//
//  Created by  李天柱 on 15/6/4.
//  Copyright (c) 2015年  李天柱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KeysTransfrom)

- (NSDictionary *)destinationDictionaryWithNewKeysMapDic:(NSDictionary *)keysMapDictionary;

- (NSDictionary *)destinationDictionaryWithNewKeys:(NSArray *)newKeys
                                           oldKeys:(NSArray *)oldKeys;

- (void)transfromWithKeysMapDic:(NSDictionary *)keysMapDictionary
                completionBlock:(void (^)(NSDictionary *destinationDictionary))completionBlock;

- (void)transfromWithNewKeys:(NSArray *)newKeys
                     oldKeys:(NSArray *)oldKeys
             completionBlock:(void (^)(NSDictionary *destinationDictionary))completionBlock;

@end
