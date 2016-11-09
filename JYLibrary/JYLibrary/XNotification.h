//
//  XNotification.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNotification : NSObject

+ (instancetype)sharedManager;

#pragma mark - notification center

/**
 添加通知
 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

/**
 移除通知
 */
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

/**
 移除所有通知
 */
- (void)removeAllObservers;

#pragma mark - KVO

/**
 添加KVO
 */
- (void)addKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

/**
 移除KVO
 */
- (void)removeKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath context:(void *)context;

- (void)removeKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath;

/**
 移除所有KVO
 */
- (void)removeAllKVO;

#pragma mark - notification
/**
 在主线程发送通知
 */
+ (void)sendNotificationOnMainThread:(NSString *)notificationName withObject:(id)object;

/**
 在当前线程发送通知
 */
+ (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 在新的线程发送通知
 */
+ (void)sendNotificationOnNewThread:(NSString *)notificationName withObject:(id)object;

#pragma mark - push
/**
 设置角标
 */
+ (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber;

/**
 清空通知栏
 */
+ (void)clearNotification;

/**
 注册远程推送
 */
+ (void)registerRemoteNotification;

/**
 IOS8 注册推送授权
 */
+ (void)registerUserNotification;

/**
 本地推送通知
 */
+ (void)alertLocalNotification:(NSString *)alertBody alertAction:(NSString *)alertAction userInfo:(NSDictionary *)userInfo interval:(double)interval;

@end
