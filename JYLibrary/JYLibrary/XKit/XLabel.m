//
//  XLabel.m
//  JYLibrary
//
//  Created by XJY on 16/1/29.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XLabel.h"

@implementation XLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textVerticalAlignment = TextVerticalAlignmentCenter;
        _textVerticalOffset = 0.0f;
    }
    return self;
}

- (void)setTextVerticalAlignment:(TextVerticalAlignment)textVerticalAlignment {
    _textVerticalAlignment = textVerticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch(_textVerticalAlignment) {
        case TextVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y + _textVerticalOffset;
            break;
        case TextVerticalAlignmentCenter:
            textRect.origin.y = bounds.origin.y + _textVerticalOffset + (bounds.size.height - textRect.size.height) / 2.0;
            break;
        case TextVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height + _textVerticalOffset;
            break;
        default:
            textRect.origin.y = bounds.origin.y + _textVerticalOffset + (bounds.size.height - textRect.size.height) / 2.0;
            break;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect actualRect=[self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
