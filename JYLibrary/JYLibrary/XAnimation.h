//
//  XAnimation.h
//  JYLibrary
//
//  Created by XJY on 15-8-7.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XAnimation : NSObject

#define kRadianToDegrees(radian) (radian * M_PI) / 180.0

/**
 淡入淡出
 */
+ (void)animationEaseInEaseOut:(UIView *)outView duration:(CFTimeInterval)duration;

/**
 开始执行动画
 */
+ (void)beginAnimation:(double)duration executingBlock:(void (^)(void))executingBlock;

/**
 开始执行动画, 带动画完成block
 */
+ (void)beginAnimation:(double)duration executingBlock:(void (^)(void))executingBlock completion:(void (^)(BOOL finished))completion;

/**
 旋转动画
 */
+ (CABasicAnimation *)rotation:(double)duration degree:(CGFloat)degree direction:(CGFloat)direction repeatCount:(float)repeatCount target:(id)target;

+ (void)animationFromBottomToTop:(UIView *)view duration:(double)duration executingBlock:(void (^)(void))executingBlock;

+ (void)animationFromTopToBottom:(UIView *)view duration:(double)duration executingBlock:(void (^)(void))executingBlock;

@end
