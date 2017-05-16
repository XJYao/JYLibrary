//
//  XAlertContainer.h
//  JYLibrary
//
//  Created by XJY on 15/8/25.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XAlertContainerBackgroundStyle) {
    XAlertContainerBackgroundStyleGradient = 0,
    XAlertContainerBackgroundStyleSolid,
};

@class XAlertContainerController;
@class XAlertContainer;

@protocol XAlertContainerDelegate <NSObject>

@optional
- (void)xAlertContainerWasHidden:(XAlertContainer *)alertContainer;
- (void)xAlertContainerWasAutoHidden:(XAlertContainer *)alertContainer;

@end


@interface XAlertContainer : NSObject

@property (nonatomic, weak) id<XAlertContainerDelegate> delegate;
@property (nonatomic, assign) XAlertContainerBackgroundStyle style;
@property (nonatomic, strong) UIColor *containerBackgroundColor;

@property (nonatomic, assign) BOOL enableAutoHide;
@property (nonatomic, assign) BOOL enableTapGestureHide;

@property (nonatomic, assign) NSInteger timeout;

@property (nonatomic, strong, readonly) UIView *containerView;

- (instancetype)initWithCustomView:(UIView *)view;

- (void)show;

- (void)hide;

@end
