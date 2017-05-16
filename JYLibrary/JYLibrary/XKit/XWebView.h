//
//  XWebView.h
//  JYLibrary
//
//  Created by XJY on 15/12/15.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XWebView : UIWebView

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

@end
