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

@end
