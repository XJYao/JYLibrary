//
//  XTitleView.m
//  XTitleView
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTitleView.h"
#import "XTool.h"
#import "UILabel+XLabel.h"

#define maxLeftTextLength   2
#define leftControlTag      1
#define rightControlTag     2

@interface XTitleView() {
    UIImageView *backgroundImageView;
    
    UIControl *leftControl;
    UIControl *rightControl;
    UIImageView *leftImageView;
    UILabel *leftLabel;
    UIImageView *rightImageView;
    UILabel *rightLabel;
    UILabel *titleLabel;
}

@end

@implementation XTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addBackgroundImageView];
        [self addLeftControl];
        [self addRightControl];
        [self addTitleLabel];
        
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            [self updateFrame];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

- (void)initialize {
    [self setBackgroundColor:[UIColor blackColor]];

    _leftButtonFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _leftButtonNormalColor = [UIColor whiteColor];
    _leftButtonHighlightedColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1];
    _leftButtonNormalImage = nil;
    _leftButtonHighlightedImage = nil;
    
    _rightButtonFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _rightButtonNormalColor = [UIColor whiteColor];
    _rightButtonHighlightedColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1];
    _rightButtonNormalImage = nil;
    _rightButtonHighlightedImage = nil;
    
    _titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    _titleColor = [UIColor whiteColor];
    
    _backgroundImage = nil;
}

- (void)addBackgroundImageView {
    backgroundImageView = [[UIImageView alloc] init];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [backgroundImageView setImage:_backgroundImage];
    [self addSubview:backgroundImageView];
}

