//
//  UIViewController+XBackButtonHandler.h
//  JYLibrary
//
//  Created by XJY on 16/8/2.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XBackButtonHandlerDelegate <NSObject>

@optional

// Override this method in UIViewController derived class to handle 'Back' button click

- (BOOL)navigationShouldPopOnBackButton;

@end


@interface UIViewController (XBackButtonHandler)

@end
