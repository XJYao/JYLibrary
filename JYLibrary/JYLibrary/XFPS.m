//
//  XFPS.m
//  JYLibrary
//
//  Created by XJY on 16/5/20.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XFPS.h"
#import <CoreText/CoreText.h>

@interface XFPS () {
    CADisplayLink *displayLink;
    NSUInteger count;
    NSTimeInterval lastTime;
    UIFont *font;
    UIFont *subFont;
    UIColor *whiteColor;
    
    BOOL isStop;
}

@end

@implementation XFPS

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        isStop = YES;
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.700]];
        [self.layer setCornerRadius:5];
        [self setClipsToBounds:YES];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setUserInteractionEnabled:NO];
        
        font = [UIFont fontWithName:@"Menlo" size:14];
        if (font) {
            subFont = [UIFont fontWithName:@"Menlo" size:4];
        } else {
            font = [UIFont fontWithName:@"Courier" size:14];
            subFont = [UIFont fontWithName:@"Courier" size:4];
        }
        
        whiteColor = [UIColor whiteColor];
        
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    isStop = NO;
}

- (void)stop {
    if (isStop) {
        return;
    }
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [displayLink invalidate];
    isStop = YES;
}

- (void)tick:(CADisplayLink *)link {
    if (lastTime == 0) {
        lastTime = link.timestamp;
        return;
    }
    
    count++;
    NSTimeInterval delta = link.timestamp - lastTime;
    if (delta < 1) return;
    lastTime = link.timestamp;
    float fps = count / delta;
    count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSString *text = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
    
    NSRange foregroundColorRange = NSMakeRange(0, text.length - 3);
    NSRange foregroundWhiteColorRange = NSMakeRange(text.length - 3, 3);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(id)color.CGColor range:foregroundColorRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:foregroundColorRange];
    [attributedString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(id)whiteColor.CGColor range:foregroundWhiteColorRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:whiteColor range:foregroundWhiteColorRange];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    [attributedString addAttribute:NSFontAttributeName value:subFont range:NSMakeRange(text.length - 4, 1)];
    
    [self setAttributedText:attributedString];
}

@end
