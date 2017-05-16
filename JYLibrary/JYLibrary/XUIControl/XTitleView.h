//
//  XTitleView.h
//  XTitleView
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTitleViewDelegate <NSObject>

@optional
- (void)clickTitleViewLeftButton;
- (void)clickTitleViewRightButton;

@end


@interface XTitleView : UIView

@property (nonatomic, weak) id<XTitleViewDelegate> delegate;

@property (nonatomic, strong) UIFont *leftButtonFont;
@property (nonatomic, strong) UIColor *leftButtonNormalColor;
@property (nonatomic, strong) UIColor *leftButtonHighlightedColor;
@property (nonatomic, strong) UIImage *leftButtonNormalImage;
@property (nonatomic, strong) UIImage *leftButtonHighlightedImage;

@property (nonatomic, strong) UIFont *rightButtonFont;
@property (nonatomic, strong) UIColor *rightButtonNormalColor;
@property (nonatomic, strong) UIColor *rightButtonHighlightedColor;
@property (nonatomic, strong) UIImage *rightButtonNormalImage;
@property (nonatomic, strong) UIImage *rightButtonHighlightedImage;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIImage *backgroundImage;

/**
 设置按钮显示
 */
- (void)leftButtonHide;
- (void)leftButtonShowAll;
- (void)leftButtonOnlyShowText;
- (void)leftButtonOnlyShowImage;

- (void)rightButtonHide;
- (void)rightButtonShowAll;
- (void)rightButtonOnlyShowText;
- (void)rightButtonOnlyShowImage;

/**
 判断按钮显示
 */
- (BOOL)isLeftButtonHide;
- (BOOL)isLeftButtonShowAll;
- (BOOL)isLeftButtonOnlyShowText;
- (BOOL)isLeftButtonOnlyShowImage;

- (BOOL)isRightButtonHide;
- (BOOL)isRightButtonShowAll;
- (BOOL)isRightButtonOnlyShowText;
- (BOOL)isRightButtonOnlyShowImage;

/**
 设置文字
 */
- (void)setLeftButtonText:(NSString *)text;
- (void)setRightButtonText:(NSString *)text;
- (void)setTitleText:(NSString *)text;

/**
 获取文字
 */
- (NSString *)getLeftButtonText;
- (NSString *)getRightButtonText;
- (NSString *)getTitle;

@end
