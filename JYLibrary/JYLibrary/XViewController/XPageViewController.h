//
//  XPageViewController.h
//  JYLibrary
//
//  Created by XJY on 15/9/29.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XPageViewControllerDelegate <NSObject>

@optional
- (void)xPageScrollView:(UIScrollView *)scrollView scrollToPageIndex:(NSInteger)index;

- (void)xPageScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)xPageScrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2);
- (void)xPageScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)xPageScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
- (void)xPageScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)xPageScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
- (void)xPageScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)xPageScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

- (UIView *)xViewForZoomingInScrollView:(UIScrollView *)scrollView;
- (void)xPageScrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2);
- (void)xPageScrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;

- (BOOL)xPageScrollViewShouldScrollToTop:(UIScrollView *)scrollView;
- (void)xPageScrollViewDidScrollToTop:(UIScrollView *)scrollView;

@end

@interface XPageViewController : UIViewController

@property (nonatomic, weak)   id <XPageViewControllerDelegate> delegate;

@property (nonatomic, assign)   NSInteger       currentPageIndex;   //default is 0.

@property (nonatomic, assign)   BOOL            bounce;             //default is YES.

@property (nonatomic, strong)   NSMutableArray  *   viewControllers;

@property (nonatomic, strong, readonly)   UIScrollView    *   scrollView;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

- (void)updateFrame;

- (void)scrollToPageAtIndex:(NSInteger)atIndex;

- (void)addViewController:(UIViewController *)viewController;

- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)atIndex;

- (void)removeViewController:(UIViewController *)viewController;

- (void)removeViewControllerAtIndex:(NSInteger)atIndex;

@end
