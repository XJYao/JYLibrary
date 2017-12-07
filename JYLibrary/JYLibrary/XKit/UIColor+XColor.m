//
//  UIColor+XColor.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIColor+XColor.h"


@implementation UIColor (XColor)

- (NSArray *)getRGBFromColor {
    return [UIColor getRGBFromColor:self];
}

- (CGFloat)getAlphaFromColor {
    return [UIColor getAlphaFromColor:self];
}

+ (NSArray *)getRGBFromColor:(UIColor *)color {
    if (!color) {
        return nil;
    }

    CGColorRef colorRef = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(colorRef);

    NSArray *RGBComponents = nil;

    if (numComponents == 2 || numComponents == 4) {
        if (numComponents == 2) {
            const CGFloat *components = CGColorGetComponents(colorRef);

            CGFloat R = components[0];
            CGFloat G = R;
            CGFloat B = R;
            CGFloat alpha = components[1];

            RGBComponents = @[ @(R), @(G), @(B), @(alpha) ];

        } else if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(colorRef);

            CGFloat R = components[0];
            CGFloat G = components[1];
            CGFloat B = components[2];
            CGFloat alpha = components[3];

            RGBComponents = @[ @(R), @(G), @(B), @(alpha) ];
        }
    }

    return RGBComponents;
}

+ (CGFloat)getAlphaFromColor:(UIColor *)color {
    if (!color) {
        return -1;
    }

    CGColorRef colorRef = [color CGColor];

    CGFloat alpha = CGColorGetAlpha(colorRef);

    return alpha;
}

+ (UIColor *)UIColorWithHexString:(NSString *)hexString {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;

    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:1.0f];
}

@end
