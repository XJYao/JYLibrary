//
//  XWebView.m
//  JYLibrary
//
//  Created by XJY on 15/12/15.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XWebView.h"

@interface XWebView () <UIAlertViewDelegate> {
    BOOL state;
}

@end

@implementation XWebView

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:message message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [confirmDiag show];
    
    while (confirmDiag.isVisible) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    
    return state;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        state = NO;
    } else if (buttonIndex == 1) {
        state = YES;
    }
    
}

@end
