//
//  UIScrollView+XScrollView.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, XScrollDirection) {
    XScrollDirectionHorizontalStop      = 1 << 0,
    XScrollDirectionHorizontalLeft      = 1 << 1,
    XScrollDirectionHorizontalRight     = 1 << 2,
    
    XScrollDirectionVerticalStop        = 1 << 3,
    XScrollDirectionVerticalTop         = 1 << 4,
    XScrollDirectionVerticalBottom      = 1 << 5,
    
    XScrollDirectionStop                = XScrollDirectionHorizontalStop | XScrollDirectionVerticalStop
};

@protocol XScrollViewDirectionDelegate <UIScrollViewDelegate>

@optional
- (void)x_scrollDirection:(XScrollDirection)scrollDirection;

@end

@interface UIScrollView (XScrollView)

typedef void (^XScrollDirectionBlock)(XScrollDirection scrollDirection);

- (void)observeScrollDirection:(CGFloat)minOffset direction:(XScrollDirectionBlock)block;

- (void)removeScrollDirectionObserver;

@end
