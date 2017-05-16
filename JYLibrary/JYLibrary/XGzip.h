//
//  XGzip.h
//  JYLibrary
//
//  Created by XJY on 15/10/27.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XGzip : NSObject

/**
 Gzip压缩
 */
+ (NSData *)compressData:(NSData *)data;

/**
 Gzip解压缩
 */
+ (NSData *)decompressData:(NSData *)data;

@end
