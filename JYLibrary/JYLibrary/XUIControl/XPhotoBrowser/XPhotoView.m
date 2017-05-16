//
//  XPhotoView.m
//  JYLibrary
//
//  Created by XJY on 16/4/14.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XPhotoView.h"
#import "UIImageView+XWebImageView.h"
#import "XTool.h"
#import "XThread.h"


@interface XPhotoView () <UIScrollViewDelegate>
{
    UIScrollView *imageScrollView;
    UIImageView *imageView;
    UIActivityIndicatorView *loading;

    XPhotoViewBeginLoadBlock beginLoadBlock;
    XPhotoViewLoadProgressBlock loadProgressBlock;
    XPhotoViewLoadCompletionBlock loadCompletionBlock;
}

@end


@implementation XPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];

        _placeholderImage = nil;
        _maximumZoomScale = 2.0;
        _minimumZoomScale = 1.0;
        _showLoading = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (CGSizeEqualToSize(self.frame.size, CGSizeZero) ||
        CGSizeEqualToSize(self.contentView.frame.size, CGSizeZero)) {
        return;
    }

    [self updateFrame];
}

- (void)addUI {
    [self releaseAll];

    imageScrollView = [[UIScrollView alloc] init];
    [imageScrollView setBackgroundColor:[UIColor clearColor]];
    [imageScrollView setShowsHorizontalScrollIndicator:NO];
    [imageScrollView setShowsVerticalScrollIndicator:NO];
    [imageScrollView setPagingEnabled:NO];
    [imageScrollView setDelegate:self];
    [imageScrollView setBounces:YES];
    [imageScrollView setClipsToBounds:YES];
    [imageScrollView setDelaysContentTouches:NO];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setMaximumZoomScale:_maximumZoomScale];
    [imageScrollView setMinimumZoomScale:_minimumZoomScale];
    [self.contentView addSubview:imageScrollView];

    imageView = [[UIImageView alloc] init];
    [imageView setUserInteractionEnabled:YES];
    [imageScrollView addSubview:imageView];

    loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.contentView addSubview:loading];
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    _maximumZoomScale = maximumZoomScale;
    [imageScrollView setMaximumZoomScale:_maximumZoomScale];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    _minimumZoomScale = minimumZoomScale;
    [imageScrollView setMinimumZoomScale:_minimumZoomScale];
}

- (void)beginLoad:(XPhotoViewBeginLoadBlock)block {
    beginLoadBlock = block;
}

- (void)loadProgress:(XPhotoViewLoadProgressBlock)block {
    loadProgressBlock = block;
}

- (void)loadCompletion:(XPhotoViewLoadCompletionBlock)block {
    loadCompletionBlock = block;
}

- (void)loadImageForPath:(NSString *)path {
    if (beginLoadBlock) {
        beginLoadBlock();
    }

    [self addUI];

    if (_showLoading) {
        [loading startAnimating];
    }

    x_dispatch_async_default(^{
        UIImage *image = nil;
        if (![XTool isStringEmpty:path]) {
            image = [[UIImage alloc] initWithContentsOfFile:path];
        }
        x_dispatch_main_async(^{
            if ([XTool isObjectNull:image]) {
                [imageView setImage:_placeholderImage];
            } else {
                [imageView setImage:image];
            }
            [self updateFrame];

            if (_showLoading) {
                [loading stopAnimating];
            }

            if (loadCompletionBlock) {
                loadCompletionBlock();
            }
        });
    });
}

- (void)loadImage:(UIImage *)image {
    if (beginLoadBlock) {
        beginLoadBlock();
    }

    [self addUI];

    if ([XTool isObjectNull:image]) {
        [imageView setImage:_placeholderImage];
    } else {
        [imageView setImage:image];
    }
    [self updateFrame];

    if (loadCompletionBlock) {
        loadCompletionBlock();
    }
}

- (void)loadImageForUrl:(NSString *)url placeHolderImage:(UIImage *)placeHolderImage {
    _placeholderImage = placeHolderImage;

    [self loadImageForUrl:url];
}

- (void)loadImageForUrl:(NSString *)url {
    if (beginLoadBlock) {
        beginLoadBlock();
    }

    [self addUI];

    if (_showLoading) {
        [loading startAnimating];
    }

    [imageView x_setImageWithURLString:url placeholderImage:_placeholderImage progress:^(long long completedCount, long long totalCount) {

        if (loadProgressBlock) {
            loadProgressBlock(completedCount * 1.0 / totalCount);
        }

    } completion:^(BOOL success, UIImage *image, NSError *error) {

        x_dispatch_main_async(^{
            [self updateFrame];

            if (_showLoading) {
                [loading stopAnimating];
            }

            if (loadCompletionBlock) {
                loadCompletionBlock();
            }
        });

    }];
}

