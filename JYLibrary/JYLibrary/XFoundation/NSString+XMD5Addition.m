//
//  NSString+XMD5Addition.m
//  JYLibrary
//
//  Created by XJY on 16/8/3.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSString+XMD5Addition.h"
#import <CommonCrypto/CommonDigest.h>
#import "XTool.h"


@implementation NSString (XMD5Addition)

- (NSString *)stringFromMD5 {
    if ([XTool isStringEmpty:self]) {
        return nil;
    }

    const char *value = [self UTF8String];

    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (uint32_t)strlen(value), outputBuffer);

    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }

    return outputString;
}

@end
