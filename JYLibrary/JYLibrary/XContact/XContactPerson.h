//
//  XContactPerson.h
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class XPerson;

@interface XContactPerson : NSObject

/**
 获取所有联系人
 */
+ (void)getAllPersons:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, NSArray<XPerson *> *persons))block;
+ (void)getAllPersons:(void (^)(BOOL granted, NSArray<XPerson *> *persons))block;

/**
 添加联系人
 */
+ (void)addPerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, BOOL success))block;
+ (void)addPerson:(XPerson *)person completion:(void (^)(BOOL granted, BOOL success))block;

/**
 添加多个联系人
 */
+ (void)addPersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;
+ (void)addPersons:(NSArray<XPerson *> *)persons completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;

/**
 删除联系人
 */
+ (void)removePersonWithRecordID:(NSInteger)recordID addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, BOOL success))block;
+ (void)removePersonWithRecordID:(NSInteger)recordID completion:(void (^)(BOOL granted, BOOL success))block;
+ (void)removePersonWithPerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, BOOL success))block;
+ (void)removePersonWithPerson:(XPerson *)person completion:(void (^)(BOOL granted, BOOL success))block;

/**
 删除多个联系人
 */
+ (void)removePersonsWithRecordIDs:(NSArray<NSNumber *> *)recordIDs addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, NSArray<NSNumber *> *failedRecordIDs))block;
+ (void)removePersonsWithRecordIDs:(NSArray<NSNumber *> *)recordIDs completion:(void (^)(BOOL granted, NSArray<NSNumber *> *failedRecordIDs))block;
+ (void)removePersonsWithPersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;
+ (void)removePersonsWithPersons:(NSArray<XPerson *> *)persons completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;

/**
 修改联系人
 */
+ (void)changePerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL granted, BOOL success))block;
+ (void)changePerson:(XPerson *)person shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL granted, BOOL success))block;

/**
 修改多个联系人
 */
+ (void)changePersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;
+ (void)changePersons:(NSArray<XPerson *> *)persons shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL granted, NSArray<XPerson *> *failedPersons))block;

/**
 标签转换为中文
 */
+ (NSString *)chineseForLabel:(NSString *)label;

/**
 中文转换为标签
 */
+ (NSString *)labelForChinese:(NSString *)chinese;

@end
