//
//  XNetwork.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XNetwork.h"
#import <netdb.h>
#import <arpa/inet.h>
#import "XTool.h"


@implementation XNetwork

+ (struct hostent *)getHostByAddress:(NSString *)address {
    char *hostname = (char *)[address UTF8String];
    return gethostbyname(hostname);
}

+ (BOOL)isDomain:(NSString *)hostName {
    if ([XTool isStringEmpty:hostName]) {
        return NO;
    }

    const char *hostNameChar = [hostName UTF8String];
    if (isalpha((hostNameChar)[0])) { //判断是否是域名
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)getIPWithHostName:(NSString *)hostName {
    if ([XTool isStringEmpty:hostName]) {
        return nil;
    }

    const char *hostNameChar = [hostName UTF8String];

    if (!isalpha((hostNameChar)[0])) { //判断是否是域名
        return hostName;
    }

    struct hostent *host_entry;

    @try {
        host_entry = gethostbyname(hostNameChar);

    } @catch (NSException *exception) {
        return nil;
    }

    if (!host_entry) {
        return nil;
    }

    struct in_addr ip_addr;
    memcpy(&ip_addr, host_entry->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

    NSString *strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

@end
