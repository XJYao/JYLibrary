//
//  XImageManager.m
//  JYLibrary
//
//  Created by XJY on 16/1/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XImageManager.h"
#import "XHttpRequest.h"
#import "XImageCache.h"

@implementation XImageManager

#pragma mark - Web Image

- (void)downloadImageWithURLString:(NSString *)URLString progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)completion {
    
    [self downloadImageWithURL:[NSURL URLWithString:URLString] progress:progress completion:completion];
}

- (void)downloadImageWithURL:(NSURL *)URL progress:(XWebImageProgressBlock)progress completion:(XWebImageCompletionBlock)completion {
    
    NSString *key = URL.absoluteString;

    UIImage *cacheImage = [[XImageCache sharedManager] imageFromMemoryCacheForKey:key];
    if (cacheImage) {
        
        if (_imageCacheType == XImageCacheTypeNone) {
            [[XImageCache sharedManager] removeImageFromMemoryCacheForKey:key];
            [[XImageCache sharedManager] removeImageFromDiskCacheForKey:key];
        } else if (_imageCacheType == XImageCacheTypeMemory) {
            [[XImageCache sharedManager] removeImageFromDiskCacheForKey:key];
        } else if (_imageCacheType == XImageCacheTypeDisk) {
            [[XImageCache sharedManager] removeImageFromMemoryCacheForKey:key];
        }
        
        if (_imageCacheType & XImageCacheTypeDisk) {
            [[XImageCache sharedManager] storeImageToDiskCache:cacheImage forKey:key];
        }
        
        if (completion) {
            completion(YES, cacheImage, nil);
        }
        return;
    }
    
    cacheImage = [[XImageCache sharedManager] imageFromDiskCacheForKey:key];
    if (cacheImage) {
        
        if (_imageCacheType == XImageCacheTypeNone ||
            _imageCacheType == XImageCacheTypeMemory) {
            [[XImageCache sharedManager] removeImageFromDiskCacheForKey:key];
        }
        
        if (_imageCacheType & XImageCacheTypeMemory) {
            [[XImageCache sharedManager] storeImageToMemoryCache:cacheImage forKey:key];
        }

        if (completion) {
            completion(YES, cacheImage, nil);
        }
        return;
    }
    
    XHttpRequest *request = [[XHttpRequest alloc] init];
    [request setUseNSURLConnection:_useNSURLConnection];
    
    [request GETHttpRequestWithURL:URL progressBlock:^(long long completedCount, long long totalCount) {
        
        if (progress) {
            progress(completedCount, totalCount);
        }
        
    } finshedBlock:^(id responseObject, NSString *responseString, NSInteger statusCode, NSError *error) {
        
        if (statusCode != XHttpStatusCodeOK ||
            ![responseObject isKindOfClass:[NSData class]]) {
            
            [[XImageCache sharedManager] removeImageFromMemoryCacheForKey:key];
            [[XImageCache sharedManager] removeImageFromDiskCacheForKey:key];
            
            if (completion) {
                completion(NO, nil, error);
            }
            
            return;
        }

        UIImage *image = nil;
        if (responseObject) {
            image = [[UIImage alloc] initWithData:responseObject];
        }
        if (_imageCacheType & XImageCacheTypeMemory) {
            [[XImageCache sharedManager] storeImageToMemoryCache:image forKey:key];
        }
        
        if (_imageCacheType & XImageCacheTypeDisk) {
            [[XImageCache sharedManager] storeImageToDiskCache:image forKey:key];
        }

        if (completion) {
            completion(YES, image, error);
        }
        
    }];
    
}

#pragma mark - Private

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _imageCacheType = XImageCacheTypeAll;
        _useNSURLConnection = NO;
    }
    
    return self;
}

@end
