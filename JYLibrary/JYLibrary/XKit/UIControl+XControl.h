//
//  UIControl+XControl.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIControl (XControl)

- (void)addTarget:(id)target normalAction:(SEL)normalAction highlightAction:(SEL)highlightAction clickAction:(SEL)clickAction;

@end
