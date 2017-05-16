//
//  XImageManager.h
//  JYLibrary
//
//  Created by XJY on 16/1/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, XImageCacheType) {
    XImageCacheTypeNone = 1 << 0,
    XImageCacheTypeDisk = 1 << 1,
    XImageCacheTypeMemory = 1 << 2,
    XImageCacheTypeAll = XImageCacheTypeDisk | XImageCacheTypeMemory
};


@interface XImageManager : NSObject

#pragma mark - Property

typedef void (^XWebImageProgressBlock)(long long completedCount, long long totalCount);
typedef void (^XWebImageCompletionBlock)(BOOL success, UIImage *image, NSError *error);

@property (nonatomic, assign) XImageCacheType imageCacheType;
@property (nonatomic, assign) BOOL useNSURLConnection;

#pragma mark - Web Image

- (void)downloadImageWithURLString:(NSString *)URLString progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)completion;

- (void)downloadImageWithURL:(NSURL *)URL progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)completion;

@end
