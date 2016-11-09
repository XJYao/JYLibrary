//
//  XCircleProgress.h
//  JYLibrary
//
//  Created by XJY on 16/1/27.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCircleProgress : UIView

@property (nonatomic, assign)   CGFloat     progress;                   //进度
@property (nonatomic, assign)   BOOL        indicatorGradient;          //进度条是否有渐变效果
@property (nonatomic, assign)   CGFloat     indicatorRadius;            //进度条半径

@property (nonatomic, strong)   UIColor *   indicatorColor;             //进度条颜色
@property (nonatomic, strong)   UIColor *   indicatorBackgroundColor;   //进度条背景线条颜色
@property (nonatomic, assign)   CGFloat     indicatorAlpha;             //进度条透明度
@property (nonatomic, assign)   CGFloat     indicatorBackgroundAlpha;   //进度条背景线条透明度
@property (nonatomic, assign)   CGFloat     indicatorWidth;             //进度条宽度
@property (nonatomic, assign)   CGFloat     indicatorBackgroundWidth;   //进度条背景线条宽度

@property (nonatomic, strong)   UIColor     *   textColor;              //文字颜色
@property (nonatomic, strong)   UIFont      *   textFont;               //文字字体
@property (nonatomic, copy)     NSString    *   text;                   //文字
@property (nonatomic, assign)   CGSize          pointImageSize;         //进度条末端图片大小

@property (nonatomic, strong, readonly)     UILabel     *   textLabel;
@property (nonatomic, strong, readonly)     UIImageView *   pointImageView;

@end
