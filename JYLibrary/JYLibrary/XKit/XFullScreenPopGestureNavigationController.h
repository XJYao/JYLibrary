//
//  XFullScreenPopGestureNavigationController.h
//  JYLibrary
//
//  Created by XJY on 16/8/6.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

/// "XFullScreenPopGestureNavigationController" extends UINavigationController's swipe-
/// to-pop behavior in iOS 7+ by supporting fullscreen pan gesture. Instead of
/// screen edge, you can now swipe from any place on the screen and the onboard
/// interactive pop transition works seamlessly.
///
/// Adding the implementation file of this category to your target will
/// automatically patch UINavigationController with this feature.
@interface XFullScreenPopGestureNavigationController : UINavigationController

/// Whether this full screen pop gesture is enable, default is NO.
@property (nonatomic, assign) BOOL x_fullScreenPopGestureEnable;

/// The gesture recognizer that actually handles interactive pop.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *x_fullScreenPopGestureRecognizer;

@end

/// Allows any view controller to disable interactive pop gesture, which might
/// be necessary when the view controller itself handles pan gesture in some
/// cases.
@interface UIViewController (XPopGesture)

/// Whether the interactive pop gesture is enable when contained in a navigation
/// stack.
@property (nonatomic, assign) BOOL x_interactivePopEnable;

/// Max allowed initial distance to left edge when you begin the interactive pop
/// gesture. 0 by default, which means it will ignore this limit.
@property (nonatomic, assign) CGFloat x_interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end
