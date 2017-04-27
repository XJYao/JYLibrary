//
//  XAlertContainer.m
//  JYLibrary
//
//  Created by XJY on 15/8/25.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XAlertContainer.h"
#import "XTimer.h"
#import "XAnimation.h"
#import "XTool.h"
#import "UIColor+XColor.h"
#import "NSArray+XArray.h"

const UIWindowLevel UIWindowLevelXAlertContainerBackground = 1998.0; // below the alert window, default.





#pragma mark - XAlertContainerBackgroundWindow

@interface XAlertContainerBackgroundWindow : UIWindow

@property (nonatomic, assign) XAlertContainerBackgroundStyle style;
@property (nonatomic, strong) UIColor   *containerBackgroundColor;

@end

@implementation XAlertContainerBackgroundWindow

- (instancetype)initWithFrame:(CGRect)frame style:(XAlertContainerBackgroundStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self setStyle:style];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self setOpaque:NO];
        [self setWindowLevel:UIWindowLevelXAlertContainerBackground];
    }
    return self;
}

- (void)initialize {
    _containerBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (_style) {
        case XAlertContainerBackgroundStyleGradient: {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = NULL;
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};

            BOOL useDefaultColors = YES;
            
            if (_containerBackgroundColor) {
                NSArray *colors = [UIColor getRGBFromColor:_containerBackgroundColor];
                if (![XTool isArrayEmpty:colors]) {
                    CGFloat alpha = [[colors x_objectAtIndex:3] floatValue];
                    if (alpha >= 0) {
                        CGFloat newColors[8] = {0.0f, 0.0f, 0.0f, 0.0f, [[colors x_objectAtIndex:0] floatValue], [[colors x_objectAtIndex:1] floatValue], [[colors x_objectAtIndex:2] floatValue], alpha};
                        gradient = CGGradientCreateWithColorComponents(colorSpace, newColors, locations, locationsCount);
                        useDefaultColors = NO;
                    }
                }
            }
            
            if (useDefaultColors || !gradient) {
                CGFloat defaultColors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
                gradient = CGGradientCreateWithColorComponents(colorSpace, defaultColors, locations, locationsCount);
            }

            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
        case XAlertContainerBackgroundStyleSolid: {
            if (_containerBackgroundColor) {
                [_containerBackgroundColor set];
            } else {
                [[UIColor colorWithWhite:0 alpha:0.5] set];
            }
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end






#pragma mark - XAlertContainerController

@interface XAlertContainerController : UIViewController

@property (nonatomic, strong) UIView *alertView;

@end

@implementation XAlertContainerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_alertView setNeedsLayout];
}

@end





#pragma mark - XAlertContainer

static XAlertContainerBackgroundWindow  * backgroundWindow;

@implementation XAlertContainer {
    UITapGestureRecognizer  *   alertTapGesture;
    XTimer  *   _timer;

    UIView  *   customView;
}

#pragma mark ---------- Public ----------

- (instancetype)initWithCustomView:(UIView *)view {
    self = [super init];
    if (self) {
        [self initialize:view];
    }
    return self;
}

- (void)show {
    [backgroundWindow makeKeyAndVisible];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [backgroundWindow setAlpha:1];
                     }];

    [XAnimation animationEaseInEaseOut:customView duration:0.5];
    
    if (_enableAutoHide) {
        __weak __typeof(self) weakSelf = self;
        
        _timer = [XTimer startTimerMSecWithBeginTime:0 endTime:_timeout perTime:1000 begin:nil progress:nil finished:^{
            
            [weakSelf hide];
            
        } stop:nil];
    }
}

- (void)hide {
    if (_timer) {
        [_timer stopTimer];
        _timer = nil;
    }
    [customView.layer removeAllAnimations];
    for (UIView *subView in customView.subviews) {
        [subView removeFromSuperview];
    }
    [customView removeFromSuperview];

    [self removeBackgroundWindow];
    
    if(_delegate && [_delegate respondsToSelector:@selector(xAlertContainerWasHidden:)]) {
        [_delegate xAlertContainerWasHidden:self];
    }
    
    if (_enableAutoHide) {
        if(_delegate && [_delegate respondsToSelector:@selector(xAlertContainerWasAutoHidden:)]) {
            [_delegate xAlertContainerWasAutoHidden:self];
        }
    }
}

#pragma mark ---------- Private ----------

- (void)initialize:(UIView *)view {
    _enableAutoHide = NO;
    _enableTapGestureHide = NO;
    
    _timeout = 2000;
    
    customView = view;

    [self removeBackgroundWindow];

    XAlertContainerController *containerViewController = [[XAlertContainerController alloc] init];
    [containerViewController.view setBackgroundColor:[UIColor clearColor]];
    [containerViewController.view addSubview:customView];
    [containerViewController setAlertView:customView];
    
    backgroundWindow = [[XAlertContainerBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds style:XAlertContainerBackgroundStyleGradient];
    [backgroundWindow setAlpha:0];
    [backgroundWindow setRootViewController:containerViewController];
}

- (void)removeBackgroundWindow {
    if (backgroundWindow) {
        [backgroundWindow setAlpha:0];
        
        for (UIView *view in backgroundWindow.subviews) {
            [view removeFromSuperview];
        }
        
        [backgroundWindow setRootViewController:nil];
        [backgroundWindow removeFromSuperview];
        backgroundWindow = nil;
    }
}

- (void)setStyle:(XAlertContainerBackgroundStyle)style {
    _style = style;
    [backgroundWindow setStyle:_style];
    [backgroundWindow setNeedsDisplay];
}

- (void)setContainerBackgroundColor:(UIColor *)containerBackgroundColor {
    _containerBackgroundColor = containerBackgroundColor;
    [backgroundWindow setContainerBackgroundColor:_containerBackgroundColor];
    [backgroundWindow setNeedsDisplay];
}

- (void)setEnableAutoHide:(BOOL)enableAutoHide {
    _enableAutoHide = enableAutoHide;
}

- (void)setEnableTapGestureHide:(BOOL)enableTapGestureHide {
    _enableTapGestureHide = enableTapGestureHide;
    
    if (_enableTapGestureHide) {
        alertTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [backgroundWindow.rootViewController.view addGestureRecognizer:alertTapGesture];
    } else {
        if (alertTapGesture) {
            [backgroundWindow.rootViewController.view removeGestureRecognizer:alertTapGesture];
            alertTapGesture = nil;
        }
    }
}

- (UIView *)containerView {
    return backgroundWindow.rootViewController.view;
}

@end
