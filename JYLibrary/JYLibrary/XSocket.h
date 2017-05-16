//
//  XSocket.h
//  JYLibrary
//
//  Created by XJY on 15/10/17.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XSocketResultType) {
    XSocketResultTypeNoneInit = 0,        //未初始化
    XSocketResultTypeSuccess,             //成功
    XSocketResultTypeFailed,              //创建失败
    XSocketResultTypeConnectServerFailed, //连接服务器失败
    XSocketResultTypeNoHost               //服务器地址为空
};


@interface XSocket : NSObject

@property (nonatomic, assign) int socket;

#pragma mark - Server

/**
 开启服务端socket监听
 */
- (BOOL)serverTcpSocketListen:(int)port backlog:(int)backlog;

/**
 服务端socket接收客户端接入
 */
- (void)serverTcpSocketAccept:(void (^)(int socket, BOOL acceptSuccess))socketBlock;

#pragma mark - Client

/**
 客户端socket连接超时时间
 默认20, -1:无超时设置
 */
@property (nonatomic, assign) long timeout;

/**
 socket创建状态
 */
@property (nonatomic, assign) XSocketResultType type;

/**
 创建客户端socket
 */
- (void)clientTcpSocket:(NSString *)hostAddress port:(int)port;

#pragma mark - public

/**
 关闭socket，-1失败，0成功
 */
+ (int)tcpSocketClose:(int)socket;

- (int)tcpSocketClose:(int)socket;

- (int)tcpSocketClose;

/**
 socket读取数据
 */
- (NSData *)tcpSocketRead:(int)socket;

- (NSData *)tcpSocketRead;

- (NSData *)tcpSocketReadHead:(int)socket;

- (NSData *)tcpSocketReadHead;

- (NSData *)tcpSocketReadBodyWithSocket:(int)socket
                               headData:(NSData *)headData
                              readBegin:(void (^)(void))beginBlock
                           readProgress:(void (^)(NSData *currentReadData, NSData *readedData, NSInteger totalLength))progressBlock
                         readCompletion:(void (^)(NSData *completionReadData))completionBlock;

- (NSData *)tcpSocketReadBodyWithHeadData:(NSData *)headData
                                readBegin:(void (^)(void))beginBlock
                             readProgress:(void (^)(NSData *currentReadData, NSData *readedData, NSInteger totalLength))progressBlock
                           readCompletion:(void (^)(NSData *completionReadData))completionBlock;

- (NSData *)tcpSocketReadBodyWithSocket:(int)socket headData:(NSData *)headData;

- (NSData *)tcpSocketReadBodyWithHeadData:(NSData *)headData;

- (NSData *)tcpSocketReadDataWithHead:(NSData *)headData body:(NSData *)bodyData;

/**
 socket发送数据
 */
+ (void)tcpSocketWrite:(int)socket withData:(NSData *)data;

- (void)tcpSocketWrite:(int)socket withData:(NSData *)data;

- (void)tcpSocketWrite:(NSData *)data;

@end
