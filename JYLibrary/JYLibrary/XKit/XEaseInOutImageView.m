//
//  XEaseInOutImageView.m
//  JYLibrary
//
//  Created by XJY on 17/2/16.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import "XEaseInOutImageView.h"

@implementation XEaseInOutImageView

- (void)setImage:(UIImage *)image {
    
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDuration:0.5f];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:transition forKey:nil];
    
    [super setImage:image];
}

@end
