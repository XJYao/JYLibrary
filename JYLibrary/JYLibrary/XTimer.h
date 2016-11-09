//
//  XTimer.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef dispatch_source_t   XGCDTimer;

typedef void (^TimerBeginBlock)     (void);
typedef void (^TimerProgressBlock)  (NSInteger timerProgress);
typedef void (^TimerFinishedBlock)  (void);
typedef void (^TimerStopBlock)      (NSInteger timerProgress);

typedef NS_ENUM(NSInteger, XTimeType) {
    XTimeTypeMSec   =   NSEC_PER_MSEC,
    XTimeTypeSec    =   NSEC_PER_SEC
};

@interface XTimer : NSObject

@property (nonatomic, assign) XGCDTimer timer;

/**
 启动定时器, 毫秒级, 有超时
 */
+ (XTimer *)startTimerMSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

- (XGCDTimer)startTimerMSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 秒级, 有超时
 */
+ (XTimer *)startTimerSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

- (XGCDTimer)startTimerSecWithBeginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 毫秒级, 无超时, 加计数
 */
+ (XTimer *)startTimerMSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

- (XGCDTimer)startTimerMSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 秒级, 无超时, 加计数
 */
+ (XTimer *)startTimerSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

- (XGCDTimer)startTimerSecIncreaseWithBeginTime:(NSInteger)beginTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器
 */
+ (XTimer *)startTimerWithTimeType:(XTimeType)timeType beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

- (XGCDTimer)startTimerWithTimeType:(XTimeType)timeType beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime perTime:(NSInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 停止定时器
 */
- (void)stopTimer:(XGCDTimer)currentTimer;

- (void)stopTimer;

@end
