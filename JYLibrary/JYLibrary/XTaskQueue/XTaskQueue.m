//
//  XTaskQueue.m
//  JYLibrary
//
//  Created by XJY on 16/4/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XTaskQueue.h"
#import "XTask.h"

@interface XTaskQueue () {
    NSMutableDictionary *taskDictionary;
}

@end

@implementation XTaskQueue

- (instancetype)init {
    self = [super init];
    
    if (self) {
        taskDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addTask:(XTask *)task forKey:(NSString *)key {
    [taskDictionary x_setObject:task forKey:key];
    
    [task completion:^{
        if ([self hasTaskForKey:key]) {
            [taskDictionary removeObjectForKey:key];
        }
    }];
}

- (void)addTasks:(NSArray<XTask *> *)tasks forkeys:(NSArray<NSString *> *)keys {
    for (NSInteger i = 0; i < tasks.count; i ++) {
        XTask *task = [tasks x_objectAtIndex:i];
        NSString *key = [keys x_objectAtIndex:i];
        
        [self addTask:task forKey:key];
    }
}

- (void)cancelTaskForKey:(NSString *)key {
    if (![taskDictionary.allKeys containsObject:key]) {
        return;
    }
    XTask *task = [taskDictionary objectForKey:key];
    if (task) {
        [task setCancel:YES];
    }
    [taskDictionary removeObjectForKey:key];
}

- (void)cancelAllTasks {
    for (NSString *key in taskDictionary.allKeys) {
        XTask *task = [taskDictionary objectForKey:key];
        if (task) {
            [task setCancel:YES];
        }
    }
    [taskDictionary removeAllObjects];
}

- (BOOL)hasTaskForKey:(NSString *)key {
    if (![taskDictionary.allKeys containsObject:key]) {
        return NO;
    }
    
    return YES;
}

@end
