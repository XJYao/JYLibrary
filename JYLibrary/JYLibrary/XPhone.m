//
//  XPhone.m
//  JYLibrary
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XPhone.h"
#import "XTool.h"
#import "XEncoding.h"
#import "XIOSVersion.h"

@implementation XPhone

+ (NSURL *)getTelUrl:(NSString *)phoneNumber {
    NSString *cleanedString =[[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [XEncoding encodeString:cleanedString encoding:NSUTF8StringEncoding];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    return telURL;
}

+ (NSURL *)getSmsUrl:(NSString *)phoneNumber {
    NSString *cleanedString =[[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [XEncoding encodeString:cleanedString encoding:NSUTF8StringEncoding];
    NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", escapedPhoneNumber]];
    return smsURL;
}

+ (void)callTelephone:(NSString *)phoneNumber atSuper:(UIView *)superView {
    UIWebView *callWebview = [[UIWebView alloc] init] ;
    [superView addSubview:callWebview];
    NSURL *telURL = [self getTelUrl:phoneNumber];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
}

+ (BOOL)callTelephone:(NSString *)phoneNumber {
    NSURL *telURL = [self getTelUrl:phoneNumber];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:telURL];
    if (canOpen) {
        [self openURL:telURL];
    }
    return canOpen;
}

+ (BOOL)sendSms:(NSString *)phoneNumber {
    NSURL *smsURL = [self getSmsUrl:phoneNumber];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:smsURL];
    if (canOpen) {
        [self openURL:smsURL];
    }
    return canOpen;
}

+ (BOOL)openEmail:(NSString *)email {
    NSString *emailStr = @"mailto://";
    emailStr = [emailStr stringByAppendingString:email];
    NSURL *emailURL = [NSURL URLWithString:emailStr];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:emailURL];
    if (canOpen) {
        [self openURL:emailURL];
    }
    return canOpen;
}

+ (BOOL)openBrowserWithString:(NSString *)urlStr {
    if ([XTool isStringEmpty:urlStr]) {
        return NO;
    }
    return [self openBrowserWithUrl:[NSURL URLWithString:urlStr]];
}

+ (BOOL)openBrowserWithUrl:(NSURL *)url {
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    if (canOpen) {
        [self openURL:url];
    }
    return canOpen;
}

+ (void)openURLWithString:(NSString *)url {
    if ([XTool isStringEmpty:url]) {
        return;
    }
    [self openURL:[NSURL URLWithString:url]];
}

+ (void)openURL:(NSURL *)url {
    if ([XIOSVersion isIOS10OrGreater]) {
        [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
            
        }];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (BOOL)jumpToContactsService {
    NSURL *URL = [NSURL URLWithString:@"prefs:root=CONTACTS_SERVICE"];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
    if (canOpen) {
        [self openURL:URL];
    }
    return canOpen;
}

@end
