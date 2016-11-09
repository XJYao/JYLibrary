//
//  XNetwork.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNetwork : NSObject

/**
 解析域名
 */
+ (struct hostent*)getHostByAddress:(NSString *)address;

/**
 根据域名解析出ip地址
 */
+ (NSString *)getIPWithHostName:(NSString *)hostName;

/**
 判断是否是域名
 */
+ (BOOL)isDomain:(NSString *)hostName;

@end
