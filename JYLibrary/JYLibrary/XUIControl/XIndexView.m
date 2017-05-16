//
//  XIndexView.m
//  JYLibrary
//
//  Created by XJY on 16/11/7.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XIndexView.h"


@interface XIndexView ()

@property (nonatomic, strong) NSTimer *timer;

@end


@implementation XIndexView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextColor:[UIColor whiteColor]];
        [self setFont:[UIFont systemFontOfSize:30]];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.0];
        [self.layer setCornerRadius:10.0];
    }
    return self;
}

+ (void)show:(NSString *)text onView:(UIView *)view {
    if (!view) {
        return;
    }

    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            XIndexView *label = (XIndexView *)subView;
            [label setAlpha:0];
            [label removeFromSuperview];
            [label.timer invalidate];
            label.timer = nil;
            break;
        }
    }

    XIndexView *label = [[XIndexView alloc] init];
    [label setText:text];
    [view addSubview:label];

    CGFloat width = 80;
    CGFloat height = width;
    CGFloat x = (view.frame.size.width - width) / 2.0;
    CGFloat y = (view.frame.size.height - height) / 2.0;
    CGRect frame = CGRectMake(x, y, width, height);
    [label setFrame:frame];

    label.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:label selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hide {
    if (self.alpha == 0 || !self.superview) {
        return;
    }

    __weak typeof(self) weak_self = self;

    [UIView animateWithDuration:0.5 animations:^{
        [weak_self setAlpha:0];
    } completion:^(BOOL finished) {
        if (finished) {
            [weak_self removeFromSuperview];
        }
    }];
}

@end
