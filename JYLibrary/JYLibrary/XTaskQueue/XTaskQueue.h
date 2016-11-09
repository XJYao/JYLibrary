//
//  XTaskQueue.h
//  JYLibrary
//
//  Created by XJY on 16/4/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XTask;

@interface XTaskQueue : NSObject

- (void)addTask:(XTask *)task forKey:(NSString *)key;

- (void)addTasks:(NSArray<XTask *> *)tasks forkeys:(NSArray<NSString *> *)keys;

- (void)cancelTaskForKey:(NSString *)key;

- (void)cancelAllTasks;

- (BOOL)hasTaskForKey:(NSString *)key;

@end
