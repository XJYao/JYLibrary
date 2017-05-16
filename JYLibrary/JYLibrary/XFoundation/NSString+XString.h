//
//  NSString+XString.h
//  JYLibrary
//
//  Created by XJY on 16/6/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (XString)

- (NSArray<NSString *> *)subStringsPerLength:(NSUInteger)length;

- (void)enumerateSubStringsPerLength:(NSUInteger)length subString:(void (^)(NSString *subString))block;

- (void)enumerateCharactersPerLength:(NSUInteger)length characters:(void (^)(const char *characters))block;

- (void)enumerateCharacters:(void (^)(const char *character))block;

- (NSString *)percentEscapedString;

@end
