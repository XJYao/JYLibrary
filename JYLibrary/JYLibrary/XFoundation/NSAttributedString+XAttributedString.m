//
//  NSAttributedString+XAttributedString.m
//  JYLibrary
//
//  Created by XJY on 17/4/5.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import "NSAttributedString+XAttributedString.h"
#import "XTool.h"


@implementation NSAttributedString (XAttributedString)

+ (NSString *)htmlWithAttributedString:(NSAttributedString *)attributedString {
    if ([XTool isObjectNull:attributedString] || attributedString.length == 0) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [attributedString dataFromRange:NSMakeRange(0, attributedString.length)
                                documentAttributes:@{
                                    NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                                    NSCharacterEncodingDocumentAttribute : [NSNumber numberWithInt:NSUTF8StringEncoding]
                                }
                                             error:&error];
    if (![XTool isObjectNull:error]) {
        return nil;
    }
    NSString *html = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
    return html;
}

+ (NSAttributedString *)attributedStringWithHTML:(NSString *)html {
    if ([XTool isStringEmpty:html]) {
        return nil;
    }

    NSError *error = nil;

    NSAttributedString *attributedString =
        [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding]
                                         options:@{
                                             NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType
                                         }
                              documentAttributes:nil
                                           error:&error];
    if (![XTool isObjectNull:error]) {
        return nil;
    }
    return attributedString;
}

@end
