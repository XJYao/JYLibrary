//
//  XJsonParser.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XJsonParser : NSObject

typedef void (^JsonParserCompletionBlock)(id parseResult, NSError *error);

/**
 解析NSData形式的json
 */
+ (id)parseJsonWithData:(NSData *)jsonData error:(NSError **)error;

/**
 解析NSString形式的json
 */
+ (id)parseJsonWithString:(NSString *)jsonStr error:(NSError **)error;

/**
 解析NSString形式的json, UTF-8编码
 */
+ (id)parseJsonWithString:(NSString *)jsonStr encoding:(NSStringEncoding)encoding error:(NSError **)error;

/**
 将对象转换成json数据
 */
+ (NSData *)jsonDataWithObject:(id)obj error:(NSError **)error;

/**
 将对象转换成json字符串
 */
+ (NSString *)jsonStringWithObject:(id)obj error:(NSError **)error;

@end
