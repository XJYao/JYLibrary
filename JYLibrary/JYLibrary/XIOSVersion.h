//
//  XIOSVersion.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XIOSVersion : NSObject

+ (double)systemVersion;

+ (double)iosVersion;

+ (BOOL)isIOS6OrGreater;

+ (BOOL)isIOS7OrGreater;

+ (BOOL)isIOS8OrGreater;

+ (BOOL)isIOS9OrGreater;

+ (BOOL)isIOS10OrGreater;

@end
