//
//  UIScrollView+XScrollView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIScrollView+XScrollView.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@property (nonatomic, assign) BOOL                  isObserving;
@property (nonatomic, assign) XScrollDirectionBlock scrollDirectionBlock;
@property (nonatomic, assign) CGFloat               beginObserveScrollMinOffset;

@end

@implementation UIScrollView (XScrollView)

#pragma mark - Public

- (void)observeScrollDirection:(CGFloat)minOffset direction:(XScrollDirectionBlock)block {
    if (!self.isObserving) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:NULL];
        self.isObserving = YES;
    }

    self.beginObserveScrollMinOffset = minOffset;
    self.scrollDirectionBlock = block;
}

- (void)removeScrollDirectionObserver {
    if (self.isObserving) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
        self.isObserving = NO;
    }
}

#pragma mark - Private

#pragma mark Private Property

static const void *XScrollViewIsObservingKey = &XScrollViewIsObservingKey;
static const void *XScrollViewScrollDirectionBlockKey = &XScrollViewScrollDirectionBlockKey;
static const void *XScrollViewBeginObserveScrollMinOffsetKey = &XScrollViewBeginObserveScrollMinOffsetKey;

- (void)setIsObserving:(BOOL)observing {
    objc_setAssociatedObject(self, XScrollViewIsObservingKey, [NSNumber numberWithBool:observing], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isObserving {
    return [objc_getAssociatedObject(self, XScrollViewIsObservingKey) boolValue];
}

- (void)setScrollDirectionBlock:(XScrollDirectionBlock)block {
    objc_setAssociatedObject(self, XScrollViewScrollDirectionBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XScrollDirectionBlock)scrollDirectionBlock {
    return objc_getAssociatedObject(self, XScrollViewScrollDirectionBlockKey);
}

- (void)setBeginObserveScrollMinOffset:(CGFloat)offset {
    objc_setAssociatedObject(self, XScrollViewBeginObserveScrollMinOffsetKey, [NSNumber numberWithFloat:offset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)beginObserveScrollMinOffset {
    return [objc_getAssociatedObject(self, XScrollViewBeginObserveScrollMinOffsetKey) floatValue];
}

#pragma mark Private Method

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldContentOffset = [[change objectForKey:@"old"] CGPointValue];
        CGPoint newContentOffset = self.contentOffset;
        
        XScrollDirection scrollDirection = XScrollDirectionStop;

        if (CGPointEqualToPoint(newContentOffset, oldContentOffset)) {
            scrollDirection = XScrollDirectionStop;
        } else {
            if (newContentOffset.x == oldContentOffset.x) {
                scrollDirection = XScrollDirectionHorizontalStop;
            } else if (newContentOffset.x > oldContentOffset.x + self.beginObserveScrollMinOffset) {
                scrollDirection = XScrollDirectionHorizontalRight;
            } else if (newContentOffset.x < oldContentOffset.x - self.beginObserveScrollMinOffset) {
                scrollDirection = XScrollDirectionHorizontalLeft;
            }
            
            if (newContentOffset.y == oldContentOffset.y) {
                scrollDirection |= XScrollDirectionVerticalStop;
            } else if (newContentOffset.y > oldContentOffset.y + self.beginObserveScrollMinOffset) {
                scrollDirection |= XScrollDirectionVerticalBottom;
            } else if (newContentOffset.y < oldContentOffset.y - self.beginObserveScrollMinOffset) {
                scrollDirection |= XScrollDirectionVerticalTop;
            }
        }
        
        if (self.scrollDirectionBlock) {
            self.scrollDirectionBlock(scrollDirection);
        }
        
        id x_delegate = self.delegate;
        if(x_delegate && [x_delegate respondsToSelector:@selector(x_scrollDirection:)]) {
            [x_delegate x_scrollDirection:scrollDirection];
        }
    }
}

@end
