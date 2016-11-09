//
//  XHttpRequest.h
//  JYLibrary
//
//  Created by XJY on 15/7/27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

//同步请求的返回结果
@interface XHttpResult : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSError *error;

@end

@interface XHttpRequest : NSObject

typedef NS_ENUM(NSInteger, XHttpStatusCode) {
    XHttpStatusCodeOK                   = 200,
    XHttpStatusCodeBadRequest           = 400,
    XHttpStatusCodeNotFound             = 404,
    XHttpStatusCodeConflict             = 409,
    XHttpStatusCodeInternalServerError  = 500
};

typedef void (^XHttpRequestProgressBlock)(long long completedCount, long long totalCount);
typedef void (^XHttpRequestFinishedBlock)(id responseObject, NSString *responseString, NSInteger statusCode, NSError *error);

@property (nonatomic, copy, readonly)   NSString *  url;
@property (nonatomic, assign, readonly) long long totalCount;

@property (nonatomic, assign)           NSStringEncoding    requestStringEncoding;  //default is UTF-8
@property (nonatomic, assign)           NSStringEncoding    responseStringEncoding; //default is UTF-8
@property (nonatomic, assign)           NSTimeInterval      timeout;                //default is 60
@property (nonatomic, assign)           BOOL                activityIndicatorEnable;//default is YES
@property (nonatomic, assign)           BOOL                finishedOnMainThread;   //default is NO
@property (nonatomic, assign)           NSURLRequestCachePolicy requestCachePolicy; //default is NSURLRequestUseProtocolCachePolicy
@property (nonatomic, assign)           BOOL                useNSURLConnection;     //default is NO
@property (nonatomic, strong)           NSMutableDictionary<NSString *, NSString *> *HTTPRequestHeaders;

#pragma mark - GET

- (void)GETHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)GETHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)GETHttpSyncRequestWithURLString:(NSString *)URLString;

- (XHttpResult *)GETHttpSyncRequestWithURL:(NSURL *)URL;

#pragma mark - POST

- (void)POSTHttpRequestWithURLString:(NSString *)URLString parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)POSTHttpRequestWithURL:(NSURL *)URL parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)POSTHttpSyncRequestWithURLString:(NSString *)URLString parameters:(id)parameters;

- (XHttpResult *)POSTHttpSyncRequestWithURL:(NSURL *)URL parameters:(id)parameters;

#pragma mark - PUT

- (void)PUTHttpRequestWithURLString:(NSString *)URLString parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)PUTHttpRequestWithURL:(NSURL *)URL parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)PUTHttpSyncRequestWithURLString:(NSString *)URLString parameters:(id)parameters;

- (XHttpResult *)PUTHttpSyncRequestWithURL:(NSURL *)URL parameters:(id)parameters;

#pragma mark - DELETE

- (void)DELETEHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)DELETEHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)DELETEHttpSyncRequestWithURLString:(NSString *)URLString;

- (XHttpResult *)DELETEHttpSyncRequestWithURL:(NSURL *)URL;

#pragma mark - HEAD

- (void)HEADHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)HEADHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)HEADHttpSyncRequestWithURLString:(NSString *)URLString;

- (XHttpResult *)HEADHttpSyncRequestWithURL:(NSURL *)URL;

#pragma mark - HTTP

- (void)httpRequestWithURLString:(NSString *)URLString method:(NSString *)method parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)httpRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (XHttpResult *)httpSyncRequestWithURLString:(NSString *)URLString method:(NSString *)method parameters:(id)parameters;

- (XHttpResult *)httpSyncRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters;

- (XHttpResult *)httpRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters async:(BOOL)async progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished;

- (void)cancel;

@end
