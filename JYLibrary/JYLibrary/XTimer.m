//
//  XTimer.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTimer.h"


@interface XTimer ()
{
    __block NSInteger currentTime;

    TimerBeginBlock timerBeginBlock;
    TimerProgressBlock timerProgressBlock;
    TimerFinishedBlock timerFinishedBlock;
    TimerStopBlock timerStopBlock;
}

@end


@implementation XTimer

/**
 启动定时器, 毫秒级, 有超时
 */
+ (XTimer *)startTimerMSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeMSec beginTime:beginTime endTime:endTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

- (XGCDTimer)startTimerMSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeMSec beginTime:beginTime endTime:endTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

/**
 启动定时器, 秒级, 有超时
 */
+ (XTimer *)startTimerSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeSec beginTime:beginTime endTime:endTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

- (XGCDTimer)startTimerSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeSec beginTime:beginTime endTime:endTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

/**
 启动定时器, 毫秒级, 无超时, 加计数
 */
+ (XTimer *)startTimerMSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeMSec beginTime:beginTime endTime:beginTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

- (XGCDTimer)startTimerMSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeMSec beginTime:beginTime endTime:beginTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

/**
 启动定时器, 秒级, 无超时, 加计数
 */
+ (XTimer *)startTimerSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeSec beginTime:beginTime endTime:beginTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

- (XGCDTimer)startTimerSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    return [self startTimerWithTimeType:XTimeTypeSec beginTime:beginTime endTime:beginTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
}

/**
 启动定时器
 */
+ (XTimer *)startTimerWithTimeType:(XTimeType)timeType beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    XTimer *timerObj = [[XTimer alloc] init];

    [timerObj startTimerWithTimeType:timeType beginTime:beginTime endTime:endTime perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];

    return timerObj;
}

- (XGCDTimer)startTimerWithTimeType:(XTimeType)timeType beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    timerBeginBlock = beginBlock;
    timerProgressBlock = progressBlock;
    timerFinishedBlock = finishedBlock;
    timerStopBlock = stopBlock;

    NSInteger offset = beginTime - endTime;
    BOOL hasTimeout = (offset != 0);
    BOOL timeDirectionIncrease = (offset > 0 ? NO : YES);

    currentTime = beginTime;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (timerBeginBlock) {
            timerBeginBlock();
        }
    });

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(source_timer, dispatch_walltime(NULL, 0), perTime * timeType, 0);
    dispatch_source_set_event_handler(source_timer, ^{

        if (hasTimeout &&
            ((!timeDirectionIncrease && currentTime <= endTime) || (timeDirectionIncrease && currentTime >= endTime))) {
            dispatch_source_cancel(source_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger outputTime = currentTime;
                currentTime = 0;
                if (timerProgressBlock) {
                    timerProgressBlock(outputTime);
                }
                if (timerFinishedBlock) {
                    timerFinishedBlock();
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timerProgressBlock) {
                    timerProgressBlock(currentTime);
                }
                if (timeDirectionIncrease) {
                    currentTime += perTime;
                } else {
                    currentTime -= perTime;
                }
            });
        }
    });
    dispatch_resume(source_timer);
    _timer = source_timer;

    return source_timer;
}

/**
 停止定时器
 */
- (void)stopTimer:(XGCDTimer)currentTimer {
    if (!currentTimer) {
        return;
    }
    dispatch_source_cancel(currentTimer);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger outputTime = currentTime;
        currentTime = 0;
        if (timerStopBlock) {
            timerStopBlock(outputTime);
        }
    });
}

- (void)stopTimer {
    [self stopTimer:_timer];
}

@end
