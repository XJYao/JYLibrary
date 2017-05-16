//
//  XTableViewCell.m
//  JYLibrary
//
//  Created by XJY on 16/4/24.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XTableViewCell.h"
#import "XIOSVersion.h"


@implementation XTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        if ([XIOSVersion isIOS7OrGreater] && ![XIOSVersion isIOS8OrGreater]) {
            for (UIView *view in self.subviews) {
                if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewCellScrollView"]) {
                    UIScrollView *sv = (UIScrollView *)view;
                    [sv setDelaysContentTouches:NO];
                    break;
                }
            }
        }
    }

    return self;
}

- (void)setSeparatorOriginX:(CGFloat)originX {
    UIEdgeInsets edgeInsets = (originX == 0 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, originX, 0, 0));
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:edgeInsets];
    }
    if ([XIOSVersion isIOS8OrGreater]) {
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:edgeInsets];
        }
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
    }
}

@end
