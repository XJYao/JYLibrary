//
//  XPageViewController.m
//  JYLibrary
//
//  Created by XJY on 15/9/29.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XPageViewController.h"
#import "XTool.h"
#import "XScrollView.h"

@interface XPageViewController () <UIScrollViewDelegate> {
    XScrollView *pageScrollView;
}

@end

@implementation XPageViewController

#pragma mark ---------- Public ----------

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewControllers = [[NSMutableArray alloc] init];
        _currentPageIndex = 0;
        _bounce = YES;
    }
    return self;
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    self = [self init];
    if (self) {
        if (![XTool isArrayEmpty:viewControllers]) {
            [_viewControllers removeAllObjects];
            [_viewControllers addObjectsFromArray:viewControllers];
        }
    }
    return self;
}

- (void)updateFrame {
    if (!pageScrollView) {
        return;
    }
    
    CGRect scrollViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (!CGRectEqualToRect(pageScrollView.frame, scrollViewFrame)) {
        [pageScrollView setFrame:scrollViewFrame];
    }
    
    CGSize contentSize = CGSizeMake(pageScrollView.frame.size.width * pageScrollView.subviews.count, pageScrollView.frame.size.height);
    if (!CGSizeEqualToSize(pageScrollView.contentSize, contentSize)) {
        [pageScrollView setContentSize:contentSize];
    }
    
    if ([XTool isArrayEmpty:self.childViewControllers]) {
        return;
    }
    
    for (UIViewController *childViewController in self.childViewControllers) {
        if (childViewController.view.superview) {
            NSInteger index = [self.childViewControllers indexOfObject:childViewController];
            
            CGRect childViewFrame = CGRectMake(pageScrollView.frame.size.width * index, 0, pageScrollView.frame.size.width, pageScrollView.frame.size.height);
            if (!CGRectEqualToRect(childViewController.view.frame, childViewFrame)) {
                [childViewController.view setFrame:childViewFrame];
            }
        }
    }
}

- (void)scrollToPageAtIndex:(NSInteger)atIndex {
    [self navigateToChildViewControllerAtIndex:_currentPageIndex];
    _currentPageIndex = atIndex;
    [self scrollToPage:_currentPageIndex];
}

- (void)addViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    
    if (!_viewControllers) {
        _viewControllers = [[NSMutableArray alloc] init];
    }
    [_viewControllers x_addObject:viewController];
    
    if (!pageScrollView) {
        return;
    }
    [self addChildViewController:viewController atIndex:_viewControllers.count - 1];
    
    [self updateFrame];
}

- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)atIndex {
    if (!viewController) {
        return;
    }
    
    if (!_viewControllers) {
        _viewControllers = [[NSMutableArray alloc] init];
    }
    
    if (atIndex == NSNotFound || atIndex < 0 || atIndex > _viewControllers.count) {
        return;
    }

    [_viewControllers x_insertObject:viewController atIndex:atIndex];

    if (!pageScrollView) {
        return;
    }
    
    [self addChildViewControllers];
    
    [self updateFrame];
}

- (void)removeViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    
    NSInteger atIndex = NSNotFound;
    if (![XTool isArrayEmpty:self.childViewControllers]) {
        atIndex = [self.childViewControllers indexOfObject:viewController];
    }
    
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }

    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [_viewControllers removeObject:viewController];
    
    [self updateFrame];
    
    if (_currentPageIndex != NSNotFound && _currentPageIndex >= 0) {
        if (_currentPageIndex == atIndex) {
            if (_currentPageIndex == _viewControllers.count) {
                _currentPageIndex --;
            }
            [self scrollToPageAtIndex:_currentPageIndex];
        } else if (_currentPageIndex > atIndex) {
            _currentPageIndex --;
            [self scrollToPageAtIndex:_currentPageIndex];
        }
    }
}

- (void)removeViewControllerAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }
    
    if (atIndex >= self.childViewControllers.count) {
        return;
    }
    
    UIViewController *childViewController = [self.childViewControllers x_objectAtIndex:atIndex];
    [self removeViewController:childViewController];
}

#pragma mark property

- (UIScrollView *)scrollView {
    return pageScrollView;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    [self scrollToPageAtIndex:currentPageIndex];
}

- (void)setBounce:(BOOL)bounce {
    _bounce = bounce;
    [pageScrollView setBounces:_bounce];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers) {
        [_viewControllers removeAllObjects];
    } else {
        _viewControllers = [[NSMutableArray alloc] init];
    }
    
    if (![XTool isArrayEmpty:viewControllers]) {
        [_viewControllers addObjectsFromArray:viewControllers];
    }
    
    if (!pageScrollView) {
        return;
    }
    
    [self addChildViewControllers];
    
    [self updateFrame];
}

#pragma mark ---------- life cycle ----------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self addPageScrollView];
    [self addChildViewControllers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFrame];
    [self scrollToPageAtIndex:_currentPageIndex];
    [self childViewControllerBeginAppearance:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self childViewControllerEndAppearance];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self childViewControllerBeginAppearance:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self childViewControllerEndAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateFrame];
    [self scrollToPageAtIndex:_currentPageIndex];
}

//Do not delete next two method! if you do that, childViewController will run viewWillAppear before it appear on the screen.
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {//iOS6+
    return NO;
}

#pragma mark ---------- Private ----------

