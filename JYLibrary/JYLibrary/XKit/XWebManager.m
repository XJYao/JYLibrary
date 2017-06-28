//
//  XWebManager.m
//  XWebManager
//
//  Created by XJY on 16/7/6.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XWebManager.h"
#import <WebKit/WebKit.h>
#import <pthread/pthread.h>
#import "XIOSVersion.h"
#import "XFileManager.h"

#pragma mark - custom UIWebView

@protocol XCustomUIWebViewDelegate <UIWebViewDelegate>

- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(NSString *)message;
- (void)webView:(id)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message completionHandler:(void (^)(BOOL))completionHandler;
- (void)webView:(id)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText completionHandler:(void (^)(NSString *))completionHandler;

@end


@interface XCustomUIWebView : UIWebView

@property (nonatomic, weak) id<XCustomUIWebViewDelegate> custom_delegate;

@end


@implementation XCustomUIWebView

- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    if (self.custom_delegate && [self.custom_delegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:)]) {
        [self.custom_delegate webView:webView runJavaScriptAlertPanelWithMessage:message];
    }
}

- (BOOL)webView:(id)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    __block BOOL waitResult = YES;
    __block BOOL confirmResult = NO;

    if (self.custom_delegate && [self.custom_delegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:completionHandler:)]) {
        [self.custom_delegate webView:webView runJavaScriptConfirmPanelWithMessage:message completionHandler:^(BOOL result) {
            confirmResult = result;
            waitResult = NO;
        }];
    } else {
        waitResult = NO;
    }

    while (waitResult) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }

    return confirmResult;
}

- (NSString *)webView:(id)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame {
    __block BOOL waitResult = YES;
    __block NSString *resultString = nil;

    if (self.custom_delegate && [self.custom_delegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:completionHandler:)]) {
        [self.custom_delegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText completionHandler:^(NSString *result) {
            resultString = result;
            waitResult = NO;
        }];
    } else {
        waitResult = NO;
    }

    while (waitResult) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }

    return resultString;
}

@end


#pragma mark - XWebManager


@interface XWebManager () <UIWebViewDelegate, XCustomUIWebViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    //before iOS8
    CADisplayLink *disPlayLink;     //用于iOS8以下进度累加
    double progressForIOS7OrBefore; //iOS8以下加载进度

    BOOL useUIWebView;
}

@end


@implementation XWebManager

#pragma mark - public

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame configuration:nil useUIWebView:NO];
}

- (instancetype)initWithUseUIWebView:(BOOL)use {
    return [self initWithFrame:CGRectZero configuration:nil useUIWebView:use];
}

- (instancetype)initWithFrame:(CGRect)frame useUIWebView:(BOOL)use {
    return [self initWithFrame:frame configuration:nil useUIWebView:use];
}

- (void)loadRequest:(NSURLRequest *)request {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView loadRequest:request];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        [webView loadRequest:request];
    }
}

- (void)reload {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView reload];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        [webView reload];
    }
}

- (void)stopLoading {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView stopLoading];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        [webView stopLoading];
    }
}

- (void)goBack {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView goBack];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        [webView goBack];
    }
}

- (void)goForward {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView goForward];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        [webView goForward];
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView evaluateJavaScript:javaScriptString completionHandler:^(id result, NSError *error) {
            if (pthread_main_np() == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(result, error);
                });
            } else {
                completionHandler(result, error);
            }
        }];
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        NSString *result = [webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    }
}

- (void)clearWebCaches {
    [XWebManager clearWebCaches];
}

- (void)clearCookies {
    [XWebManager clearCookies];
}

- (void)clearCaches {
    [XWebManager clearCaches];
}

+ (void)clearWebCaches {
    if ([XIOSVersion isIOS9OrGreater]) {
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[NSSet setWithObjects:
                                                                            WKWebsiteDataTypeDiskCache,
                                                                            WKWebsiteDataTypeMemoryCache,
                                                                            WKWebsiteDataTypeOfflineWebApplicationCache,
                                                                            WKWebsiteDataTypeSessionStorage,
                                                                            WKWebsiteDataTypeLocalStorage,
                                                                            WKWebsiteDataTypeWebSQLDatabases,
                                                                            WKWebsiteDataTypeIndexedDBDatabases,
                                                                            nil]
                                                   modifiedSince:dateFrom
                                               completionHandler:^{
                                               }];
    }

    NSString *libraryDirectory = [XFileManager getLibraryDirectory];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit", libraryDirectory];
    NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit", libraryDirectory, bundleId];

    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:&error];
    error = nil;
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData", libraryDirectory, bundleId];
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];

    NSString *cachesPath = [NSString stringWithFormat:@"%@/Caches", libraryDirectory];
    NSArray *files = [XFileManager getAllFiles:cachesPath];
    for (NSString *file in files) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", cachesPath, file];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:NULL];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
}

