//
//  UIColor+XColor.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (XColor)

//RGB color macro with alpha
#define colorFromRGBWithAlpha(rgbValue, alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                                                               green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                                                                blue:((float)(rgbValue & 0xFF)) / 255.0             \
                                                               alpha:alpha]

//RGB Color macro
#define colorFromRGB(rgbValue) colorFromRGBWithAlpha(rgbValue, 1.0f)

/**
 获取颜色的RGB值
 返回数组, 0是R, 1是G, 2是B, 3是alpha
 */
- (NSArray *)getRGBFromColor;
+ (NSArray *)getRGBFromColor:(UIColor *)color;

/**
 获取颜色的alpha值
 如果color为空, 则返回-1
 */
- (CGFloat)getAlphaFromColor;
+ (CGFloat)getAlphaFromColor:(UIColor *)color;

/**
 十六进制转UIColor

 @param hexString 十六进制
 @return UIColor
 */
+ (UIColor *)UIColorWithHexString:(NSString *)hexString;

@end
