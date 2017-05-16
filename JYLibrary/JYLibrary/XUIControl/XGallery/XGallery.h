//
//  XGallery.h
//  JYLibrary
//
//  Created by XJY on 15-7-31.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XGallery : UIView

@property (nonatomic, copy) NSString *placeholderImageName;
@property (nonatomic, assign) CGFloat maximumZoomScale; //default is 2.0
@property (nonatomic, assign) CGFloat minimumZoomScale; //default is 1.0
@property (nonatomic, strong) UIFont *pageNumberFont;

/**
 初始化时就传入图片
 */
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images;

/**
 添加图片,数组里元素可以是UIImage,NSString(图片地址或图片名),NSData
 */
- (void)addImages:(NSArray *)images;

/**
 添加图片和默认图片,用于图片加载失败时显示,数组里元素可以是UIImage,NSString（图片地址或图片名),NSData
 */
- (void)addImages:(NSArray *)images placeHolderImageName:(NSString *)imageName;

/**
 添加一张图片,传入的参数可以是UIImage,NSString(图片地址或图片名)或者NSData
 */
- (void)addImage:(id)anObject;

/**
 删除指定索引的图片
 */
- (BOOL)removeImageAtIndex:(NSInteger)index;

/**
 删除指定图片
 */
- (BOOL)removeImage:(id)anObject;

/**
 删除所有图片
 */
- (void)removeAllImages;

/**
 滚动到指定图片,从0开始
 */
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

/**
 当旋转时调用,重置布局
 */
- (void)updateFrameWhenRotation:(CGRect)frame;

@end
