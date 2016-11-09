//
//  NSString+XString.m
//  JYLibrary
//
//  Created by XJY on 16/6/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSString+XString.h"
#import "XIOSVersion.h"

@implementation NSString (XString)

- (NSArray<NSString *> *)subStringsPerLength:(NSUInteger)length {
    NSMutableArray *subStrings = [[NSMutableArray alloc] init];
    
    NSUInteger index = 0;
    
    while (index < self.length) {
        NSUInteger len = MIN(self.length - index, length);
        NSRange range = NSMakeRange(index, len);
        
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [self substringWithRange:range];
        
        index += range.length;
        
        if (substring) {
            [subStrings x_addObject:substring];
        }
    }
    
    return subStrings;
}

- (void)enumerateSubStringsPerLength:(NSUInteger)length subString:(void (^)(NSString *))block {
    NSArray<NSString *> *subStrings = [self subStringsPerLength:length];
    for (NSString *subString in subStrings) {
        if (block) {
            block(subString);
        }
    }
}

- (void)enumerateCharactersPerLength:(NSUInteger)length characters:(void (^)(const char *))block {
    [self enumerateSubStringsPerLength:length subString:^(NSString *subString) {
        
        if (block) {
            block([subString UTF8String]);
        }
    }];
}

- (void)enumerateCharacters:(void (^)(const char *))block {
    [self enumerateCharactersPerLength:1 characters:block];
}

- (NSString *)percentEscapedString {
    
    NSString *charactersString = @":#[]@!$&'()*+,;=";
    
    if ([XIOSVersion isIOS7OrGreater]) {
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:charactersString];
        
        NSMutableString *escaped = [[NSMutableString alloc] init];
        
        NSArray<NSString *> *subStrings = [self subStringsPerLength:50];
        for (NSString *subString in subStrings) {
            NSString *encoded = [subString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
        }
        
        return escaped;
    }
    
    CFStringRef escapedRef = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (CFStringRef)charactersString, kCFStringEncodingUTF8);
    NSString *escaped = (__bridge NSString *)escapedRef;
    CFRelease(escapedRef);
    return escaped;
}

@end
