//
//  XPhotoView.h
//  JYLibrary
//
//  Created by XJY on 16/4/14.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XPhotoView : UICollectionViewCell

typedef void (^XPhotoViewBeginLoadBlock)(void);
typedef void (^XPhotoViewLoadProgressBlock)(CGFloat progress);
typedef void (^XPhotoViewLoadCompletionBlock)(void);

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, assign) CGFloat maximumZoomScale; //default is 2.0
@property (nonatomic, assign) CGFloat minimumZoomScale; //default is 1.0
@property (nonatomic, assign) BOOL showLoading;         //default is YES

- (void)loadImageForPath:(NSString *)path;

- (void)loadImage:(UIImage *)image;

- (void)loadImageForUrl:(NSString *)url placeHolderImage:(UIImage *)placeHolderImage;

- (void)loadImageForUrl:(NSString *)url;

- (void)releaseAll;

- (void)beginLoad:(XPhotoViewBeginLoadBlock)block;
- (void)loadProgress:(XPhotoViewLoadProgressBlock)block;
- (void)loadCompletion:(XPhotoViewLoadCompletionBlock)block;

@end
