//
//  XTask.m
//  JYLibrary
//
//  Created by XJY on 16/4/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XTask.h"

@interface XTask () {
    XTaskCompletionBlock taskCompletionBlock;
}

@end

@implementation XTask

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _cancel = NO;
        _parameter = nil;
        _delaySec = 0;
        _delayMSec = 0;
        _delayUSec = 0;
    }
    
    return self;
}

- (void)dispatch_async:(dispatch_queue_t)queue block:(dispatch_block_t)block completion:(XTaskCompletionBlock)completionBlock {
    
    taskCompletionBlock = completionBlock;
    
    int64_t delay = 0;
    if (_delaySec > 0) {
        delay = (int64_t)(_delaySec * NSEC_PER_SEC);
    } else if (_delayMSec > 0) {
        delay = (int64_t)(_delayMSec * NSEC_PER_MSEC);
    } else if (_delayUSec > 0) {
        delay = (int64_t)(_delayUSec * NSEC_PER_USEC);
    }
    
    if (delay > 0) {
        dispatch_time_t delay_time = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delay_time, queue, ^{
            if (_cancel) {
                return;
            }
            if (taskCompletionBlock) {
                taskCompletionBlock();
            }
            
            if (block) {
                block();
            }
        });
    } else {
        dispatch_async(queue, ^{
            if (_cancel) {
                return;
            }
            if (taskCompletionBlock) {
                taskCompletionBlock();
            }
            
            if (block) {
                block();
            }
        });
    }
}

- (void)dispatch_async:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    [self dispatch_async:queue block:block completion:nil];
}

- (void)completion:(XTaskCompletionBlock)block {
    taskCompletionBlock = block;
}

@end
