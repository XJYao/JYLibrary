//
//  UIAlertView+XAlertView.m
//  JYLibrary
//
//  Created by XJY on 16/6/4.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIAlertView+XAlertView.h"
#import <objc/runtime.h>


@interface UIAlertView () <UIAlertViewDelegate>

@end


@implementation UIAlertView (XAlertView)

static const void *kAssociatedObjectKey = &kAssociatedObjectKey;
static const void *kAssociatedXAlertViewBlockKey = &kAssociatedXAlertViewBlockKey;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message object:(id)object buttonTitles:(NSArray<NSString *> *)buttonTitles alertViewBlock:(XAlertViewBlock)block {
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];

    if (self) {
        if (buttonTitles && buttonTitles.count > 0) {
            for (NSString *buttonTitle in buttonTitles) {
                [self addButtonWithTitle:buttonTitle];
            }
        }

        objc_setAssociatedObject(self, kAssociatedObjectKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kAssociatedXAlertViewBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return self;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id blockObject = objc_getAssociatedObject(alertView, kAssociatedXAlertViewBlockKey);

    if (blockObject) {
        id object = objc_getAssociatedObject(alertView, kAssociatedObjectKey);
        XAlertViewBlock alertViewBlock = blockObject;
        alertViewBlock(alertView, [alertView buttonTitleAtIndex:buttonIndex], buttonIndex, object);
    }
}

@end
