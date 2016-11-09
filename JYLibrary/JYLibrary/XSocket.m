//
//  XSocket.m
//  JYLibrary
//
//  Created by XJY on 15/10/17.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/ioctl.h>
#import <arpa/inet.h>
#import "XTool.h"

@interface XSocket () {
    NSData *readedBody;
}

@end

@implementation XSocket

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _socket = -1;
        _type = XSocketResultTypeNoneInit;
        _timeout = 20;//该超时时间必须有值, 因为经过select()方法才成功连接，不知道为什么。
    }
    
    return self;
}

#pragma mark - Server

//服务端socket监听
- (BOOL)serverTcpSocketListen:(int)port backlog:(int)backlog {
    
    _socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    BOOL socketSuccess = (_socket != -1);
    
    if (!socketSuccess) {
        return socketSuccess;
    }
    
    struct sockaddr_in serverSocketAddr;
    
    memset(&serverSocketAddr, 0, sizeof(serverSocketAddr));
    serverSocketAddr.sin_len = sizeof(serverSocketAddr);
    serverSocketAddr.sin_family = AF_INET;
    serverSocketAddr.sin_port = htons(port);
    
    //设置socket可重用,这样重启程序就能再次绑定socket
    int reuse = 1;
    setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int));
    
    int socketBind = bind(_socket, (const struct sockaddr *)&serverSocketAddr, sizeof(serverSocketAddr));
    
    if (socketBind == -1) {
        [self tcpSocketClose];
        return NO;
    }
    
    int socketListen = listen(_socket, backlog);
    
    if (socketListen == -1) {
        [self tcpSocketClose];
        return NO;
    }
    
    return socketSuccess;
}

//服务端socket接收客户端接入
- (void)serverTcpSocketAccept:(void (^)(int socket, BOOL acceptSuccess))socketBlock {
    struct sockaddr_in peerAddr;
    socklen_t addrLength = sizeof(peerAddr);
    
    int socketClient = 0;
    while (socketClient != -1) {
        socketClient = accept(_socket, (struct sockaddr *)&peerAddr, &addrLength);
        
        if (socketClient != -1) {
            socketBlock(socketClient, YES);
        }
    }
    
    socketBlock(-1, NO);
}

#pragma mark - Client