- (void)addLeftControl {
    leftControl = [[UIControl alloc] init];
    [leftControl setBackgroundColor:[UIColor clearColor]];
    [leftControl setTag:leftControlTag];
    [leftControl addTarget:self action:@selector(controlTouchToHighlighted:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter | UIControlEventTouchDragInside];
    [leftControl addTarget:self action:@selector(controlTouchToNormal:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchUpOutside];
    [leftControl addTarget:self action:@selector(controlTouchToEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftControl];
    
    leftImageView = [[UIImageView alloc] init];
    [leftImageView setBackgroundColor:[UIColor clearColor]];
    [leftImageView setImage:_leftButtonNormalImage];
    [leftControl addSubview:leftImageView];
    
    leftLabel = [[UILabel alloc] init];
    [leftLabel setBackgroundColor:[UIColor clearColor]];
    [leftLabel setTextAlignment:NSTextAlignmentCenter];
    [leftLabel setTextColor:_leftButtonNormalColor];
    [leftLabel setFont:_leftButtonFont];
    [leftLabel setText:@"返回"];
    [leftControl addSubview:leftLabel];
}

- (void)addRightControl {
    rightControl = [[UIControl alloc] init];
    [rightControl setBackgroundColor:[UIColor clearColor]];
    [rightControl setTag:rightControlTag];
    [rightControl addTarget:self action:@selector(controlTouchToHighlighted:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter | UIControlEventTouchDragInside];
    [rightControl addTarget:self action:@selector(controlTouchToNormal:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchUpOutside];
    [rightControl addTarget:self action:@selector(controlTouchToEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightControl];
    
    rightImageView = [[UIImageView alloc] init];
    [rightImageView setBackgroundColor:[UIColor clearColor]];
    [rightControl addSubview:rightImageView];
    
    rightLabel = [[UILabel alloc] init];
    [rightLabel setBackgroundColor:[UIColor clearColor]];
    [rightLabel setTextAlignment:NSTextAlignmentCenter];
    [rightLabel setTextColor:_rightButtonNormalColor];
    [rightLabel setFont:_rightButtonFont];
    [rightLabel setText:@""];
    [rightControl addSubview:rightLabel];
}

- (void)addTitleLabel {
    titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:_titleFont];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:_titleColor];
    [titleLabel setText:@""];
    [self addSubview:titleLabel];
}

- (void)updateBackgroundImageViewFrame {
    CGFloat backgroundImageViewWidth = 0;
    CGFloat backgroundImageViewHeight = 0;
    CGFloat backgroundImageViewX = 0;
    CGFloat backgroundImageViewY = 0;
    if (backgroundImageView.image != nil) {
        backgroundImageViewWidth = self.frame.size.width;
        backgroundImageViewHeight = self.frame.size.height;
    }
    [backgroundImageView setFrame:CGRectMake(backgroundImageViewX, backgroundImageViewY, backgroundImageViewWidth, backgroundImageViewHeight)];
}

- (void)updateLeftControlFrame {
    CGFloat leftControlWidth = 0;
    CGFloat leftControlHeight = 0;
    CGFloat leftControlX = 0;
    CGFloat leftControlY = statusBarOriginY;
    
    CGFloat leftImageViewWidth = 0;
    CGFloat leftImageViewHeight = 0;
    CGFloat leftImageViewX = 0;
    CGFloat leftImageViewY = 0;
    
    CGFloat leftLabelWidth = 0;
    CGFloat leftLabelHeight = 0;
    CGFloat leftLabelX = 0;
    CGFloat leftLabelY = 0;
    
    CGFloat offsetBetweenImageAndText = 5.0f;
    leftControlHeight = self.frame.size.height - statusBarOriginY;
    if (leftImageView.image) {
        leftImageViewWidth = leftImageView.image.size.width / 2.0;
        leftImageViewHeight = leftImageView.image.size.height / 2.0;
        leftImageViewX = offsetBetweenImageAndText;
        leftImageViewY = (leftControlHeight - leftImageViewHeight) / 2.0;
    }
    CGSize leftLabelSize = [leftLabel labelSize];
    leftLabelWidth = (leftLabel.text.length > maxLeftTextLength) ? ((leftLabelSize.width * 1.0 / leftLabel.text.length) * maxLeftTextLength) : leftLabelSize.width;
    leftLabelHeight = leftLabelSize.height;
    if (leftImageViewWidth <= 0 || leftImageView.hidden) {
        leftLabelX = offsetBetweenImageAndText * 2;
    } else {
        leftLabelX = leftImageViewX + leftImageViewWidth + offsetBetweenImageAndText;
    }
    leftLabelY = (leftControlHeight - leftLabelHeight) / 2.0;
    leftControlWidth = leftLabelX + leftLabelWidth;
    
    [leftControl setFrame:CGRectMake(leftControlX, leftControlY, leftControlWidth, leftControlHeight)];
    [leftImageView setFrame:CGRectMake(leftImageViewX, leftImageViewY, leftImageViewWidth, leftImageViewHeight)];
    [leftLabel setFrame:CGRectMake(leftLabelX, leftLabelY, leftLabelWidth, leftLabelHeight)];
}

- (void)updateRightControlFrame {
    CGFloat offset = 10.0f;
    
    CGFloat rightControlWidth = 0;
    CGFloat rightControlHeight = self.frame.size.height - statusBarOriginY;
    CGFloat rightControlX = 0;
    CGFloat rightControlY = statusBarOriginY;
    
    CGFloat rightImageViewWidth = 0;
    CGFloat rightImageViewHeight = 0;
    CGFloat rightImageViewX = offset;
    CGFloat rightImageViewY = 0;
    
    CGFloat rightLabelWidth = 0;
    CGFloat rightLabelHeight = 0;
    CGFloat rightLabelX = offset;
    CGFloat rightLabelY = 0;
    
    if (!rightImageView.hidden) {
        if (rightImageView.image) {
            rightImageViewWidth = rightImageView.image.size.width / 2.0;
            rightImageViewHeight = rightImageView.image.size.height / 2.0;
            if (rightImageViewHeight > rightControlHeight) {
                CGFloat rightImageScale = rightImageViewWidth * 1.0 / rightImageViewHeight;
                rightImageViewHeight = rightControlHeight;
                rightImageViewWidth = rightImageViewHeight * rightImageScale;
            }
            rightImageViewY = (rightControlHeight - rightImageViewHeight) / 2.0;
            rightControlWidth = rightImageViewWidth + offset * 2;
        }
    }
    if (!rightLabel.hidden) {
        CGSize rightLabelSize = [rightLabel labelSize];
        rightLabelWidth = rightLabelSize.width;
        rightLabelHeight = rightLabelSize.height;
        rightLabelY = (rightControlHeight - rightLabelHeight) / 2.0;
        rightControlWidth = rightLabelWidth + offset * 2;
    }
    rightControlX = self.frame.size.width - rightControlWidth;
    
    [rightControl setFrame:CGRectMake(rightControlX, rightControlY, rightControlWidth, rightControlHeight)];
    [rightImageView setFrame:CGRectMake(rightImageViewX, rightImageViewY, rightImageViewWidth, rightImageViewHeight)];
    [rightLabel setFrame:CGRectMake(rightLabelX, rightLabelY, rightLabelWidth, rightLabelHeight)];
}

- (void)updateTitleLabelFrame {
    CGFloat offsetBetweenLeftControlAndTitleLabel = 20.0f;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = statusBarOriginY;
    CGFloat titleLabelWidth =0;
    CGFloat titleLabelHeight = self.frame.size.height - statusBarOriginY;
    
    if (!leftControl.hidden) {
        titleLabelX = leftControl.frame.size.width + offsetBetweenLeftControlAndTitleLabel;
        titleLabelWidth = (self.frame.size.width / 2.0 - titleLabelX) * 2;
    } else if (!rightControl.hidden) {
        titleLabelWidth = (self.frame.size.width / 2.0 - rightControl.frame.size.width - offsetBetweenLeftControlAndTitleLabel) * 2;
        titleLabelX = (self.frame.size.width - titleLabelWidth) / 2.0;
    } else {
        CGSize titleLabelSize = [titleLabel labelSize];
        titleLabelWidth = titleLabelSize.width;
        titleLabelX = (self.frame.size.width - titleLabelWidth) / 2.0;
    }
    [titleLabel setFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight)];
}

- (void)updateFrame {
    [self updateBackgroundImageViewFrame];
    [self updateLeftControlFrame];
    [self updateRightControlFrame];
    [self updateTitleLabelFrame];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [backgroundImageView setImage:_backgroundImage];
    [self updateBackgroundImageViewFrame];
}

- (void)setLeftButtonFont:(UIFont *)leftButtonFont {
    _leftButtonFont = leftButtonFont;
    [leftLabel setFont:_leftButtonFont];
    [self updateLeftControlFrame];
}

- (void)setLeftButtonNormalColor:(UIColor *)leftButtonNormalColor {
    _leftButtonNormalColor = leftButtonNormalColor;
    [leftLabel setTextColor:_leftButtonNormalColor];
}

- (void)setLeftButtonNormalImage:(UIImage *)leftButtonNormalImage {
    _leftButtonNormalImage = leftButtonNormalImage;
    [leftImageView setImage:_leftButtonNormalImage];
    [self updateLeftControlFrame];
}

- (void)setRightButtonFont:(UIFont *)rightButtonFont {
    _rightButtonFont = rightButtonFont;
    [rightLabel setFont:_rightButtonFont];
    [self updateRightControlFrame];
}

- (void)setRightButtonNormalColor:(UIColor *)rightButtonNormalColor {
    _rightButtonNormalColor = rightButtonNormalColor;
    [rightLabel setTextColor:_rightButtonNormalColor];
}

- (void)setRightButtonNormalImage:(UIImage *)rightButtonNormalImage {
    _rightButtonNormalImage = rightButtonNormalImage;
    [rightImageView setImage:_rightButtonNormalImage];
    [self updateRightControlFrame];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [titleLabel setFont:_titleFont];
    [self updateTitleLabelFrame];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [titleLabel setTextColor:_titleColor];
}

- (void)leftButtonHide {
    [leftControl setHidden:YES];
    [leftLabel setHidden:YES];
    [leftImageView setHidden:YES];
    [self updateTitleLabelFrame];
}

- (void)leftButtonShowAll {
    [leftControl setHidden:NO];
    [leftLabel setHidden:NO];
    [leftImageView setHidden:NO];
    [self updateLeftControlFrame];
    [self updateTitleLabelFrame];
}

- (void)leftButtonOnlyShowText {
    [leftControl setHidden:NO];
    [leftLabel setHidden:NO];
    [leftImageView setHidden:YES];
    [self updateLeftControlFrame];
    [self updateTitleLabelFrame];
}

- (void)leftButtonOnlyShowImage {
    [leftControl setHidden:NO];
    [leftLabel setHidden:YES];
    [leftImageView setHidden:NO];
}

- (void)rightButtonHide {
    [rightControl setHidden:YES];
    [rightImageView setHidden:YES];
    [rightLabel setHidden:YES];
    [self updateRightControlFrame];
}

- (void)rightButtonShowAll {
    [rightControl setHidden:NO];
    [rightImageView setHidden:NO];
    [rightLabel setHidden:NO];
}

- (void)rightButtonOnlyShowText {
    [rightControl setHidden:NO];
    [rightImageView setHidden:YES];
    [rightLabel setHidden:NO];
    [self updateRightControlFrame];
}

- (void)rightButtonOnlyShowImage {
    [rightControl setHidden:NO];
    [rightImageView setHidden:NO];
    [rightLabel setHidden:YES];
    [self updateRightControlFrame];
}

- (BOOL)isLeftButtonHide {
    if (leftControl.hidden &&
        leftLabel.hidden &&
        leftImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isLeftButtonShowAll {
    if (leftControl.hidden ||
        leftLabel.hidden ||
        leftImageView.hidden) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isLeftButtonOnlyShowText {
    if (!leftControl.hidden &&
        !leftLabel.hidden &&
        leftImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isLeftButtonOnlyShowImage {
    if (!leftControl.hidden &&
        leftLabel.hidden &&
        !leftImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isRightButtonHide {
    if (rightControl.hidden &&
        rightLabel.hidden &&
        rightImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isRightButtonShowAll {
    if (rightControl.hidden ||
        rightLabel.hidden ||
        rightImageView.hidden) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isRightButtonOnlyShowText {
    if (!rightControl.hidden &&
        !rightLabel.hidden &&
        rightImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isRightButtonOnlyShowImage {
    if (!rightControl.hidden &&
        rightLabel.hidden &&
        !rightImageView.hidden) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setLeftButtonText:(NSString *)text {
    if ([XTool isStringEmpty:text]) {
        text = @"";
    }
    [leftLabel setText:text];
    [self updateLeftControlFrame];
    [self updateTitleLabelFrame];
}

- (void)setRightButtonText:(NSString *)text {
    if ([XTool isStringEmpty:text]) {
        text = @"";
    }
    [rightLabel setText:text];
    [self updateRightControlFrame];
}

- (void)setTitleText:(NSString *)text {
    if ([XTool isStringEmpty:text]) {
        text = @"";
    }
    [titleLabel setText:text];
    [self updateTitleLabelFrame];
}

- (NSString *)getLeftButtonText {
    return leftLabel.text;
}

- (NSString *)getRightButtonText {
    return rightLabel.text;
}

- (NSString *)getTitle {
    return titleLabel.text;
}

- (void)setLeftControlIsNormal:(BOOL)isNormal {
    if (isNormal) {
        [leftImageView setImage:_leftButtonNormalImage];
        [leftLabel setTextColor:_leftButtonNormalColor];
    } else {
        if (_leftButtonHighlightedImage) {
            [leftImageView setImage:_leftButtonHighlightedImage];
        } else {
            [leftImageView setImage:_leftButtonNormalImage];
        }
        if (_leftButtonHighlightedColor) {
            [leftLabel setTextColor:_leftButtonHighlightedColor];
        } else {
            [leftLabel setTextColor:_leftButtonNormalColor];
        }
    }
}

- (void)setRightControlIsNormal:(BOOL)isNormal {
    if (isNormal) {
        [rightImageView setImage:_rightButtonNormalImage];
        [rightLabel setTextColor:_rightButtonNormalColor];
    } else {
        if (_rightButtonHighlightedImage) {
            [rightImageView setImage:_rightButtonHighlightedImage];
        } else {
            [rightImageView setImage:_rightButtonNormalImage];
        }
        if (_rightButtonHighlightedColor) {
            [rightLabel setTextColor:_rightButtonHighlightedColor];
        } else {
            [rightLabel setTextColor:_rightButtonNormalColor];
        }
    }
}

#pragma mark TouchEvent Method

- (void)controlTouchToNormal:(id)sender {
    UIControl *control = (UIControl *)sender;
    if (control.tag == leftControlTag) {
        [self setLeftControlIsNormal:YES];
    } else if (control.tag == rightControlTag) {
        [self setRightControlIsNormal:YES];
    }
}

- (void)controlTouchToHighlighted:(id)sender {
    UIControl *control = (UIControl *)sender;
    if (control.tag == leftControlTag) {
        [self setLeftControlIsNormal:NO];
    } else if (control.tag == rightControlTag) {
        [self setRightControlIsNormal:NO];
    }
}

- (void)controlTouchToEvent:(id)sender {
    UIControl *control = (UIControl *)sender;
    if (control.tag == leftControlTag) {
        [self setLeftControlIsNormal:YES];
        if(_delegate && [_delegate respondsToSelector:@selector(clickTitleViewLeftButton)]) {
            [_delegate clickTitleViewLeftButton];
        }
    } else if (control.tag == rightControlTag) {
        [self setRightControlIsNormal:YES];
        if(_delegate && [_delegate respondsToSelector:@selector(clickTitleViewRightButton)]) {
            [_delegate clickTitleViewRightButton];
        }
    }
}

@end
