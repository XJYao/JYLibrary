//
//  UIAlertView+XAlertView.h
//  JYLibrary
//
//  Created by XJY on 16/6/4.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAlertView (XAlertView)

typedef void (^XAlertViewBlock)(UIAlertView *alertView, NSString *buttonTitle, NSInteger buttonIndex, id object);

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message object:(id)object buttonTitles:(NSArray<NSString *> *)buttonTitles alertViewBlock:(XAlertViewBlock)block;

@end
