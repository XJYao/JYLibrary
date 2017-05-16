//
//  XPhone.h
//  JYLibrary
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface XPhone : NSObject

/**
 获取电话接口地址
 */
+ (NSURL *)getTelUrl:(NSString *)phoneNumber;

/**
 获取发送短信接口地址
 */
+ (NSURL *)getSmsUrl:(NSString *)phoneNumber;

/**
 打电话,通话结束后不可返回
 */
+ (BOOL)callTelephone:(NSString *)phoneNumber;

/**
 打电话,通话结束后可返回,通过UIWebview实现
 */
+ (void)callTelephone:(NSString *)phoneNumber atSuper:(UIView *)superView;

/**
 发短信
 */
+ (BOOL)sendSms:(NSString *)phoneNumber;

/**
 调用默认邮箱客户端
 */
+ (BOOL)openEmail:(NSString *)email;

/**
 调用默认浏览器
 */
+ (BOOL)openBrowserWithString:(NSString *)urlStr;

+ (BOOL)openBrowserWithUrl:(NSURL *)url;

/**
 跳转到指定应用
 */
+ (void)openURLWithString:(NSString *)url;

+ (void)openURL:(NSURL *)url;

/**
 跳转到通讯录权限设置，需要添加URLScheme：prefs
 */
+ (BOOL)jumpToContactsService;

@end
