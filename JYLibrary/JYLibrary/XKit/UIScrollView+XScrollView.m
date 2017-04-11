//
//  UIScrollView+XScrollView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIScrollView+XScrollView.h"
#import <objc/runtime.h>

typedef void (^XScrollViewObserveContentSizeBlock)(CGSize contentSize);
typedef void (^XScrollDirectionBlock)(XScrollDirection scrollDirection);

@interface UIScrollView ()

@property (nonatomic, assign) BOOL                  x_isContentSizeObserving;
@property (nonatomic, assign) XScrollViewObserveContentSizeBlock x_observeContentSizeBlock;

@property (nonatomic, assign) BOOL                  x_isContentOffsetObserving;
@property (nonatomic, assign) XScrollDirectionBlock x_scrollDirectionBlock;
@property (nonatomic, assign) CGFloat               x_beginObserveScrollMinOffset;

@end

@implementation UIScrollView (XScrollView)

#pragma mark - Public

- (void)x_observeContentSize:(void (^)(CGSize))block {
    self.x_observeContentSizeBlock = block;
    if (!self.x_isContentSizeObserving) {
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
        self.x_isContentSizeObserving = YES;
    }
}

- (void)x_removeContentSizeObserver {
    if (self.x_isContentSizeObserving) {
        [self removeObserver:self forKeyPath:@"contentSize"];
        self.x_isContentSizeObserving = NO;
    }
}

- (void)x_observeScrollDirection:(CGFloat)minOffset direction:(void (^)(XScrollDirection))block {
    self.x_beginObserveScrollMinOffset = minOffset;
    self.x_scrollDirectionBlock = block;
    if (!self.x_isContentOffsetObserving) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:NULL];
        self.x_isContentOffsetObserving = YES;
    }
}

- (void)x_removeScrollDirectionObserver {
    if (self.x_isContentOffsetObserving) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
        self.x_isContentOffsetObserving = NO;
    }
}

#pragma mark - Private

#pragma mark Private Property

static const void *XScrollViewIsContentSizeObservingKey = &XScrollViewIsContentSizeObservingKey;
static const void *XScrollViewObserveContentSizeBlockKey = &XScrollViewObserveContentSizeBlockKey;

- (void)setX_isContentSizeObserving:(BOOL)isObserving {
    objc_setAssociatedObject(self, XScrollViewIsContentSizeObservingKey, [NSNumber numberWithBool:isObserving], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)x_isContentSizeObserving {
    return [objc_getAssociatedObject(self, XScrollViewIsContentSizeObservingKey) boolValue];
}

- (void)setX_observeContentSizeBlock:(XScrollViewObserveContentSizeBlock)block {
    objc_setAssociatedObject(self, XScrollViewObserveContentSizeBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XScrollViewObserveContentSizeBlock)x_observeContentSizeBlock {
    return objc_getAssociatedObject(self, XScrollViewObserveContentSizeBlockKey);
}

static const void *XScrollViewIsContentOffsetObservingKey = &XScrollViewIsContentOffsetObservingKey;
static const void *XScrollViewScrollDirectionBlockKey = &XScrollViewScrollDirectionBlockKey;
static const void *XScrollViewBeginObserveScrollMinOffsetKey = &XScrollViewBeginObserveScrollMinOffsetKey;

- (void)setX_isContentOffsetObserving:(BOOL)isObserving {
    objc_setAssociatedObject(self, XScrollViewIsContentOffsetObservingKey, [NSNumber numberWithBool:isObserving], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)x_isContentOffsetObserving {
    return [objc_getAssociatedObject(self, XScrollViewIsContentOffsetObservingKey) boolValue];
}

- (void)setX_scrollDirectionBlock:(XScrollDirectionBlock)block {
    objc_setAssociatedObject(self, XScrollViewScrollDirectionBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XScrollDirectionBlock)x_scrollDirectionBlock {
    return objc_getAssociatedObject(self, XScrollViewScrollDirectionBlockKey);
}

- (void)setX_beginObserveScrollMinOffset:(CGFloat)offset {
    objc_setAssociatedObject(self, XScrollViewBeginObserveScrollMinOffsetKey, [NSNumber numberWithFloat:offset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)x_beginObserveScrollMinOffset {
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
            } else if (newContentOffset.x > oldContentOffset.x + self.x_beginObserveScrollMinOffset) {
                scrollDirection = XScrollDirectionHorizontalRight;
            } else if (newContentOffset.x < oldContentOffset.x - self.x_beginObserveScrollMinOffset) {
                scrollDirection = XScrollDirectionHorizontalLeft;
            }
            
            if (newContentOffset.y == oldContentOffset.y) {
                scrollDirection |= XScrollDirectionVerticalStop;
            } else if (newContentOffset.y > oldContentOffset.y + self.x_beginObserveScrollMinOffset) {
                scrollDirection |= XScrollDirectionVerticalBottom;
            } else if (newContentOffset.y < oldContentOffset.y - self.x_beginObserveScrollMinOffset) {
                scrollDirection |= XScrollDirectionVerticalTop;
            }
        }
        
        if (self.x_scrollDirectionBlock) {
            self.x_scrollDirectionBlock(scrollDirection);
        }
        
        id x_delegate = self.delegate;
        if(x_delegate && [x_delegate respondsToSelector:@selector(x_scrollView:scrollDirection:)]) {
            [x_delegate x_scrollView:self scrollDirection:scrollDirection];
        }
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        if (self.x_observeContentSizeBlock) {
            self.x_observeContentSizeBlock(self.contentSize);
        }
        id x_delegate = self.delegate;
        if(x_delegate && [x_delegate respondsToSelector:@selector(x_scrollView:contentSize:)]) {
            [x_delegate x_scrollView:self contentSize:self.contentSize];
        }
    }
}

#pragma mark - 解决侧滑手势冲突问题

//以下三个方法是解决侧滑手势和scrollview横向滚动冲突的问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
    
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < 50 && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
    
}

@end
