//
//  UIView+XView.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XView)

- (void)x_setFrame:(CGRect)frame;

- (void)x_setBounds:(CGRect)bounds;

- (void)x_setCenter:(CGPoint)center;

- (void)x_setHidden:(BOOL)hidden;

- (void)x_setAlpha:(CGFloat)alpha;

/**
 手势点击事件
 */
- (void)x_tapGestureWithTarget:(id)target action:(SEL)action;

@end
