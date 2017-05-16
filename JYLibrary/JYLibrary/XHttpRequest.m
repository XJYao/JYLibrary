//
//  XHttpRequest.m
//  JYLibrary
//
//  Created by XJY on 15/7/27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XHttpRequest.h"
#import "XTool.h"
#import "XThread.h"
#import "XIOSVersion.h"
#import "XJsonParser.h"


@implementation XHttpResult

@end


@interface XHttpRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
{
    NSString *requestUrlString;

    NSURLResponse *urlResponse;
    NSMutableData *responseData;
    NSError *requestError;

    XHttpRequestFinishedBlock finishedBlock;
    XHttpRequestProgressBlock progressBlock;

    //before ios7
    NSURLConnection *urlConnection;

    //ios7 or later
    NSURLSessionTask *urlSessionTask;
}

@end


@implementation XHttpRequest

#pragma mark - GET

- (void)GETHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURLString:URLString method:@"GET" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (void)GETHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:@"GET" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)GETHttpSyncRequestWithURLString:(NSString *)URLString {
    return [self httpSyncRequestWithURLString:URLString method:@"GET" parameters:nil];
}

- (XHttpResult *)GETHttpSyncRequestWithURL:(NSURL *)URL {
    return [self httpSyncRequestWithURL:URL method:@"GET" parameters:nil];
}

#pragma mark - POST

- (void)POSTHttpRequestWithURLString:(NSString *)URLString parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURLString:URLString method:@"POST" parameters:parameters progressBlock:progress finshedBlock:finished];
}

- (void)POSTHttpRequestWithURL:(NSURL *)URL parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:@"POST" parameters:parameters progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)POSTHttpSyncRequestWithURLString:(NSString *)URLString parameters:(id)parameters {
    return [self httpSyncRequestWithURLString:URLString method:@"POST" parameters:parameters];
}

- (XHttpResult *)POSTHttpSyncRequestWithURL:(NSURL *)URL parameters:(id)parameters {
    return [self httpSyncRequestWithURL:URL method:@"POST" parameters:parameters];
}

#pragma mark - PUT

- (void)PUTHttpRequestWithURLString:(NSString *)URLString parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURLString:URLString method:@"PUT" parameters:parameters progressBlock:progress finshedBlock:finished];
}

- (void)PUTHttpRequestWithURL:(NSURL *)URL parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:@"PUT" parameters:parameters progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)PUTHttpSyncRequestWithURLString:(NSString *)URLString parameters:(id)parameters {
    return [self httpSyncRequestWithURLString:URLString method:@"PUT" parameters:parameters];
}

- (XHttpResult *)PUTHttpSyncRequestWithURL:(NSURL *)URL parameters:(id)parameters {
    return [self httpSyncRequestWithURL:URL method:@"PUT" parameters:parameters];
}

#pragma mark - DELETE

- (void)DELETEHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURLString:URLString method:@"DELETE" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (void)DELETEHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:@"DELETE" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)DELETEHttpSyncRequestWithURLString:(NSString *)URLString {
    return [self httpSyncRequestWithURLString:URLString method:@"DELETE" parameters:nil];
}

- (XHttpResult *)DELETEHttpSyncRequestWithURL:(NSURL *)URL {
    return [self httpSyncRequestWithURL:URL method:@"DELETE" parameters:nil];
}

#pragma mark - HEAD

- (void)HEADHttpRequestWithURLString:(NSString *)URLString progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURLString:URLString method:@"HEAD" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (void)HEADHttpRequestWithURL:(NSURL *)URL progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:@"HEAD" parameters:nil progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)HEADHttpSyncRequestWithURLString:(NSString *)URLString {
    return [self httpSyncRequestWithURLString:URLString method:@"HEAD" parameters:nil];
}

- (XHttpResult *)HEADHttpSyncRequestWithURL:(NSURL *)URL {
    return [self httpSyncRequestWithURL:URL method:@"HEAD" parameters:nil];
}

#pragma mark - HTTP

- (void)httpRequestWithURLString:(NSString *)URLString method:(NSString *)method parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:[NSURL URLWithString:URLString] method:method parameters:parameters progressBlock:progress finshedBlock:finished];
}

- (void)httpRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self httpRequestWithURL:URL method:method parameters:parameters async:YES progressBlock:progress finshedBlock:finished];
}

- (XHttpResult *)httpSyncRequestWithURLString:(NSString *)URLString method:(NSString *)method parameters:(id)parameters {
    return [self httpSyncRequestWithURL:[NSURL URLWithString:URLString] method:method parameters:parameters];
}

- (XHttpResult *)httpSyncRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters {
    return [self httpRequestWithURL:URL method:method parameters:parameters async:NO progressBlock:nil finshedBlock:nil];
}

