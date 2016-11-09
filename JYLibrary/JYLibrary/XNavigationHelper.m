//
//  XNavigationHelper.m
//  JYLibrary
//
//  Created by XJY on 15/11/18.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XNavigationHelper.h"
#import "XIOSVersion.h"

@implementation XNavigationHelper

//防止viewController被导航栏挡住
+ (void)preventShelteredFromNavigationBarForViewController:(UIViewController *)viewController {
    if([XIOSVersion isIOS7OrGreater]) {
        [viewController setEdgesForExtendedLayout:UIRectEdgeNone];//UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
//        [viewController setExtendedLayoutIncludesOpaqueBars:NO];
//        [viewController setModalPresentationCapturesStatusBarAppearance:NO];
    }
}

//隐藏导航栏的返回按钮
+ (void)hideNavigationBarBackButton:(UIViewController *)viewController {
    [viewController.navigationItem.backBarButtonItem setTitle:@""];
    [viewController.navigationItem setHidesBackButton:YES];
}

//禁止导航栏用户手势交互
+ (void)disableNavigationInteractiveGesture:(UINavigationController *)navigationController {
    if ([XIOSVersion isIOS7OrGreater]) {
        [navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
}

//设置导航栏背景色
+ (void)setNavigationBarBackgroundColor:(UIColor *)color navigationController:(UINavigationController *)navigationController {
    if ([XIOSVersion isIOS7OrGreater]) {
        [navigationController.navigationBar setBarTintColor:color];
    } else {
        [navigationController.navigationBar setTintColor:color];
    }
}

//推入控制器到导航控制器中
+ (void)pushViewController:(UIViewController *)viewController navigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
    if (!viewController || !navigationController) {
        return;
    }
    if ([navigationController.viewControllers containsObject:viewController]) {
        return;
    }
    
    [navigationController pushViewController:viewController animated:animated];
}

//小窗口从底部弹出
+ (void)presentViewControllerFormSheet:(UIViewController *)viewController onViewController:(UIViewController *)onViewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];//从底部弹出
    [viewController setModalPresentationStyle:UIModalPresentationFormSheet];//小窗口
    [onViewController presentViewController:viewController animated:animated completion:completion];
}

@end
