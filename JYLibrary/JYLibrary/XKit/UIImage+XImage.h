//
//  UIImage+XImage.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface UIImage (XImage)

/**
 从工程目录加载图片,传入图片名,适用于大图,无缓存
 */
+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName;

/**
 从工程目录加载图片,传入图片名,适用于不大并且不常用的图片,无缓存
 */
+ (UIImage *)imageWithContentsOfName:(NSString *)imageName;

/**
 从工程目录加载图片,传入图片名和图片类型,适用于大图,无缓存
 */
+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName type:(NSString *)type;

/**
 从工程目录加载图片,传入图片名和图片类型,适用于不大并且不常用的图片,无缓存
 */
+ (UIImage *)imageWithContentsOfName:(NSString *)imageName type:(NSString *)type;

/**
 从工程目录加载图片,适用于不大并且经常使用,特别是频繁访问的图片,缓存到内存
 */
+ (UIImage *)imageWithNamed:(NSString *)imageName;

/**
 将指定颜色制作成图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 将图片进行旋转处理
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source;

/**
 根据局部区域frame裁剪图片
 */
+ (UIImage *)subImageFromImage:(UIImage *)image inRect:(CGRect)rect;

/**
 将UIImage转化为NSData
 */
+ (NSData *)dataWithImage:(UIImage *)image ;

/**
 将图片裁剪为指定大小
 */
+ (UIImage *)changeImageSize:(UIImage *)sourceImage size:(CGSize)destSize;

/**
 图片压缩
 */
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;

+ (UIImage *)thumbnailForImage:(UIImage *)asset maxPixelSize:(NSUInteger)size;

+ (UIImage *)compressImage:(UIImage *)sourceImage pixels:(long long)destPixels;

/**
 多图
 */
+ (NSArray *)imagesWithData:(NSData *)data;

/**
 合并图片
 */
+ (UIImage *)mergeImages:(NSArray *)images;

+ (UIImage *)mergeImagesWithImage:(UIImage *)image, ... NS_REQUIRES_NIL_TERMINATION;

@end
