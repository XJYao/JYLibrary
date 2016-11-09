//
//  UIWebView+XWebView.m
//  JYLibrary
//
//  Created by XJY on 16/1/18.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIWebView+XWebView.h"

@implementation UIWebView (XWebView)

//修改网页的宽度与webView宽度一致
- (void)pageWidthEqualToWebView {
    if (!self) {
        return;
    }
    
    NSString *viewportJS = [NSString stringWithFormat:@"var viewportMeta = document.getElementsByName('viewport')[0];if(viewportMeta){viewportMeta.content='width=%f,minimum-scale=1,initial-scale=1.0';}",self.frame.size.width];
    [self stringByEvaluatingJavaScriptFromString:viewportJS];
}

/**
 获取html内容
 */
- (NSString *)getHTMLString {
    return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

@end
