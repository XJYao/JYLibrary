//
//  XImageCache.m
//  JYLibrary
//
//  Created by XJY on 16/1/17.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XImageCache.h"
#import "XTool.h"
#import "XFileManager.h"


@interface XImageCache ()
{
    NSCache *cache;

    NSString *diskCachePath;
}

@end


@implementation XImageCache

#pragma mark - Public

+ (instancetype)sharedManager {
    static XImageCache *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[XImageCache alloc] init];
        });
    }
    return manager;
}

- (void)storeImageToMemoryCache:(UIImage *)image forKey:(NSString *)key {
    if ([XTool isStringEmpty:key]) {
        return;
    }
    if (!image) {
        [self removeImageFromMemoryCacheForKey:key];
        return;
    }

    NSUInteger cost = SDCacheCostForImage(image);
    [cache setObject:image forKey:key cost:cost];
}

- (void)storeImageToDiskCache:(UIImage *)image forKey:(NSString *)key {
    if ([XTool isStringEmpty:key]) {
        return;
    }

    if (!image) {
        [self removeImageFromDiskCacheForKey:key];
        return;
    }

    NSString *path = [self pathForKey:key];
    if ([XFileManager isFileExist:path]) {
        return;
    }

    [XFileManager archive:image keyedArchivePath:path];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    id obj = [cache objectForKey:key];
    if (obj && [obj isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)obj;
        return image;
    }

    return nil;
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key {
    NSString *path = [self pathForKey:key];

    id obj = [XFileManager unarchive:path];
    if (obj && [obj isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)obj;
        return image;
    }

    return nil;
}

- (void)removeImageFromMemoryCacheForKey:(NSString *)key {
    [cache removeObjectForKey:key];
}

- (void)removeImageFromDiskCacheForKey:(NSString *)key {
    NSString *path = [self pathForKey:key];
    [XFileManager removeFile:path];
}

- (void)clearImageFromMemoryCache {
    [cache removeAllObjects];
}

- (void)clearImageFromDiskCache {
    [XFileManager removeFile:diskCachePath];
}

- (void)clearAllImageCache {
    [self clearImageFromMemoryCache];
    [self clearImageFromDiskCache];
}

#pragma mark - Property

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit {
    _totalCostLimit = totalCostLimit;
    [cache setTotalCostLimit:_totalCostLimit];
}

#pragma mark - Private

- (instancetype)init {
    self = [super init];

    if (self) {
        NSString *cacheName = @"com.xjy.imageCache";
        cache = [[NSCache alloc] init];
        [cache setName:cacheName];

        diskCachePath = [[XFileManager getCachesDirectory] stringByAppendingPathComponent:cacheName];
    }

    return self;
}

- (NSString *)pathForKey:(NSString *)key {
    NSString *newKey = [[NSString alloc] initWithString:key];
    if ([newKey rangeOfString:@"/"].location != NSNotFound) {
        newKey = [newKey stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    NSString *path = [diskCachePath stringByAppendingPathComponent:newKey];
    return path;
}

FOUNDATION_STATIC_INLINE NSUInteger SDCacheCostForImage(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

@end
