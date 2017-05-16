//
//  UIImageView+XImageView.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImageView (XImageView)

- (void)x_setTintColor:(UIColor *)tintColor;

/**
 启动图片动画
 */
- (void)x_startImagesAnimating:(NSArray<UIImage *> *)images duration:(double)duration;

@end
