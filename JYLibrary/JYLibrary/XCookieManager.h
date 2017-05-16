//
//  XCookieManager.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XCookieManager : NSObject

/**
 获取所有的cookie
 */
+ (NSArray *)getAllCookies;

/**
 根据cookie名称中指定关键字获取cookie
 */
+ (NSHTTPCookie *)getCookieWithKeywordInName:(NSString *)keyword;

/**
 根据cookie名获取cookie
 */
+ (NSHTTPCookie *)getCookieWithName:(NSString *)name;

/**
 添加cookie
 */
+ (void)addCookie:(NSHTTPCookie *)cookie;

/**
 根据cookie名称中指定关键字移除cookie
 */
+ (void)removeCookieWithKeywordInName:(NSString *)keyword;

/**
 移除指定cookie
 */
+ (void)removeCookie:(NSHTTPCookie *)cookie;

/**
 移除所有cookie
 */
+ (void)clearCookies;

@end
