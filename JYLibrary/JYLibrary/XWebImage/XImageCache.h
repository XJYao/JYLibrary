//
//  XImageCache.h
//  JYLibrary
//
//  Created by XJY on 16/1/17.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XImageCache : NSObject

@property (nonatomic, assign) NSUInteger totalCostLimit;

+ (instancetype)sharedManager;

- (void)storeImageToMemoryCache:(UIImage *)image forKey:(NSString *)key;

- (void)storeImageToDiskCache:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;

- (void)removeImageFromMemoryCacheForKey:(NSString *)key;

- (void)removeImageFromDiskCacheForKey:(NSString *)key;

- (void)clearImageFromMemoryCache;

- (void)clearImageFromDiskCache;

- (void)clearAllImageCache;

@end