+ (void)clearCookies {
    if ([XIOSVersion isIOS9OrGreater]) {
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[NSSet setWithObjects:
                                                                            WKWebsiteDataTypeCookies,
                                                                            nil]
                                                   modifiedSince:dateFrom
                                               completionHandler:^{
                                               }];
    }

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }

    NSString *libraryDirectory = [XFileManager getLibraryDirectory];
    NSString *cookiesFolderPath = [libraryDirectory stringByAppendingString:@"/Cookies"];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
}

+ (void)clearCaches {
    [self clearWebCaches];
    [self clearCookies];
}

- (void)addScriptMessageHandlerWithName:(NSString *)name {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        [webView.configuration.userContentController addScriptMessageHandler:self name:name];
    }
}

#pragma mark - property

- (UIScrollView *)scrollView {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.scrollView;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return webView.scrollView;
    }
}

- (BOOL)canGoBack {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.canGoBack;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return webView.canGoBack;
    }
}

- (BOOL)canGoForward {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.canGoForward;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return webView.canGoForward;
    }
}

- (BOOL)isLoading {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.isLoading;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return webView.isLoading;
    }
}

- (NSString *)title {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.title;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

- (NSURL *)URL {
    if ([self isUseWKWebView]) {
        WKWebView *webView = (WKWebView *)_webView;
        return webView.URL;
    } else {
        UIWebView *webView = (UIWebView *)_webView;
        return webView.request.URL;
    }
}

#pragma mark - private

- (BOOL)isUseWKWebView {
    return (!useUIWebView && [XIOSVersion isIOS8OrGreater]);
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration useUIWebView:(BOOL)use {
    self = [super init];

    if (self) {
        progressForIOS7OrBefore = 0;
        useUIWebView = use;

        if ([self isUseWKWebView]) {
            _webView = [self createWKWebView:frame configuration:configuration];

            [self registerKVOForWKWebView];

        } else {
            _webView = [self createUIWebView:frame];
        }
    }

    return self;
}

- (void)dealloc {
    if ([self isUseWKWebView]) {
        [self removeKVOForWKWebView];
    } else {
        [disPlayLink invalidate];
        disPlayLink = nil;
    }
}

- (UIView *)createUIWebView:(CGRect)frame {
    XCustomUIWebView *webView = [[XCustomUIWebView alloc] initWithFrame:frame];
    [webView setDelegate:self];
    [webView setCustom_delegate:self];
    [webView setScalesPageToFit:YES];

    return webView;
}

- (UIView *)createWKWebView:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebView *webView = nil;
    if (configuration) {
        webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    } else {
        webView = [[WKWebView alloc] initWithFrame:frame];
    }
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];

    return webView;
}

//iOS8及以上KVO监听WKWebView的属性
- (void)registerKVOForWKWebView {
    NSArray *keyPaths = @[ @"estimatedProgress", @"title" ];

    for (NSString *path in keyPaths) {
        [((WKWebView *)_webView) addObserver:self forKeyPath:path options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeKVOForWKWebView {
    NSArray *keyPaths = @[ @"estimatedProgress", @"title" ];

    for (NSString *path in keyPaths) {
        [((WKWebView *)_webView) removeObserver:self forKeyPath:path];
    }
}

- (void)updateProgress:(double)progress {
    if (_delegate && [_delegate respondsToSelector:@selector(webManager:loadProgress:)]) {
        [_delegate webManager:self loadProgress:progress];
    }
}

- (void)beginGettingProgressForIOS7OrBefore {
    progressForIOS7OrBefore = 0;
    [self updateProgress:progressForIOS7OrBefore];

    if (disPlayLink) {
        [disPlayLink setPaused:NO];
        return;
    }
    disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(ios7OrBeforeDisPlayLinkForGettingProgress)];
    [disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopGettingProgressForIOS7OrBefore {
    [disPlayLink setPaused:YES];

    progressForIOS7OrBefore = 1;
    [self updateProgress:progressForIOS7OrBefore];
}

- (void)ios7OrBeforeDisPlayLinkForGettingProgress {
    if (progressForIOS7OrBefore >= 0.8) {
        return;
    }

    progressForIOS7OrBefore += 0.005;
    [self updateProgress:progressForIOS7OrBefore];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    BOOL allow = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(webManager:allowLoadURL:)]) {
        allow = [_delegate webManager:self allowLoadURL:request.URL];
    }
    return allow;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidStartLoad:)]) {
        [_delegate webManagerDidStartLoad:self];
    }

    [self beginGettingProgressForIOS7OrBefore];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidFinishLoad:)]) {
        [_delegate webManagerDidFinishLoad:self];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:title:)]) {
        [_delegate webManager:self title:self.title];
    }

    [self stopGettingProgressForIOS7OrBefore];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:didFailLoadWithError:)]) {
        [_delegate webManager:self didFailLoadWithError:error];
    }

    [self stopGettingProgressForIOS7OrBefore];
}

