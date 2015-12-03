//
//  NSDate+NSString.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSString)

- (NSString *)DateToString;
- (NSString *)LocalDateToUTCString;


- (NSDate *)UTCDateToLocalDate;
- (NSDate *)LocalDateToUTCDate;

@end
