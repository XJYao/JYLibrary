//
//  NSAttributedString+XAttributedString.h
//  JYLibrary
//
//  Created by XJY on 17/4/5.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSAttributedString (XAttributedString)

/**
 富文本转html
 */
+ (NSString *)htmlWithAttributedString:(NSAttributedString *)attributedString;

/**
 html转富文本
 */
+ (NSAttributedString *)attributedStringWithHTML:(NSString *)html;

@end