- (void)initialize {
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)addPageScrollView {
    pageScrollView = [[XScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [pageScrollView setBackgroundColor:[UIColor clearColor]];
    [pageScrollView setPagingEnabled:YES];
    [pageScrollView setBounces:_bounce];
    [pageScrollView setShowsHorizontalScrollIndicator:NO];
    [pageScrollView setShowsVerticalScrollIndicator:NO];
    [pageScrollView setScrollsToTop:NO];
    [pageScrollView setDelaysContentTouches:NO];
    [pageScrollView setDelegate:self];
    [self.view addSubview:pageScrollView];
}

//add viewControllers to self's childViewController, add viewController's view on the scrollview
- (void)addChildViewControllers {
    for (UIViewController *childViewController in self.childViewControllers) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
    }
    
    for (UIView *subView in pageScrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (![XTool isArrayEmpty:_viewControllers]) {
        for (NSInteger i = 0; i< _viewControllers.count; i ++) {
            UIViewController *childViewController = [_viewControllers x_objectAtIndex:i];
            [self addChildViewController:childViewController atIndex:i];
        }
    }
}

- (void)addChildViewController:(UIViewController *)childViewController atIndex:(NSInteger)atIndex {
    [self addChildViewController:childViewController];
    
    if (!childViewController.view.superview) {
        
        CGRect childViewFrame = CGRectMake(pageScrollView.frame.size.width * atIndex, 0, pageScrollView.frame.size.width, pageScrollView.frame.size.height);
        if (!CGRectEqualToRect(childViewController.view.frame, childViewFrame)) {
            [childViewController.view setFrame:childViewFrame];
        }
        
        [pageScrollView addSubview:childViewController.view];
        [childViewController didMoveToParentViewController:self];
    }
}

- (void)childViewControllerBeginAppearance:(BOOL)isAppearing animated:(BOOL)animated  {
    if ([XTool isArrayEmpty:self.childViewControllers]) {
        return;
    }
    
    if (_currentPageIndex == NSNotFound || _currentPageIndex < 0) {
        return;
    }
    
    if (_currentPageIndex >= self.childViewControllers.count) {
        return;
    }
    
    UIViewController *childViewController = [self.childViewControllers x_objectAtIndex:_currentPageIndex];
    if (childViewController.view.superview != nil) {
        [childViewController beginAppearanceTransition:isAppearing animated:animated];
    }
}

- (void)childViewControllerEndAppearance {
    if ([XTool isArrayEmpty:self.childViewControllers]) {
        return;
    }
    
    if (_currentPageIndex == NSNotFound || _currentPageIndex < 0) {
        return;
    }
    
    if (_currentPageIndex >= self.childViewControllers.count) {
        return;
    }
    
    UIViewController *childViewController = [self.childViewControllers x_objectAtIndex:_currentPageIndex];
    if (childViewController.view.superview) {
        [childViewController endAppearanceTransition];
    }
}

- (void)scrollToPage:(NSInteger)atIndex {
    if (atIndex == NSNotFound) {
        return;
    }
    
    if (!pageScrollView) {
        return;
    }
    
    CGPoint contentOffset = pageScrollView.contentOffset;
    if (contentOffset.x != pageScrollView.frame.size.width * atIndex) {
        contentOffset.x = pageScrollView.frame.size.width * atIndex;
        [pageScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)navigateToChildViewControllerAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }
    
    if (_currentPageIndex == NSNotFound || _currentPageIndex < 0) {
        return;
    }
    
    if (_currentPageIndex == atIndex) {
        return;
    }
    
    if ([XTool isArrayEmpty:self.childViewControllers]) {
        return;
    }
    
    if (atIndex >= self.childViewControllers.count || _currentPageIndex >= self.childViewControllers.count) {
        return;
    }
    
    UIViewController *oldViewController = [self.childViewControllers x_objectAtIndex:_currentPageIndex];
    UIViewController *newViewController = [self.childViewControllers x_objectAtIndex:atIndex];
    
    [oldViewController viewWillDisappear:YES];
    [newViewController viewWillAppear:YES];
    [oldViewController viewDidDisappear:YES];
    [newViewController viewDidAppear:YES];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidScroll:)]) {
        [_delegate xPageScrollViewDidScroll:scrollView];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollView:scrollToPageIndex:)]) {
        
        CGFloat offsetX = scrollView.contentOffset.x;

        NSInteger atIndex = 0;
        
        if (offsetX < 0) {
            atIndex = 0;
        } else if (offsetX > scrollView.frame.size.width * _viewControllers.count) {
            atIndex = _viewControllers.count - 1;
        } else {
            atIndex = offsetX / scrollView.frame.size.width;
        }

        [_delegate xPageScrollView:scrollView scrollToPageIndex:atIndex];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidZoom:)]) {
        [_delegate xPageScrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewWillBeginDragging:)]) {
        [_delegate xPageScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_delegate xPageScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate xPageScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewWillBeginDecelerating:)]) {
        [_delegate xPageScrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidEndDecelerating:)]) {
        [_delegate xPageScrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidEndScrollingAnimation:)]) {
        [_delegate xPageScrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xViewForZoomingInScrollView:)]) {
        return [_delegate xViewForZoomingInScrollView:scrollView];
    } else {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewWillBeginZooming:withView:)]) {
        [_delegate xPageScrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidEndZooming:withView:atScale:)]) {
        [_delegate xPageScrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewShouldScrollToTop:)]) {
        return [_delegate xPageScrollViewShouldScrollToTop:scrollView];
    } else {
        return NO;
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if(_delegate && [_delegate respondsToSelector:@selector(xPageScrollViewDidScrollToTop:)]) {
        [_delegate xPageScrollViewDidScrollToTop:scrollView];
    }
}

@end
