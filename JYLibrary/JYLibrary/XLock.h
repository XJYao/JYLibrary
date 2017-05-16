//
//  XLock.h
//  JYLibrary
//
//  Created by XJY on 15/11/10.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XLock : NSObject

/**
 单例
 */
+ (instancetype)sharedManager;

/**
 线程加锁
 */
- (void)lock;

/**
 线程解锁
 */
- (void)unlock;

@end
