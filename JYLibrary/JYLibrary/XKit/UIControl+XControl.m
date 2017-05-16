//
//  UIControl+XControl.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIControl+XControl.h"


@implementation UIControl (XControl)

- (void)addTarget:(id)target normalAction:(SEL)normalAction highlightAction:(SEL)highlightAction clickAction:(SEL)clickAction {
    [self addTarget:target action:normalAction forControlEvents:UIControlEventTouchCancel | UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchUpOutside];
    [self addTarget:target action:highlightAction forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter | UIControlEventTouchDragInside];
    [self addTarget:target action:clickAction forControlEvents:UIControlEventTouchUpInside];
}

@end
