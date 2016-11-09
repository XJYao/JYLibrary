//
//  XEncoding.h
//  JYLibrary
//
//  Created by XJY on 15/10/15.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XEncoding : NSObject

/**
 字符串编码
 */
+ (NSString *)encodeString:(NSString *)string encoding:(NSStringEncoding)encoding;

/**
 字符串解码
 */
+ (NSString *)decodeString:(NSString *)string encoding:(NSStringEncoding)encoding;

@end
