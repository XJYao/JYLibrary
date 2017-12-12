//
//  UIDevice+XDevice.h
//  JYLibrary
//
//  Created by XJY on 16/8/3.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDevice (XDevice)

///**
// 是否是ipad
// */
//@property (nonatomic, assign, readonly) BOOL isPad;
//
///**
// 是否是模拟器
// */
//@property (nonatomic, assign, readonly) BOOL isSimulator;

/**
 获取UUID
 */
@property (nonatomic, copy, readonly) NSString *UUID;

/**
// 是否越狱
// */
//@property (nonatomic, assign, readonly) BOOL isJailbroken;
//
///**
// WIFI IP地址
// */
//@property (nonatomic, copy, readonly) NSString *ipAddressWIFI;
//
///**
// 蜂窝网络 IP地址
// */
//@property (nonatomic, copy, readonly) NSString *ipAddressCell;

///**
// 设备型号
// */
//@property (nonatomic, copy, readonly) NSString *machineModel;
//
///**
// 设备名称
// */
//@property (nonatomic, copy, readonly) NSString *machineModelName;

/**
 物理地址
 */
@property (nonatomic, copy, readonly) NSString *macAddress;
@property (nonatomic, copy, readonly) NSString *macFromMD5;

/**
 userAgent
 */
@property (nonatomic, copy, readonly) NSString *userAgent;

/**
 退出程序
 */
+ (void)exitApplication;

@end
