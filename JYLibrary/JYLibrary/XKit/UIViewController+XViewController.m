//
//  UIViewController+XViewController.m
//  JYLibrary
//
//  Created by XJY on 16/7/29.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIViewController+XViewController.h"
#import "XIOSVersion.h"

@implementation UIViewController (XViewController)

- (void)adjustViewToTop {
    if ([XIOSVersion isIOS7OrGreater]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
}

@end
