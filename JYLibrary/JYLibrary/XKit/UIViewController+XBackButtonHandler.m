//
//  UIViewController+XBackButtonHandler.m
//  JYLibrary
//
//  Created by XJY on 16/8/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIViewController+XBackButtonHandler.h"


@interface UIViewController () <XBackButtonHandlerDelegate>

@end


@implementation UIViewController (XBackButtonHandler)

@end


@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count < navigationBar.items.count) {
        return YES;
    }

    BOOL shouldPop = YES;
    UIViewController *viewController = self.topViewController;
    if ([viewController respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [viewController navigationShouldPopOnBackButton];
    }

    if (shouldPop) {
        [self popViewControllerAnimated:YES];
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        for (UIView *subview in navigationBar.subviews) {
            if (subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }

    return NO;
}

@end
