//
//  XContactAccess.h
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface XContactAccess : NSObject

/**
 获取权限
 */
+ (void)addressBookRequestAccess:(void (^)(BOOL granted, ABAddressBookRef addressBook))block;//记得释放addressBook

@end
