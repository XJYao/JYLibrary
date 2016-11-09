//
//  XEncoding.m
//  JYLibrary
//
//  Created by XJY on 15/10/15.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XEncoding.h"
#import "XIOSVersion.h"

@implementation XEncoding

+ (NSString *)encodeString:(NSString *)string encoding:(NSStringEncoding)encoding {
//    NSString *characters = @"\"/'!*()&=+$#%,:;<>?@[]\\^`{}|";
//    
//    if ([XIOSVersion isIOS7OrGreater]) {
//        return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:characters]];
//    } else {
        return [string stringByAddingPercentEscapesUsingEncoding:encoding];
        
//        return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)originString, NULL, (CFStringRef)characters, kCFStringEncodingUTF8);
//    }
}

+ (NSString *)decodeString:(NSString *)string encoding:(NSStringEncoding)encoding {
//    if ([XIOSVersion isIOS7OrGreater]) {
//        return [string stringByRemovingPercentEncoding];
//    } else {
        return [string stringByReplacingPercentEscapesUsingEncoding:encoding];
//    }
}

@end