#pragma mark - XCustomUIWebViewDelegate

- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(NSString *)message {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:alertWithMessage:)]) {
        [_delegate webManager:self alertWithMessage:message];
    }
}

- (void)webView:(id)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:confirmWithMessage:completionHandler:)]) {
        [_delegate webManager:self confirmWithMessage:message completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NO);
        }
    }
}

- (void)webView:(id)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText completionHandler:(void (^)(NSString *))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:textInputWithPrompt:defaultText:completionHandler:)]) {
        [_delegate webManager:self textInputWithPrompt:prompt defaultText:defaultText completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    BOOL allow = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(webManager:allowLoadURL:)]) {
        allow = [_delegate webManager:self allowLoadURL:navigationAction.request.URL];
    }

    if (decisionHandler) {
        decisionHandler(allow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    BOOL allow = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(webManager:allowNavigateAfterResponse:)]) {
        allow = [_delegate webManager:self allowNavigateAfterResponse:navigationResponse.response.URL];
    }

    if (decisionHandler) {
        decisionHandler(allow ? WKNavigationResponsePolicyAllow : WKNavigationResponsePolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidStartLoad:)]) {
        [_delegate webManagerDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidReceiveServerRedirectForProvisionalNavigation:)]) {
        [_delegate webManagerDidReceiveServerRedirectForProvisionalNavigation:self];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:didFailLoadWithError:)]) {
        [_delegate webManager:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerContentStartsArriving:)]) {
        [_delegate webManagerContentStartsArriving:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidFinishLoad:)]) {
        [_delegate webManagerDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:didFailLoadContentWithError:)]) {
        [_delegate webManager:self didFailLoadContentWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (completionHandler) {
        if (_delegate && [_delegate respondsToSelector:@selector(webManager:didReceiveAuthenticationChallenge:completionHandler:)]) {
            [_delegate webManager:self didReceiveAuthenticationChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition userDisposition, NSURLCredential *_Nonnull userCredential) {

                if (userCredential) {
                    completionHandler(userDisposition, userCredential);
                } else {
                    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
                    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                }
            }];
        } else {
            NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView { //ios9

    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerWebContentProcessDidTerminate:)]) {
        [_delegate webManagerWebContentProcessDidTerminate:self];
    }
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    XWebManager *newManager = [[XWebManager alloc] initWithFrame:_webView.frame configuration:configuration useUIWebView:useUIWebView];

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:newManager:URL:)]) {
        [_delegate webManager:self newManager:newManager URL:navigationAction.request.URL];
    }

    return (WKWebView *)(newManager.webView);
}

- (void)webViewDidClose:(WKWebView *)webView { //ios9

    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManagerDidClose:)]) {
        [_delegate webManagerDidClose:self];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:alertWithMessage:)]) {
        [_delegate webManager:self alertWithMessage:message];
    }

    if (completionHandler) {
        completionHandler();
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:confirmWithMessage:completionHandler:)]) {
        [_delegate webManager:self confirmWithMessage:message completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NO);
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:textInputWithPrompt:defaultText:completionHandler:)]) {
        [_delegate webManager:self textInputWithPrompt:prompt defaultText:defaultText completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_delegate && [_delegate respondsToSelector:@selector(webManager:didReceiveScriptMessage:handlerName:)]) {
        [_delegate webManager:self didReceiveScriptMessage:message.body handlerName:message.name];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        double newProgress = [[change objectForKey:@"new"] doubleValue];
        [self updateProgress:newProgress];
    } else if ([keyPath isEqualToString:@"title"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(webManager:title:)]) {
            [_delegate webManager:self title:[change objectForKey:@"new"]];
        }
    }
}

@end
