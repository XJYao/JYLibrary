//
//  XCircleProgress.m
//  JYLibrary
//
//  Created by XJY on 16/1/27.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XCircleProgress.h"
#import "XTool.h"
#import "UILabel+XLabel.h"
#import "UIColor+XColor.h"
#import "XThread.h"
#import "XNotification.h"
#import "XMacro.h"
#import "NSArray+XArray.h"

@interface XCircleProgress () {
    NSArray *observableKeypaths;
}

@end

@implementation XCircleProgress

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self registerForKVO];
        [self addUI];
        
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            [self setNeedsLayout];
        }
    }
    return self;
}

#pragma mark - Private

- (void)dealloc {
    [self unregisterFromKVO];
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    
    observableKeypaths = @[
                           @"progress",
                           @"textFont",
                           @"text"
                           ];

    _progress = 0;
    _indicatorGradient = YES;
    _indicatorRadius = 50;
    
    _indicatorAlpha = 1.0f;
    _indicatorBackgroundAlpha = 1.0f;
    _indicatorColor = [UIColor whiteColor];
    _indicatorBackgroundColor = [UIColor whiteColor];
    _indicatorWidth = 5;
    _indicatorBackgroundWidth = 3;
    
    _textColor = [UIColor whiteColor];
    _textFont = systemBoldFontWithSize(17);
    _text = @"";
    _pointImageSize = CGSizeZero;
}

- (void)registerForKVO {
    for (NSString *key in observableKeypaths) {
        [[XNotification sharedManager] addKVO:self forObject:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *key in observableKeypaths) {
        [[XNotification sharedManager] removeKVO:self forObject:self forKeyPath:key];
    }
}

- (void)addUI {
    _textLabel = [[UILabel alloc] init];
    [_textLabel setBackgroundColor:[UIColor clearColor]];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:_textColor];
    [_textLabel setFont:_textFont];
    [_textLabel setText:_text];
    [_textLabel allowMultiLine];
    [self addSubview:_textLabel];
    
    _pointImageView = [[UIImageView alloc] init];
    [_pointImageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_pointImageView];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textLabelWidth = 0;
    CGFloat textLabelHeight = 0;
    CGFloat textLabelX = 0;
    CGFloat textLabelY = 0;
    if (![XTool isStringEmpty:_textLabel.text]) {
        textLabelWidth = [_textLabel labelSize].width;
        textLabelHeight = [_textLabel heightForWidth:textLabelWidth];
        
        textLabelX = (self.frame.size.width - textLabelWidth) / 2.0;
        textLabelY = (self.frame.size.width - textLabelHeight) / 2.0;
    }
    
    [_textLabel setFrame:CGRectMake(textLabelX, textLabelY, textLabelWidth, textLabelHeight)];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat startAngle = - M_PI_2;

    //draw background
    if (_indicatorBackgroundColor) {
        NSArray *RGB = [UIColor getRGBFromColor:_indicatorBackgroundColor];
        
        CGFloat R = [[RGB x_objectAtIndex:0] floatValue];
        CGFloat G = [[RGB x_objectAtIndex:1] floatValue];
        CGFloat B = [[RGB x_objectAtIndex:2] floatValue];

        UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:_indicatorBackgroundAlpha];
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        CGContextSetLineWidth(context, _indicatorBackgroundWidth);
        
        CGFloat endAngle = startAngle + 2 * M_PI;
        CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //draw indicator
    if (_indicatorColor) {
        NSArray *RGB = [UIColor getRGBFromColor:_indicatorColor];
        
        CGFloat R = [[RGB x_objectAtIndex:0] floatValue];
        CGFloat G = [[RGB x_objectAtIndex:1] floatValue];
        CGFloat B = [[RGB x_objectAtIndex:2] floatValue];

        if (!_indicatorGradient) {
            UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:_indicatorAlpha];
            CGContextSetStrokeColorWithColor(context, [color CGColor]);
            
            CGContextSetLineWidth(context, _indicatorWidth);
            CGFloat endAngle = startAngle + _progress * 2 * M_PI;
            CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
            CGContextDrawPath(context, kCGPathStroke);
        } else {

            for (CGFloat progress = 0; progress <= _progress; progress += 0.01) {
                UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:(_indicatorBackgroundAlpha + (_indicatorAlpha - _indicatorBackgroundAlpha) * progress)];
                CGContextSetStrokeColorWithColor(context, [color CGColor]);
                
                CGFloat currentIndicatorWidth = _indicatorBackgroundWidth + (_indicatorWidth - _indicatorBackgroundWidth) * progress;
                CGContextSetLineWidth(context, currentIndicatorWidth);
                
                CGFloat endAngle = startAngle + 0.01 * 2 * M_PI;
                CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
                
                CGContextDrawPath(context, kCGPathStroke);
                
                startAngle = endAngle;
                
                if (_pointImageView && _pointImageView.image) {
                    CGFloat pointImageViewWidth = 0;
                    CGFloat pointImageViewHeight = 0;
                    
                    if (CGSizeEqualToSize(_pointImageSize, CGSizeZero)) {
                        pointImageViewWidth = _pointImageView.image.size.width;
                        pointImageViewHeight = _pointImageView.image.size.height;
                        
                        if (pointImageViewWidth > _indicatorWidth * 2) {
                            pointImageViewWidth = _indicatorWidth * 2;
                        }
                        
                        if (pointImageViewHeight > _indicatorWidth * 2) {
                            pointImageViewHeight = _indicatorWidth * 2;
                        }
                    } else {
                        pointImageViewWidth = _pointImageSize.width;
                        pointImageViewHeight = _pointImageSize.height;
                    }
                    
                    CGFloat pointImageViewX = _indicatorRadius * cos(endAngle) + self.frame.size.width / 2.0 - pointImageViewWidth / 2.0;
                    CGFloat pointImageViewY = _indicatorRadius * sin(endAngle) + self.frame.size.height / 2.0 - pointImageViewHeight / 2.0;
                    
                    [_pointImageView setFrame:CGRectMake(pointImageViewX, pointImageViewY, pointImageViewWidth, pointImageViewHeight)];
                }
            }
        }
    }
}

#pragma mark - Property

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_textLabel setTextColor:_textColor];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    x_dispatch_main_async(^{
        if ([keyPath isEqualToString:@"progress"])
        {
            [self setNeedsDisplay];
        }
        
        else if ([keyPath isEqualToString:@"textFont"])
        {
            [_textLabel setFont:_textFont];
            [self setNeedsLayout];
        }
        
        else if ([keyPath isEqualToString:@"text"])
        {
            [_textLabel setText:_text];
            [self setNeedsLayout];
        }
    });
}

@end