- (XHttpResult *)httpRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters async:(BOOL)async progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    [self clear];

    NSURLRequest *request = [self requestWithURL:URL method:method parameters:parameters progressBlock:progress finshedBlock:finished];

    if (!_useNSURLConnection && [XIOSVersion isIOS7OrGreater]) {
        //ios7 or later

        if (async) {
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];

            urlSessionTask = [urlSession dataTaskWithRequest:request];
            [urlSessionTask resume];
        } else {
            //创建一个信号量，值为0
            [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {

                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

                __weak __typeof(self) weak_self = self;

                NSURLSessionTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {

                    responseData = [[NSMutableData alloc] initWithData:data];
                    urlResponse = response;
                    requestError = error;

                    [weak_self dealRequestResult];

                    //释放信号
                    sendSignal();
                }];

                [task resume];

                //等待可用信号
                waitSignal();
            }];
        }

    } else {
        //before ios7
        if (async) {
            urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            [urlConnection setDelegateQueue:[[NSOperationQueue alloc] init]];
            [urlConnection start];

        } else {
            NSURLResponse *response = nil;
            NSError *error = nil;

            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

            responseData = [[NSMutableData alloc] initWithData:data];
            urlResponse = response;
            requestError = error;

            [self dealRequestResult];
        }
    }

    if (async) {
        return nil;
    } else {
        XHttpResult *httpResult = [[XHttpResult alloc] init];
        [httpResult setData:responseData];
        [httpResult setResponse:(NSHTTPURLResponse *)urlResponse];
        [httpResult setError:requestError];

        return httpResult;
    }
}

- (void)cancel {
    if (urlConnection) {
        [urlConnection cancel];
        urlConnection = nil;
    }

    if (urlSessionTask) {
        [urlSessionTask cancel];
        urlSessionTask = nil;
    }
}

#pragma mark - property

- (long long)totalCount {
    long long count = NSNotFound;

    if (!urlResponse) {
        return count;
    }

    NSString *key = @"Content-Length";

    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)urlResponse;
    NSDictionary *allHeaderFields = httpUrlResponse.allHeaderFields;

    if ([XTool isDictionaryEmpty:allHeaderFields] || ![allHeaderFields.allKeys containsObject:key]) {
        count = urlResponse.expectedContentLength;
    } else {
        count = [[allHeaderFields objectForKey:key] longLongValue];
    }

    return count;
}

#pragma mark---------- Private ----------

- (instancetype)init {
    self = [super init];
    if (self) {
        [self clear];

        _requestStringEncoding = NSUTF8StringEncoding;
        _responseStringEncoding = NSUTF8StringEncoding;
        _timeout = 60;
        _activityIndicatorEnable = YES;
        _finishedOnMainThread = NO;
        _requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        _useNSURLConnection = NO;
        _HTTPRequestHeaders = [[NSMutableDictionary alloc] init];

        finishedBlock = nil;
    }
    return self;
}

- (void)clear {
    [self cancel];
    requestUrlString = @"";
    urlResponse = nil;
    responseData = nil;
    requestError = nil;
}

- (NSURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method parameters:(id)parameters progressBlock:(XHttpRequestProgressBlock)progress finshedBlock:(XHttpRequestFinishedBlock)finished {
    requestUrlString = URL.absoluteString;
    finishedBlock = finished;
    progressBlock = progress;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:_requestCachePolicy timeoutInterval:_timeout];

    [request setHTTPMethod:method];

    if (![XTool isDictionaryEmpty:_HTTPRequestHeaders]) {
        for (NSString *key in _HTTPRequestHeaders.allKeys) {
            NSString *value = [_HTTPRequestHeaders objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }

    if (parameters) {
        if ([parameters isKindOfClass:[NSData class]]) {
            [request setHTTPBody:parameters];
        } else if ([parameters isKindOfClass:[NSString class]]) {
            [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            if (![request valueForHTTPHeaderField:@"Content-Type"]) {
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }

            NSError *error;
            [request setHTTPBody:[XJsonParser jsonDataWithObject:parameters error:&error]];
        }
    } else {
        [request setHTTPBody:nil];
    }

    if (_activityIndicatorEnable) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }

    return request;
}

- (void)receiveData:(NSData *)data {
    //add data
    if (!responseData) {
        responseData = [[NSMutableData alloc] init];
    }
    [responseData appendData:data];

    //progress
    [self executeProgressBlock];
}

- (void)dealRequestResult {
    if (_activityIndicatorEnable) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }

    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)urlResponse;

    NSStringEncoding stringEncoding = [XTool getEncodingFromResponse:httpUrlResponse];

    if (stringEncoding != NSNotFound) {
        _responseStringEncoding = stringEncoding;
    }

    [self executeFinishedBlock];
}

- (void)executeProgressBlock {
    [self executeProgressBlock:responseData.length totalCount:self.totalCount];
}

- (void)executeProgressBlock:(long long)completedCount totalCount:(long long)totalCount {
    if (progressBlock) {
        if (_finishedOnMainThread) {
            x_dispatch_main_async(^{
                progressBlock(completedCount, totalCount);
            });
        } else {
            progressBlock(completedCount, totalCount);
        }
    }
}

- (void)executeFinishedBlock {
    if (finishedBlock) {
        NSString *responseString = nil;

        if (responseData) {
            responseString = [[NSString alloc] initWithData:responseData encoding:_responseStringEncoding];
        }

        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)urlResponse;

        if (_finishedOnMainThread) {
            x_dispatch_main_async(^{
                finishedBlock(responseData, responseString, httpUrlResponse.statusCode, requestError);
            });
        } else {
            finishedBlock(responseData, responseString, httpUrlResponse.statusCode, requestError);
        }
    }
}

- (NSString *)url {
    return requestUrlString;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    responseData = nil;
    requestError = error;
    [self dealRequestResult];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self receiveData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    [self executeProgressBlock:totalBytesWritten totalCount:totalBytesExpectedToWrite];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self dealRequestResult];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [self executeProgressBlock:totalBytesSent totalCount:totalBytesExpectedToSend];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    requestError = error;
    if (error) {
        responseData = nil;
    }
    [self dealRequestResult];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    urlResponse = dataTask.response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self receiveData:data];
}

@end
