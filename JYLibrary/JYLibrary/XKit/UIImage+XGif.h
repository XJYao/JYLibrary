//
//  UIImage+XGif.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XGif)

+ (UIImage *)animatedGIFNamed:(NSString *)name;

+ (UIImage *)animatedGIFWithData:(NSData *)data;

- (UIImage *)animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
