//
//  XFullScreenPopGestureNavigationController.m
//  JYLibrary
//
//  Created by XJY on 16/8/6.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XFullScreenPopGestureNavigationController.h"
#import <objc/runtime.h>

@interface XPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end


@implementation XPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (!topViewController.x_interactivePopEnable) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.x_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@interface XFullScreenPopGestureNavigationController ()

@property (nonatomic, strong) XPopGestureRecognizerDelegate *popGestureRecognizerDelegate;

@end

@implementation XFullScreenPopGestureNavigationController


static BOOL hasExchanged = NO;

@synthesize x_fullScreenPopGestureRecognizer;

- (instancetype)init {
    self = [super init];
    if (self) {
        _x_fullScreenPopGestureEnable = hasExchanged;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _x_fullScreenPopGestureEnable = hasExchanged;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _x_fullScreenPopGestureEnable = hasExchanged;
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

- (void)x_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.x_fullScreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.x_fullScreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.x_fullScreenPopGestureRecognizer.delegate = self.x_popGestureRecognizerDelegate;
        [self.x_fullScreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        [self x_pushViewController:viewController animated:animated];
    }
}

- (XPopGestureRecognizerDelegate *)x_popGestureRecognizerDelegate {
    if (!_popGestureRecognizerDelegate) {
        _popGestureRecognizerDelegate = [[XPopGestureRecognizerDelegate alloc] init];
        _popGestureRecognizerDelegate.navigationController = self;
    }
    
    return _popGestureRecognizerDelegate;
}

- (void)setX_fullScreenPopGestureEnable:(BOOL)enable {
    if (_x_fullScreenPopGestureEnable == enable) {
        return;
    }
    
    _x_fullScreenPopGestureEnable = enable;
    
    Class class = [self class];
    
    SEL originalSelector = @selector(pushViewController:animated:);
    SEL swizzledSelector = @selector(x_pushViewController:animated:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    hasExchanged = !hasExchanged;
}

- (UIPanGestureRecognizer *)x_fullScreenPopGestureRecognizer {
    
    if (!x_fullScreenPopGestureRecognizer) {
        x_fullScreenPopGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        x_fullScreenPopGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return x_fullScreenPopGestureRecognizer;
}

@end

@implementation UIViewController (XPopGesture)

- (BOOL)x_interactivePopEnable {
    id enableObject = objc_getAssociatedObject(self, _cmd);
    
    BOOL enable = YES;
    
    if (enableObject) {
        enable = [enableObject boolValue];
    } else {
        [self setX_interactivePopEnable:enable];
    }
    
    return enable;
}

- (void)setX_interactivePopEnable:(BOOL)enable {
    objc_setAssociatedObject(self, @selector(x_interactivePopEnable), @(enable), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)x_interactivePopMaxAllowedInitialDistanceToLeftEdge {
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif
}

- (void)setX_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)distance {
    SEL key = @selector(x_interactivePopMaxAllowedInitialDistanceToLeftEdge);
    objc_setAssociatedObject(self, key, @(MAX(0, distance)), OBJC_ASSOCIATION_ASSIGN);
}

@end
