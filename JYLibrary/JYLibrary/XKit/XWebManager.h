//
//  XWebManager.h
//  XWebManager
//
//  Created by XJY on 16/7/6.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XWebManager;

@protocol XWebManagerDelegate <NSObject>

@optional
/*! @abstract 是否允许加载指定URL
 */
- (BOOL)webManager:(XWebManager *)manager allowLoadURL:(NSURL *)URL;

/*! @abstract 是否允许在收到响应后跳转
 */
- (BOOL)webManager:(XWebManager *)manager allowNavigateAfterResponse:(NSURL *)URL NS_AVAILABLE(10_10, 8_0);

/*! @abstract 接收到服务器跳转请求
 */
- (BOOL)webManagerDidReceiveServerRedirectForProvisionalNavigation:(XWebManager *)manager NS_AVAILABLE(10_10, 8_0);

/*! @abstract 开始加载
 */
- (void)webManagerDidStartLoad:(XWebManager *)manager;

/*! @abstract 结束加载
 */
- (void)webManagerDidFinishLoad:(XWebManager *)manager;

/*! @abstract 在开始加载时发生错误
 */
- (void)webManager:(XWebManager *)manager didFailLoadWithError:(NSError *)error;

/*! @abstract 内容加载失败
 */
- (void)webManager:(XWebManager *)manager didFailLoadContentWithError:(NSError *)error NS_AVAILABLE(10_10, 8_0);

/*! @abstract 加载进度
 */
- (void)webManager:(XWebManager *)manager loadProgress:(double)progress;

/*! @abstract 当前加载页面的标题
 */
- (void)webManager:(XWebManager *)manager title:(NSString *)title;

/*! @abstract 身份认证
 */
- (void)webManager:(XWebManager *)manager didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential))completionHandler NS_AVAILABLE(10_10, 8_0);

/*! @abstract 打开新窗口
 */
- (void)webManager:(XWebManager *)manager newManager:(XWebManager *)newManager URL:(NSURL *)URL NS_AVAILABLE(10_10, 8_0);

/*! @abstract 获取到页面内容
 */
- (void)webManagerContentStartsArriving:(XWebManager *)manager NS_AVAILABLE(10_10, 8_0);

/*! @abstract 关闭窗口
 */
- (void)webManagerDidClose:(XWebManager *)manager NS_AVAILABLE(10_11, 9_0);

/*! @abstract 加载进程终止
 */
- (void)webManagerWebContentProcessDidTerminate:(XWebManager *)manager NS_AVAILABLE(10_11, 9_0);

/*! @abstract 捕捉到JavaScript执行alert
 */
- (void)webManager:(XWebManager *)manager alertWithMessage:(NSString *)message;

/*! @abstract 捕捉到JavaScript执行confirm
 */
- (void)webManager:(XWebManager *)manager confirmWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler;

/*! @abstract 捕捉到JavaScript执行prompt
 */
- (void)webManager:(XWebManager *)manager textInputWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText completionHandler:(void (^)(NSString * result))completionHandler;

/*! @abstract 捕捉到JavaScript调oc的消息
 */
- (void)webManager:(XWebManager *)manager didReceiveScriptMessage:(id)message handlerName:(NSString *)name NS_AVAILABLE(10_10, 8_0);

@end

@interface XWebManager : NSObject

@property (nonatomic, weak) id <XWebManagerDelegate> delegate;

@property (nonatomic, readonly, strong) UIView *webView;
@property (nonatomic, readonly, strong) UIScrollView *scrollView;

/*! @abstract 是否可以返回
 */
@property (nonatomic, readonly, getter=canGoBack)       BOOL canGoBack;

/*! @abstract 是否可以前进
 */
@property (nonatomic, readonly, getter=canGoForward)    BOOL canGoForward;

/*! @abstract 是否正在加载
 */
@property (nonatomic, readonly, getter=isLoading)       BOOL loading;

/*! @abstract 当前加载页面的标题
 */
@property (nonatomic, readonly, copy) NSString *title;

/*! @abstract 当前加载的URL
 */
@property (nonatomic, readonly, copy) NSURL *URL;

/*! @abstract 初始化时传入frame
 */
- (instancetype)initWithFrame:(CGRect)frame;

/*! @abstract 初始化时强制使用UIWebView，默认为NO。
 */
- (instancetype)initWithUseUIWebView:(BOOL)useUIWebView;
- (instancetype)initWithFrame:(CGRect)frame useUIWebView:(BOOL)useUIWebView;

/*! @abstract 加载
 */
- (void)loadRequest:(NSURLRequest *)request;

/*! @abstract 重新加载
 */
- (void)reload;

/*! @abstract 停止加载
 */
- (void)stopLoading;

/*! @abstract 返回
 */
- (void)goBack;

/*! @abstract 前进
 */
- (void)goForward;

/*! @abstract 执行JS
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError * error))completionHandler;

/*! @abstract 清空缓存
 */
- (void)clearWebCaches;
- (void)clearCaches;
+ (void)clearWebCaches;
+ (void)clearCaches;

/*! @abstract 清空Cookie
 */
- (void)clearCookies;
+ (void)clearCookies;

/*! @abstract 添加js调oc方法的桥梁名。
 */
- (void)addScriptMessageHandlerWithName:(NSString *)name; NS_AVAILABLE(10_10, 8_0);

@end

NS_ASSUME_NONNULL_END
