//
//  XIOSVersion.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XIOSVersion.h"
#import <UIKit/UIKit.h>

@implementation XIOSVersion

+ (double)systemVersion {
    static double sysVersion;
    static dispatch_once_t onceToken_systemVersion;
    dispatch_once(&onceToken_systemVersion, ^{
        sysVersion = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return sysVersion;
}

+ (double)iosVersion {
    static double version;
    static dispatch_once_t onceToken_iosVersion;
    dispatch_once(&onceToken_iosVersion, ^{
        version = floor(NSFoundationVersionNumber);
    });
    return version;
}

+ (BOOL)isIOS6OrGreater {
#ifdef NSFoundationVersionNumber_iOS_5_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_5_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS7OrGreater {
#ifdef NSFoundationVersionNumber_iOS_6_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_6_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS8OrGreater {
#ifdef NSFoundationVersionNumber_iOS_7_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_7_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS9OrGreater {
#ifdef NSFoundationVersionNumber_iOS_8_x_Max
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_8_x_Max) {
        return YES;
    } else {
        return NO;
    }
#else
    #ifdef NSFoundationVersionNumber_iOS_8_4
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_8_4) {
        return YES;
    } else {
        return NO;
    }
    #else
        return NO;
    #endif
#endif
}

+ (BOOL)isIOS10OrGreater {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_9_x_Max) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

@end
