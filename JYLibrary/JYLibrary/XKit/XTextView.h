//
//  XTextView.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, XTextViewPlaceholderAlignment) {
    XTextViewPlaceholderAlignmentLeft = 1 << 0,
    XTextViewPlaceholderAlignmentRight = 1 << 1,
    XTextViewPlaceholderAlignmentTop = 1 << 2,
    XTextViewPlaceholderAlignmentBottom = 1 << 3,
    XTextViewPlaceholderAlignmentCenterX = 1 << 4,
    XTextViewPlaceholderAlignmentCenterY = 1 << 5,
    XTextViewPlaceholderAlignmentCenter = XTextViewPlaceholderAlignmentCenterX | XTextViewPlaceholderAlignmentCenterY
};

@protocol XTextViewDelegate <UITextViewDelegate>

@optional
- (void)updateInputLengthForTextView:(UITextView *)textView;

@end


@interface XTextView : UITextView

@property (nonatomic, assign) XTextViewPlaceholderAlignment placeholderAlignment;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, assign) NSInteger maxLengthForInput; //default is 0,unlimited

/**
 检测字数是否达到限制,textViewDidChange里调用
 */
- (void)checkTextLimited;

@end
