//
//  XJsonParser.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XJsonParser.h"
#import "XTool.h"

@implementation XJsonParser

+ (id)parseJsonWithData:(NSData *)jsonData error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:error];
}

+ (id)parseJsonWithString:(NSString *)jsonStr error:(NSError **)error {
    return [self parseJsonWithString:jsonStr encoding:NSUTF8StringEncoding error:error];
}

+ (id)parseJsonWithString:(NSString *)jsonStr encoding:(NSStringEncoding)encoding error:(NSError **)error {
    if ([XTool isStringEmpty:jsonStr]) {
        error = nil;
        return nil;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:encoding];
    return [self parseJsonWithData:jsonData error:error];
}

+ (NSData *)jsonDataWithObject:(id)obj error:(NSError **)error {
    if ([XTool isObjectNull:obj]) {
        error = nil;
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
}

+ (NSString *)jsonStringWithObject:(id)obj error:(NSError **)error {
    if ([XTool isObjectNull:obj]) {
        error = nil;
        return nil;
    }
    
    NSData *data = [self jsonDataWithObject:obj error:error];
    
    if ([XTool isObjectNull:data]) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
