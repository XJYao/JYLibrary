//
//  XContactAccess.m
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XContactAccess.h"
#import "XIOSVersion.h"


@implementation XContactAccess

/**
 获取权限
 */
+ (void)addressBookRequestAccess:(void (^)(BOOL granted, ABAddressBookRef addressBook))block {
    if ([XIOSVersion isIOS6OrGreater]) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (block) {
                block(granted ? YES : NO, addressBook);
            } else {
                if (addressBook) {
                    CFRelease(addressBook);
                }
            }
        });
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        bool granted = false;
        if (addressBook) {
            granted = true;
        }
        if (block) {
            block(granted ? YES : NO, addressBook);
        } else {
            if (addressBook) {
                CFRelease(addressBook);
            }
        }
    }
}

@end
