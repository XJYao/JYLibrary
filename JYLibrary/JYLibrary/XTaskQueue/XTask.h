//
//  XTask.h
//  JYLibrary
//
//  Created by XJY on 16/4/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XTask : NSObject

typedef void (^XTaskCompletionBlock)(void);

@property (nonatomic, assign) BOOL cancel;
@property (nonatomic, strong) id parameter;
@property (nonatomic, assign) int64_t delaySec;
@property (nonatomic, assign) int64_t delayMSec;
@property (nonatomic, assign) int64_t delayUSec;

- (void)dispatch_async:(dispatch_queue_t)queue block:(dispatch_block_t)block completion:(XTaskCompletionBlock)completionBlock;

- (void)dispatch_async:(dispatch_queue_t)queue block:(dispatch_block_t)block;

- (void)completion:(XTaskCompletionBlock)block;

@end
