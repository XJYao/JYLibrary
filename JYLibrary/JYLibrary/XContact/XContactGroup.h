//
//  XContactGroup.h
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface XContactGroup : NSObject

/**
 获取联系人分组
 */
+ (void)getAllGroups:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, CFArrayRef groups))block; //记得释放addressBook和groups

+ (void)getAllGroups:(void (^)(BOOL granted, CFArrayRef groups))block; //记得释放groups

+ (void)getAllGroupsName:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, NSArray<NSString *> *groups))block; //记得释放addressBook

+ (void)getAllGroupsName:(void (^)(BOOL granted, NSArray<NSString *> *groups))block;

/**
 获取分组里的成员
 */
+ (CFArrayRef)getMembersFromGroup:(ABRecordRef)group;

/**
 向分组中添加成员
 */
+ (BOOL)addMemberToGroup:(ABRecordRef)group person:(ABRecordRef)person;

/**
 从分组中删除成员
 */
+ (BOOL)removeMemberFromGroup:(ABRecordRef)group person:(ABRecordRef)person;

@end
