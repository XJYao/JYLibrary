//
//  UIImageView+XWebImageView.h
//  JYLibrary
//
//  Created by XJY on 16/1/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XImageManager.h"

@interface UIImageView (XWebImageView)

@property (nonatomic, strong) XImageManager *imageManager;

- (void)x_setImageWithURLString:(NSString *)URLString progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImageName:(NSString *)placeholderImageName progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImagePath:(NSString *)placeholderImagePath progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURLString:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURL:(NSURL *)URL progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURL:(NSURL *)URL placeholderImageName:(NSString *)placeholderImageName progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURL:(NSURL *)URL placeholderImagePath:(NSString *)placeholderImagePath progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

- (void)x_setImageWithURL:(NSURL *)URL placeholderImage:(UIImage *)placeholderImage progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)block;

@end
