//
//  UIImageView+XWebImageView.m
//  JYLibrary
//
//  Created by XJY on 16/1/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIImageView+XWebImageView.h"
#import "XTool.h"
#import "XThread.h"
#import "UIImage+XImage.h"
#import <objc/runtime.h>


@implementation UIImageView (XWebImageView)

#pragma mark - Public

- (void)x_setImageWithURLString:(NSString *)URLString progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    [self x_setImageWithURLString:URLString placeholderImage:nil progress:progress completion:block];
}

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImageName:(NSString *)placeholderImageName progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    UIImage *placeholderImage = [UIImage initImageWithContentsOfName:placeholderImageName];
    [self x_setImageWithURLString:URLString placeholderImage:placeholderImage progress:progress completion:block];
}

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImagePath:(NSString *)placeholderImagePath progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    UIImage *placeholderImage = [[UIImage alloc] initWithContentsOfFile:placeholderImagePath];
    [self x_setImageWithURLString:URLString placeholderImage:placeholderImage progress:progress completion:block];
}

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    [self x_setImageWithURL:[NSURL URLWithString:URLString] placeholderImage:placeholderImage progress:progress completion:block];
}

- (void)x_setImageWithURL:(NSURL *)URL progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    [self x_setImageWithURL:URL placeholderImage:nil progress:progress completion:block];
}

- (void)x_setImageWithURL:(NSURL *)URL placeholderImageName:(NSString *)placeholderImageName progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    UIImage *placeholderImage = [UIImage initImageWithContentsOfName:placeholderImageName];
    [self x_setImageWithURL:URL placeholderImage:placeholderImage progress:progress completion:block];
}

- (void)x_setImageWithURL:(NSURL *)URL placeholderImagePath:(NSString *)placeholderImagePath progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    UIImage *placeholderImage = [[UIImage alloc] initWithContentsOfFile:placeholderImagePath];
    [self x_setImageWithURL:URL placeholderImage:placeholderImage progress:progress completion:block];
}

- (void)x_setImageWithURL:(NSURL *)URL placeholderImage:(UIImage *)placeholderImage progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block {
    [self setImage:placeholderImage];

    if (!self || !URL || [XTool isStringEmpty:URL.absoluteString]) {
        if (block) {
            block(NO, nil, nil);
        }

        return;
    }

    [self.imageManager downloadImageWithURL:URL progress:progress completion:^(BOOL success, UIImage *image, NSError *error) {
        if (success) {
            x_dispatch_main_async(^{
                if (self.image != image) {
                    [self setImage:image];
                }
            });
        }
        if (block) {
            block(success, image, error);
        }
    }];
}

#pragma mark - Private

static const void *XImageManagerKey = &XImageManagerKey;

#pragma mark - property

- (void)setImageManager:(XImageManager *)imageManager {
    objc_setAssociatedObject(self, XImageManagerKey, imageManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XImageManager *)imageManager {
    id obj = objc_getAssociatedObject(self, XImageManagerKey);
    if (!obj) {
        XImageManager *imageManager = [[XImageManager alloc] init];
        [self setImageManager:imageManager];
        return imageManager;
    }

    return obj;
}

@end
