//
//  XThread.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XThread.h"

@interface XThread () {
    dispatch_semaphore_t x_semaphore;
}

@end

@implementation XThread

+ (void)semaphoreCreate:(NSInteger)maxNumber executingBlock:(void (^)(WaitSignal, SendSignal))executingBlock {
    if (executingBlock) {
        
        XThread *x_thread = [[XThread alloc] init];
        [x_thread semaphoreCreate:maxNumber];
        executingBlock(
                       ^(void){[x_thread semaphoreWait];},
                       ^(void){[x_thread semaphoreSignal];}
                       );
        
    }
}

- (dispatch_semaphore_t)semaphoreCreate:(NSInteger)maxNumber {
    x_semaphore = dispatch_semaphore_create(maxNumber);
    
    return x_semaphore;
}

- (void)semaphoreWait {
    if (x_semaphore) {
        dispatch_semaphore_wait(x_semaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)semaphoreSignal {
    if (x_semaphore) {
        dispatch_semaphore_signal(x_semaphore);
    }
}

@end
