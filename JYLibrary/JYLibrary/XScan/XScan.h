//
//  XScan.h
//  XScan
//
//  Created by XJY on 16/2/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XScanAuthorizationStatus) {
    XScanAuthorizationStatusNotDetermined = 0,
    XScanAuthorizationStatusRestricted,
    XScanAuthorizationStatusDenied,
    XScanAuthorizationStatusAuthorized
};

@interface XScan : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect scanRect;

- (instancetype)initWithView:(UIView *)view accessCompletion:(void (^)(XScanAuthorizationStatus authorizationStatus))block;

- (void)start:(void (^)(NSString *result))block;

- (void)stop;

@end
