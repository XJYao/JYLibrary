//
//  XThread.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/**
 是否是主线程
 */
static inline bool x_dispatch_is_main() {
    return pthread_main_np() != 0;
}

/**
 在主线程同步执行语句块
 */
static inline void x_dispatch_main_sync(dispatch_block_t block) {
    if (x_dispatch_is_main()) {
        if (block) {
            block();
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/**
 异步到主线程执行语句块
 */
static inline void x_dispatch_main_async(dispatch_block_t block) {
    if (x_dispatch_is_main()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 创建子线程，默认优先级
 */
static inline void x_dispatch_async_default(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

/**
 创建子线程，高优先级
 */
static inline void x_dispatch_async_high(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

/**
 创建子线程，低优先级
 */
static inline void x_dispatch_async_low(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}

/**
 同步执行代码块，执行完才继续执行该线程其他任务
 */
static inline void x_dispatch_sync_default(dispatch_block_t block) {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

static inline void x_dispatch_sync_high(dispatch_block_t block) {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

static inline void x_dispatch_sync_low(dispatch_block_t block) {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}

/**
 如果是主线程，则异步到子线程；
 如果是子线程，则保持在当前线程执行。
 */
static inline void x_dispatch_async_excuting(dispatch_block_t block) {
    if (x_dispatch_is_main()) {
        x_dispatch_async_default(^{
            if (block) {
                block();
            }
        });
    } else {
        if (block) {
            block();
        }
    }
}

@interface XThread : NSObject

typedef void (^WaitSignal)(void);
typedef void (^SendSignal)(void);

/**
 用信号量实现的线程数可控的方法
 */
+ (void)semaphoreCreate:(NSInteger)maxNumber executingBlock:(void (^)(WaitSignal waitSignal, SendSignal sendSignal))executingBlock;

- (dispatch_semaphore_t)semaphoreCreate:(NSInteger)maxNumber;

- (void)semaphoreWait;

- (void)semaphoreSignal;

@end
