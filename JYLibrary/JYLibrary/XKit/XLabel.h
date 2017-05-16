//
//  XLabel.h
//  JYLibrary
//
//  Created by XJY on 16/1/29.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, TextVerticalAlignment) {
    TextVerticalAlignmentTop = 0,
    TextVerticalAlignmentCenter,
    TextVerticalAlignmentBottom,
};


@interface XLabel : UILabel

@property (nonatomic, assign) TextVerticalAlignment textVerticalAlignment;
@property (nonatomic, assign) CGFloat textVerticalOffset;

@end
