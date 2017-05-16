//
//  UILabel+XLabel.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UILabel+XLabel.h"
#import "XTool.h"
#import "XIOSVersion.h"


@implementation UILabel (XLabel)

- (CGSize)labelSize {
    return ([XTool isStringEmpty:self.text] ? CGSizeZero : [self.text sizeWithFont:self.font]);
}

- (CGSize)labelSize:(CGSize)maximumLabelSize {
    CGSize labelSize;
    if ([XTool isStringEmpty:self.text]) {
        labelSize = CGSizeZero;
    } else {
        if ([XIOSVersion isIOS7OrGreater]) {
            NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, nil];
            labelSize = [self.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        } else {
            labelSize = [self.text sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    return labelSize;
}

- (CGFloat)widthForHeight:(CGFloat)height {
    CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, height);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.width;
}

- (CGFloat)widthForHeight:(CGFloat)height maxWidth:(CGFloat)maxWidth {
    CGSize maximumLabelSize = CGSizeMake(maxWidth, height);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.width;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.height + 1;
}

- (CGFloat)heightForWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight {
    CGSize maximumLabelSize = CGSizeMake(width, maxHeight);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.height + 1;
}

- (void)allowMultiLine {
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
}

@end
