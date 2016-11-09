//
//  XDeviceAuthorization.h
//  JYLibrary
//
//  Created by XJY on 16/10/24.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XDeviceAuthorizationStatus) {
    XDeviceAuthorizationStatusNotDetermined = 0,
    XDeviceAuthorizationStatusRestricted,
    XDeviceAuthorizationStatusDenied,
    XDeviceAuthorizationStatusAuthorized
};

@interface XDeviceAuthorization : NSObject

+ (void)cameraAuthorizationStatus:(void (^)(XDeviceAuthorizationStatus authorizationStatus))block;

+ (XDeviceAuthorizationStatus)photoAuthorizationStatus;

@end