//创建客户端socket
- (void)clientTcpSocket:(NSString *)serverAddress port:(int)port {
    if ([XTool isStringEmpty:serverAddress]) {
        [self tcpSocketClose];
        _socket = -1;
        _type = XSocketResultTypeNoHost;//服务器地址为空
        
        return;
    }

    _socket = socket(AF_INET, SOCK_STREAM, 0);
    
    BOOL socketSuccess = (_socket >= 0);
    
    if (!socketSuccess) {
        [self tcpSocketClose];
        _socket = -1;
        _type = XSocketResultTypeFailed;//创建socket失败
        
        return;
    }

    struct sockaddr_in socketAddr;
    memset(&socketAddr, 0, sizeof(socketAddr));
    socketAddr.sin_len = sizeof(socketAddr);
    socketAddr.sin_family = AF_INET;
    socketAddr.sin_port = htons(port);
    socketAddr.sin_addr.s_addr = inet_addr([serverAddress UTF8String]);

    //设置为非阻塞模式
    unsigned long ul = 1;
    ioctl(_socket, FIONBIO, &ul);
    
    int socketConnect = connect(_socket, (struct sockaddr *)&socketAddr, sizeof(socketAddr));
    socketSuccess = (socketConnect == 0);
    
    if (!socketSuccess) {
        
        if (_timeout != -1) {
            //超时设置
            
            struct timeval tm;
            tm.tv_sec = _timeout;
            tm.tv_usec = 0;
            
            fd_set set;
            FD_ZERO(&set);
            FD_SET(_socket, &set);
            
            if(select(_socket+1, NULL, &set, NULL, &tm) > 0){
                
                int error= -1;
                int len = sizeof(int);
                
                getsockopt(_socket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
                if(error == 0) {
                    socketSuccess = YES;
                }
                
            }
            
        }
        
    }
    
    //设置为阻塞模式
    ul = 0;
    ioctl(_socket, FIONBIO, &ul);
    
    if (!socketSuccess) {
        [self tcpSocketClose];
        _socket = -1;
        _type = XSocketResultTypeConnectServerFailed;//连接失败
        
        return;
    }
    
    _type = XSocketResultTypeSuccess;//成功
}

#pragma mark - close
+ (int)tcpSocketClose:(int)socket {
    if (socket == -1) {
        return 0;
    }
    int closeResult = close(socket);
    
    return closeResult;
}

- (int)tcpSocketClose:(int)socket {
    return [XSocket tcpSocketClose:socket];
}

- (int)tcpSocketClose {
    return [XSocket tcpSocketClose:_socket];
}

#pragma mark - read
- (NSData *)tcpSocketRead:(int)socket {
    if (socket == -1) {
        return nil;
    }
    
    NSData *headData = [self tcpSocketReadHead:socket];
    NSData *bodyData = [self tcpSocketReadBodyWithSocket:socket headData:headData];
    NSData *readData = [self tcpSocketReadDataWithHead:headData body:bodyData];
    
    return readData;
}

- (NSData *)tcpSocketRead {
    return [self tcpSocketRead:_socket];
}

- (NSData *)tcpSocketReadHead:(int)socket {
    if (socket == -1) {
        return nil;
    }
    
    NSData *headData = nil;
    NSMutableData *readData = [[NSMutableData alloc] init];
    
    char readBuffer[1024];
    NSInteger enterIndex = NSNotFound;
    
    BOOL readToEnter = NO;
    while (!readToEnter) {
        NSInteger tempRead = read(socket, readBuffer, sizeof(readBuffer));
        
        if (tempRead <= 0) {
            return readData;
        }
        
        [readData appendBytes:readBuffer length:tempRead];
        //读取到分隔行,则跳出
        enterIndex = [XTool getKeyIndexForData:readData key:@"\r\n\r\n"];
        if (enterIndex != NSNotFound && enterIndex >= 0) {
            NSInteger length = enterIndex + 4;
            if (length > readData.length) {
                length = readData.length;
            }
            headData = [readData subdataWithRange:NSMakeRange(0, length)];
            if (headData.length < readData.length) {
                readedBody = [readData subdataWithRange:NSMakeRange(headData.length, readData.length - headData.length)];
            } else {
                readedBody = nil;
            }
            
            readToEnter = YES;
        }
    }
    
    return headData;
}

- (NSData *)tcpSocketReadHead {
    return [self tcpSocketReadHead:_socket];
}

- (NSData *)tcpSocketReadBodyWithSocket:(int)socket headData:(NSData *)headData readBegin:(void (^)(void))beginBlock readProgress:(void (^)(NSData *, NSData *, NSInteger))progressBlock readCompletion:(void (^)(NSData *))completionBlock {
    
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    
    if (![XTool isDataEmpty:readedBody]) {
        [bodyData appendData:readedBody];
    }
    readedBody = nil;
    
    if (beginBlock) {
        beginBlock();
    }
    
    if (socket == -1) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }
    
    if ([XTool isDataEmpty:headData]) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }
    
    //读取包体长度
    NSInteger contentLength = 0;
    NSString *contentLengthValue = [XTool getValueOnResponseHead:headData key:@"Content-Length: "];
    if ([XTool isStringEmpty:contentLengthValue] == NO) {
        contentLength = [contentLengthValue integerValue];
    }
    
    if (contentLength <= 0) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return nil;
    }
    
    if (![XTool isDataEmpty:bodyData]) {
        if (progressBlock) {
            progressBlock(bodyData, bodyData, contentLength);
        }
    }
    
    //如果当前包体已经读完了，不再读，直接退出
    if (bodyData.length >= contentLength) {
        if (completionBlock) {
            completionBlock(bodyData);
        }
        return bodyData;
    }
    
    //包体长度有值,则按长度读包体
    
    char bodyBuffer[1024];
    
    BOOL readComplete = NO;
    while (!readComplete) {
        NSInteger tempRead = read(socket, bodyBuffer, sizeof(bodyBuffer));
        
        if (tempRead <= 0) {
            if (completionBlock) {
                completionBlock(bodyData);
            }
            return bodyData;
        }
        
        if (progressBlock) {
            NSData *tempData = [[NSData alloc] initWithBytes:bodyBuffer length:tempRead];
            [bodyData appendData:tempData];
            progressBlock(tempData, bodyData, contentLength);
        } else {
            [bodyData appendBytes:bodyBuffer length:tempRead];
        }
        
        if (bodyData.length >= contentLength) {
            readComplete = YES;
        }
    }
    
    if (completionBlock) {
        completionBlock(bodyData);
    }
    return bodyData;
}

- (NSData *)tcpSocketReadBodyWithHeadData:(NSData *)headData readBegin:(void (^)(void))beginBlock readProgress:(void (^)(NSData *, NSData *, NSInteger))progressBlock readCompletion:(void (^)(NSData *))completionBlock {
    
    return [self tcpSocketReadBodyWithSocket:_socket headData:headData readBegin:beginBlock readProgress:progressBlock readCompletion:completionBlock];
}

- (NSData *)tcpSocketReadBodyWithSocket:(int)socket headData:(NSData *)headData {
    return [self tcpSocketReadBodyWithSocket:socket headData:headData readBegin:nil readProgress:nil readCompletion:nil];
}

- (NSData *)tcpSocketReadBodyWithHeadData:(NSData *)headData {
    return [self tcpSocketReadBodyWithSocket:_socket headData:headData readBegin:nil readProgress:nil readCompletion:nil];
}

- (NSData *)tcpSocketReadDataWithHead:(NSData *)headData body:(NSData *)bodyData {
    NSMutableData *readData = [[NSMutableData alloc] init];
    
    if ([XTool isDataEmpty:headData] == NO) {
        [readData appendData:headData];
    }
    if ([XTool isDataEmpty:bodyData] == NO) {
        [readData appendData:bodyData];
    }
    
    return readData;
}

#pragma mark - write
+ (void)tcpSocketWrite:(int)socket withData:(NSData *)data {
    if (socket == -1) {
        return;
    }
    
    send(socket, [data bytes], [data length], 0);
}

- (void)tcpSocketWrite:(int)socket withData:(NSData *)data {
    [XSocket tcpSocketWrite:socket withData:data];
}

- (void)tcpSocketWrite:(NSData *)data {
    [self tcpSocketWrite:_socket withData:data];
}

@end
