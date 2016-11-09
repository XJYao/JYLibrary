//
//  XLock.m
//  JYLibrary
//
//  Created by XJY on 15/11/10.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XLock.h"

@interface XLock () {
    NSLock *lock;
}

@end

@implementation XLock

//单例
+ (instancetype)sharedManager {
    static XLock *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[XLock alloc] init];
        });
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        lock = [[NSLock alloc] init];
    }
    
    return self;
}

- (void)lock {
    [lock lock];
}

- (void)unlock {
    [lock unlock];
}

@end
