//
//  UITableView+XTableView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UITableView+XTableView.h"
#import "XIOSVersion.h"


@implementation UITableView (XTableView)

- (void)setNoDelaysContentTouches {
    [self setDelaysContentTouches:NO];
    if ([XIOSVersion isIOS8OrGreater]) {
        for (id view in self.subviews) {
            if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"]) {
                [view setDelaysContentTouches:NO];
            }
        }
    }
}

- (void)clearRemainSeparators {
    [self setTableFooterView:[[UIView alloc] init]];
}

- (void)setSeparatorEdgeInsetsZero {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([XIOSVersion isIOS8OrGreater]) {
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
    }
}

- (void)setSeparatorOrigin:(UITableViewCell *)cell originX:(CGFloat)originX {
    UIEdgeInsets edgeInsets = (originX == 0 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, originX, 0, 0));
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:edgeInsets];
    }
    if ([XIOSVersion isIOS8OrGreater]) {
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:edgeInsets];
        }
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
}

@end