- (void)releaseAll {
    if (imageView) {
        [imageView setImage:nil];
        [imageView removeFromSuperview];
        imageView = nil;
    }

    if (imageScrollView) {
        for (UIView *subView in imageScrollView.subviews) {
            [subView removeFromSuperview];
        }
        [imageScrollView removeFromSuperview];
        imageScrollView = nil;
    }

    if (loading) {
        [loading removeFromSuperview];
        loading = nil;
    }

    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)updateFrame {
    CGRect contentViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!CGRectEqualToRect(self.contentView.frame, contentViewFrame)) {
        [self.contentView setFrame:contentViewFrame];
    }

    if (loading) {
        [loading setCenter:self.contentView.center];
    }

    [self updateScrollViewFrame];
    [self updateImageViewFrame];
}

- (void)updateScrollViewFrame {
    if ([XTool isObjectNull:imageScrollView]) {
        return;
    }

    CGFloat scrollViewWidth = self.contentView.frame.size.width;
    CGFloat scrollViewHeight = self.contentView.frame.size.height;
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;

    CGRect imageScrollViewFrame = CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight);
    if (!CGRectEqualToRect(imageScrollView.frame, imageScrollViewFrame)) {
        [imageScrollView setFrame:imageScrollViewFrame];
    }
    [imageScrollView setContentSize:CGSizeMake(scrollViewWidth, scrollViewHeight)];
    [imageScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)updateImageViewFrame {
    if ([XTool isObjectNull:imageView]) {
        return;
    }

    x_dispatch_async_default(^{
        CGFloat imageViewWidth = 0;
        CGFloat imageViewHeight = 0;
        CGFloat imageViewX = 0;
        CGFloat imageViewY = 0;

        CGFloat imageWidth = 0;
        CGFloat imageHeight = 0;
        if (imageView && imageView.image) {
            imageWidth = imageView.image.size.width;
            imageHeight = imageView.image.size.height;
        }
        if (imageWidth <= 0 || imageHeight <= 0) {
            imageViewWidth = 0;
            imageViewHeight = 0;
            imageViewX = 0;
            imageViewY = 0;
        } else {
            CGFloat scrollViewWidth = imageScrollView.frame.size.width;
            CGFloat scrollViewHeight = imageScrollView.frame.size.height;

            CGFloat widthScale = imageWidth * 1.0 / scrollViewWidth;
            CGFloat HeightScale = imageHeight * 1.0 / scrollViewHeight;
            CGFloat imageSizeScale = imageWidth * 1.0 / imageHeight;

            if (widthScale <= 1.0 && HeightScale <= 1.0) {
                imageViewWidth = imageWidth;
                imageViewHeight = imageHeight;
                imageViewX = (scrollViewWidth - imageViewWidth) * 1.0 / 2;
                imageViewY = (scrollViewHeight - imageViewHeight) * 1.0 / 2;
            } else {
                if (widthScale >= HeightScale) {
                    imageViewWidth = scrollViewWidth;
                    imageViewHeight = imageViewWidth * 1.0 / imageSizeScale;
                    imageViewX = 0;
                    imageViewY = (scrollViewHeight - imageViewHeight) * 1.0 / 2;
                } else {
                    imageViewHeight = scrollViewHeight;
                    imageViewWidth = imageViewHeight * imageSizeScale;
                    imageViewX = (scrollViewWidth - imageViewWidth) * 1.0 / 2;
                    imageViewY = 0;
                }
            }
        }

        CGRect imageViewFrame = CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight);
        if (!CGRectEqualToRect(imageView.frame, imageViewFrame)) {
            x_dispatch_main_async(^{
                [imageView setFrame:imageViewFrame];
            });
        }
    });
}

- (void)setImageViewToCenter:(UIScrollView *)scrollView {
    x_dispatch_async_default(^{
        CGFloat imageViewX = 0;
        CGFloat imageViewY = 0;
        if (imageView.frame.size.width < scrollView.frame.size.width) {
            imageViewX = (scrollView.frame.size.width - imageView.frame.size.width) * 1.0 / 2;
        } else {
            imageViewX = 0;
        }
        if (imageView.frame.size.height < scrollView.frame.size.height) {
            imageViewY = (scrollView.frame.size.height - imageView.frame.size.height) * 1.0 / 2;
        } else {
            imageViewY = 0;
        }

        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.origin.x = imageViewX;
        imageViewFrame.origin.y = imageViewY;

        if (!CGRectEqualToRect(imageView.frame, imageViewFrame)) {
            x_dispatch_main_async(^{
                [imageView setFrame:imageViewFrame];
            });
        }
    });
}

#pragma mark UIScrollView Delegate Method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setImageViewToCenter:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self setImageViewToCenter:scrollView];
}

@end
