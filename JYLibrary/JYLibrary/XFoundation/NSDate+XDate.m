//
//  NSDate+XDate.m
//  JYLibrary
//
//  Created by XJY on 16/8/7.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSDate+XDate.h"


@implementation NSDate (XDate)

+ (NSDate *)dateWithSystemZone:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}

+ (NSDate *)zeroOfDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;

    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return localeDate;
}

@end
