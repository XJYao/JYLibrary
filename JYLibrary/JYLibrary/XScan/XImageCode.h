//
//  XImageCode.h
//  XScan
//
//  Created by XJY on 16/2/26.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface XImageCode : NSObject

+ (NSString *)readStringFromImage:(UIImage *)image;

+ (UIImage *)imageFromString:(NSString *)string size:(CGSize)size frontColor:(UIColor *)frontColor backColor:(UIColor *)backColor;

@end
