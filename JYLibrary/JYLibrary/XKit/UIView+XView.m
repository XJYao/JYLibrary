//
//  UIView+XView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIView+XView.h"


@implementation UIView (XView)

- (void)x_setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [self setFrame:frame];
    }
}

- (void)x_setBounds:(CGRect)bounds {
    if (!CGRectEqualToRect(self.bounds, bounds)) {
        [self setBounds:bounds];
    }
}

- (void)x_setCenter:(CGPoint)center {
    if (!CGPointEqualToPoint(self.center, center)) {
        [self setCenter:center];
    }
}

- (void)x_setHidden:(BOOL)hidden {
    if (self.hidden != hidden) {
        [self setHidden:hidden];
    }
}

- (void)x_setAlpha:(CGFloat)alpha {
    if (self.alpha != alpha) {
        [self setAlpha:alpha];
    }
}

- (void)x_tapGestureWithTarget:(id)target action:(SEL)action {
    if (!self.userInteractionEnabled) {
        [self setUserInteractionEnabled:YES];
    }

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tapGesture];
}

@end
