//
//  UILabel+XLabel.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UILabel (XLabel)

/**
 获取label的大小，只支持单行
 */
- (CGSize)labelSize;

/**
 获取label的大小,有大小限制
 */
- (CGSize)labelSize:(CGSize)maximumLabelSize;

/**
 通过高度获取label宽度
 */
- (CGFloat)widthForHeight:(CGFloat)height;

/**
 通过高度获取label宽度,有最大宽度限制
 */
- (CGFloat)widthForHeight:(CGFloat)height maxWidth:(CGFloat)maxWidth;

/**
 通过宽度获取label高度
 */
- (CGFloat)heightForWidth:(CGFloat)width;

/**
 通过宽度获取label高度,有最大高度限制
 */
- (CGFloat)heightForWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;

/**
 允许多行
 */
- (void)allowMultiLine;

@end
