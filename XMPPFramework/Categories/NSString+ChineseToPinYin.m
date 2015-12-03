//
//  NSString+ChineseToPinYin.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "NSString+ChineseToPinYin.h"
#import <CoreFoundation/CoreFoundation.h>

static const NSString *allChar = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@implementation NSString (ChineseToPinYin)

- (NSString *) chineseToPinYin
{
    if ([self isEqualToString:@""]) {
        
        return self;
        
    }
    
    NSMutableString *source = [self mutableCopy];
    
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    
    if ([[(NSString *)self substringToIndex:1] compare:@"长"] == NSOrderedSame){
        
        [source replaceCharactersInRange:NSMakeRange(0, 5)withString:@"chang"];
        
    }
    
    if ([[(NSString *)self substringToIndex:1] compare:@"沈"] == NSOrderedSame){

        [source replaceCharactersInRange:NSMakeRange(0, 4)withString:@"shen"];
        
    }
    
    if ([[(NSString *)self substringToIndex:1] compare:@"厦"] == NSOrderedSame){
        
        [source replaceCharactersInRange:NSMakeRange(0, 3)withString:@"xia"];
        
    }

    if ([[(NSString *)self substringToIndex:1] compare:@"地"] == NSOrderedSame){
        
        [source replaceCharactersInRange:NSMakeRange(0, 3)withString:@"di"];
        
    }
    
    if ([[(NSString *)self substringToIndex:1] compare:@"重"] == NSOrderedSame){
        
        [source replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chong"];
        
    }
    
    return source;
}

- (NSString *) firstLetter
{
    if ([self isEqualToString:@""]) return @"#";
    
    NSString *firstLetter = [[[self chineseToPinYin] substringToIndex:1] uppercaseString];
    
    return ([allChar rangeOfString:firstLetter].location == NSNotFound) ? @"#":firstLetter;
}

- (NSString *) pinyin_firstLetter
{
    if ([self isEqualToString:@""]) return @"#";
    
    NSString *firstLetter = [[self substringToIndex:1] uppercaseString];
    
    return ([allChar rangeOfString:firstLetter].location == NSNotFound) ? @"#":firstLetter;
}

@end
