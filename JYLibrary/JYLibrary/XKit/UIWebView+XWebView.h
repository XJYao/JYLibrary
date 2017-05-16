//
//  UIWebView+XWebView.h
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIWebView (XWebView)

/**
 修改网页的宽度与webView宽度一致
 */
- (void)pageWidthEqualToWebView;

/**
 获取html内容
 */
- (NSString *)getHTMLString;

@end
