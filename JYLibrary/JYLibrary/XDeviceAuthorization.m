//
//  XDeviceAuthorization.m
//  JYLibrary
//
//  Created by XJY on 16/10/24.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XDeviceAuthorization.h"
#import <AVFoundation/AVFoundation.h>
#import<AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import "XIOSVersion.h"

@implementation XDeviceAuthorization

+ (void)cameraAuthorizationStatus:(void (^)(XDeviceAuthorizationStatus authorizationStatus))block {
    if (!block) {
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            
            switch (authStatus) {
                case AVAuthorizationStatusAuthorized: {
                    block(XDeviceAuthorizationStatusAuthorized);
                } break;
                case AVAuthorizationStatusNotDetermined: {
                    block(XDeviceAuthorizationStatusNotDetermined);
                } break;
                case AVAuthorizationStatusRestricted: {
                    block(XDeviceAuthorizationStatusRestricted);
                } break;
                case AVAuthorizationStatusDenied:
                default: {
                    block(XDeviceAuthorizationStatusDenied);
                } break;
            }
        });
    }];
}

+ (XDeviceAuthorizationStatus)photoAuthorizationStatus {
    XDeviceAuthorizationStatus authorizationStatus = XDeviceAuthorizationStatusDenied;
    
    if ([XIOSVersion isIOS8OrGreater]) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        switch (authStatus) {
            case PHAuthorizationStatusAuthorized: {
                authorizationStatus = XDeviceAuthorizationStatusAuthorized;
            } break;
            case PHAuthorizationStatusNotDetermined: {
                authorizationStatus = XDeviceAuthorizationStatusNotDetermined;
            } break;
            case PHAuthorizationStatusRestricted: {
                authorizationStatus = XDeviceAuthorizationStatusRestricted;
            } break;
            case PHAuthorizationStatusDenied:
            default: {
                authorizationStatus = XDeviceAuthorizationStatusDenied;
            } break;
        }
    } else {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        switch (authStatus) {
            case ALAuthorizationStatusAuthorized: {
                authorizationStatus = XDeviceAuthorizationStatusAuthorized;
            } break;
            case ALAuthorizationStatusNotDetermined: {
                authorizationStatus = XDeviceAuthorizationStatusNotDetermined;
            } break;
            case ALAuthorizationStatusRestricted: {
                authorizationStatus = XDeviceAuthorizationStatusRestricted;
            } break;
            case ALAuthorizationStatusDenied:
            default: {
                authorizationStatus = XDeviceAuthorizationStatusDenied;
            } break;
        }
    }
    
    return authorizationStatus;
}

@end
