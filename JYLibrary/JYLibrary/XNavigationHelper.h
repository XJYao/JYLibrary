//
//  XNavigationHelper.h
//  JYLibrary
//
//  Created by XJY on 15/11/18.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface XNavigationHelper : NSObject

/**
 防止viewcontroller被导航栏挡住
 */
+ (void)preventShelteredFromNavigationBarForViewController:(UIViewController *)viewController;

/**
 隐藏导航栏的返回按钮
 */
+ (void)hideNavigationBarBackButton:(UIViewController *)viewController;

//禁止导航栏用户手势交互
+ (void)disableNavigationInteractiveGesture:(UINavigationController *)navigationController;

/**
 设置导航栏背景色
 */
+ (void)setNavigationBarBackgroundColor:(UIColor *)color navigationController:(UINavigationController *)navigationController;

/**
 推入控制器到导航控制器中
 */
+ (void)pushViewController:(UIViewController *)viewController navigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

/**
 小窗口从底部弹出
 */
+ (void)presentViewControllerFormSheet:(UIViewController *)viewController onViewController:(UIViewController *)onViewController animated:(BOOL)animated completion:(void (^)(void))completion;

@end
