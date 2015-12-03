//
//  NSString+NSDate.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "NSString+NSDate.h"

@implementation NSString (NSDate)

- (NSString *)LocalDateStringToUTCString
{
    //将本地日期字符串转为UTC日期字符串
    //本地日期格式:2013-08-03 12:53:51
    //可自行指定输入输出格式
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:self];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
- (NSString *)UTCDateStringToLocalDateString
{
    //将UTC日期字符串转为本地时间字符串
    //输入的UTC日期格式2013-08-03T04:53:51+0000
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:self];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
/**
 *  Get the local date object with the given UTC date string
 *
 *  @param utc The utc date string
 *
 *  @return The local date obejct we will get
 */
- (NSDate *)UTCStringToLocalDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *ldate = [dateFormatter dateFromString:self];
    return ldate;
}
/**
 *  Get the date obejct With the given date string
 *
 *  @param strdate The given date string
 *
 *  @return The Date object we will get
 */
- (NSDate *)StringToDate
{
    //NSString 2 NSDate
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *retdate = [dateFormatter dateFromString:self];
    return retdate;
}
@end
