//
//  NSDate+NSString.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "NSDate+NSString.h"

@implementation NSDate (NSString)

- (NSString *)LocalDateToUTCString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}

- (NSDate *)LocalDateToUTCDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone localTimeZone];
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
    
    return destinationDate;
}

- (NSDate *)UTCDateToLocalDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
    return destinationDate;
}

- (NSString *)DateToString
{
    //NSDate 2 NSString
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:self];
    return strDate;
}


@end
