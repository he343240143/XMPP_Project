//
//  NSDictionary+KeysTransfrom.m
//  NSDictionaryTransformation
//
//  Created by  李天柱 on 15/6/4.
//  Copyright (c) 2015年  李天柱. All rights reserved.
//

#import "NSDictionary+KeysTransfrom.h"

@implementation NSDictionary (KeysTransfrom)

- (NSDictionary *)destinationDictionaryWithNewKeysMapDic:(NSDictionary *)keysMapDictionary
{
    __block NSMutableDictionary *destinationDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    [keysMapDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id object = [destinationDictionary objectForKey:obj];
        
        if (object) {
            
            [destinationDictionary removeObjectForKey:obj];
            
            if (![object isKindOfClass:[NSNull class]]){
                [destinationDictionary setValue:object forKey:key];
            }
        }
    }];
    
    return destinationDictionary;
}

- (NSDictionary *)destinationDictionaryWithNewKeys:(NSArray *)newKeys
                                           oldKeys:(NSArray *)oldKeys
{
    NSAssert([newKeys count] == [oldKeys count], @"The new keys array count should been equal to the old keys array count");
    NSDictionary *keysMapDictionary = [NSDictionary dictionaryWithObjects:oldKeys forKeys:newKeys];
    __block NSMutableDictionary *destinationDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    [keysMapDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id object = [destinationDictionary objectForKey:obj];
        
        if (object) {
            
            [destinationDictionary removeObjectForKey:obj];
            
            if (![object isKindOfClass:[NSNull class]]){
                [destinationDictionary setValue:object forKey:key];
            }
            
        }
    }];
    
    return destinationDictionary;
}

- (void)transfromWithKeysMapDic:(NSDictionary *)keysMapDictionary
                completionBlock:(void (^)(NSDictionary *destinationDictionary))completionBlock
{
    __block NSMutableDictionary *destinationDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    [keysMapDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id object = [destinationDictionary objectForKey:obj];
        if (object) {
            
            [destinationDictionary removeObjectForKey:obj];
            
            if (![object isKindOfClass:[NSNull class]]){
                [destinationDictionary setValue:object forKey:key];
            }
            
        }
    }];
    
    if (completionBlock) completionBlock(destinationDictionary);
}

- (void)transfromWithNewKeys:(NSArray *)newKeys
                     oldKeys:(NSArray *)oldKeys
             completionBlock:(void (^)(NSDictionary *destinationDictionary))completionBlock
{
    NSAssert([newKeys count] == [oldKeys count], @"The new keys array count should been equal to the old keys array count");
    NSDictionary *keysMapDictionary = [NSDictionary dictionaryWithObjects:oldKeys forKeys:newKeys];
    __block NSMutableDictionary *destinationDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    [keysMapDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id object = [destinationDictionary objectForKey:obj];
        
        if (object) {
            
            [destinationDictionary removeObjectForKey:obj];
            
            if (![object isKindOfClass:[NSNull class]]){
                [destinationDictionary setValue:object forKey:key];
            }
            
        }
    }];
    
    if (completionBlock) completionBlock(destinationDictionary);
}
@end
