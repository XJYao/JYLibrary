//
//  UIImageView+XImageView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIImageView+XImageView.h"
#import "XIOSVersion.h"

@implementation UIImageView (XImageView)

- (void)x_setTintColor:(UIColor *)tintColor {
    if ([XIOSVersion isIOS7OrGreater]) {
        [self setTintColor:tintColor];
    }
}

- (void)x_startImagesAnimating:(NSArray<UIImage *> *)images duration:(double)duration {
    [self setAnimationImages:images];
    [self setAnimationDuration:duration];
    [self setIsAccessibilityElement:YES];
    [self startAnimating];
}

@end
