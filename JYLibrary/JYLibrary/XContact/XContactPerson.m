//
//  XContactPerson.m
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XContactPerson.h"
#import "XPerson.h"
#import "XTool.h"
#import <objc/runtime.h>
#import "XThread.h"
#import "XContactAccess.h"
#import "NSArray+XArray.h"
#import "NSDictionary+XDictionary.h"


@implementation XContactPerson

/**
 获取所有联系人
 */
+ (void)getAllPersons:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }

    CFRetain(addressBook);

    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (!allPeople) {
        CFRelease(addressBook);
        if (block) {
            block(YES, nil);
        }
        return;
    }

    CFIndex peopleCount = CFArrayGetCount(allPeople);
    if (peopleCount <= 0) {
        CFRelease(allPeople);
        CFRelease(addressBook);
        if (block) {
            block(YES, nil);
        }
        return;
    }

    NSMutableArray<XPerson *> *peoplesArray = [[NSMutableArray alloc] init];

    ABPropertyID propertyTypes[] = {kABPersonFirstNameProperty, kABPersonLastNameProperty, kABPersonMiddleNameProperty, kABPersonPrefixProperty, kABPersonSuffixProperty, kABPersonNicknameProperty, kABPersonFirstNamePhoneticProperty, kABPersonLastNamePhoneticProperty, kABPersonMiddleNamePhoneticProperty, kABPersonOrganizationProperty, kABPersonDepartmentProperty, kABPersonJobTitleProperty, kABPersonNoteProperty,
                                    kABPersonKindProperty,
                                    //        kABPersonAlternateBirthdayProperty,//在ios7下会崩溃
                                    kABPersonBirthdayProperty, kABPersonCreationDateProperty, kABPersonModificationDateProperty,
                                    kABPersonEmailProperty, kABPersonPhoneProperty, kABPersonURLProperty, //kABPersonRelatedNamesProperty,//不知道为什么翻译成中文是“名字”，而且是数组
                                    kABPersonAddressProperty, kABPersonInstantMessageProperty, kABPersonSocialProfileProperty,
                                    kABPersonDateProperty};

    NSInteger propertyTypesTotleSize = sizeof(propertyTypes) / sizeof(ABPropertyID);

    for (CFIndex peopleIndex = 0; peopleIndex < peopleCount; peopleIndex++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, peopleIndex);
        if (!person) {
            continue;
        }

        XPerson *personModel = [[XPerson alloc] init];

        //record id
        ABRecordID recordID = ABRecordGetRecordID(person);
        [personModel setRecordID:recordID];

        //image
        bool hasImage = ABPersonHasImageData(person);
        if (hasImage) {
            CFDataRef thumbnailImageDataRef = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
            CFDataRef originalImageDataRef = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);

            if (thumbnailImageDataRef) {
                [personModel setThumbnailImage:(__bridge NSData *)thumbnailImageDataRef];
            }
            if (originalImageDataRef) {
                [personModel setOriginalImage:(__bridge NSData *)originalImageDataRef];
            }
        }

        //group
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
        if (groupRef) {
            CFTypeRef groupNameRef = ABRecordCopyValue(groupRef, kABGroupNameProperty);
            NSString *groupName = (__bridge NSString *)groupNameRef;
            if (![XTool isStringEmpty:groupName]) {
                [personModel setGroup:groupName];
            }
            if (groupNameRef) {
                CFRelease(groupNameRef);
            }
        }

        //others
        for (CFIndex propertyTypeIndex = 0; propertyTypeIndex < propertyTypesTotleSize; propertyTypeIndex++) {
            ABPropertyID property = propertyTypes[propertyTypeIndex];

            ABPropertyType propertyType = ABPersonGetTypeOfProperty(property);
            if (propertyType == kABInvalidPropertyType) {
                continue;
            }

            CFStringRef propertyNameRef = ABPersonCopyLocalizedPropertyName(property);
            NSString *propertyName = [[NSString alloc] initWithString:(__bridge NSString *)propertyNameRef];
            if (propertyNameRef) {
                CFRelease(propertyNameRef);
            }
            if ([XTool isStringEmpty:propertyName]) {
                continue;
            }

            if ([XTool isEqualFromString:propertyName toString:@"名字"]) {
                propertyName = @"First";
            } else if ([XTool isEqualFromString:propertyName toString:@"姓氏"]) {
                propertyName = @"Last";
            } else if ([XTool isEqualFromString:propertyName toString:@"中间名"]) {
                propertyName = @"Middle";
            } else if ([XTool isEqualFromString:propertyName toString:@"前缀"]) {
                propertyName = @"Prefix";
            } else if ([XTool isEqualFromString:propertyName toString:@"后缀"]) {
                propertyName = @"Suffix";
            } else if ([XTool isEqualFromString:propertyName toString:@"昵称"]) {
                propertyName = @"Nickname";
            } else if ([XTool isEqualFromString:propertyName toString:@"名字拼音或音标"]) {
                propertyName = @"Phonetic First Name";
            } else if ([XTool isEqualFromString:propertyName toString:@"姓氏拼音或音标"]) {
                propertyName = @"Phonetic Last Name";
            } else if ([XTool isEqualFromString:propertyName toString:@"中间名拼音或音标"]) {
                propertyName = @"Phonetic Middle Name";
            } else if ([XTool isEqualFromString:propertyName toString:@"公司"]) {
                propertyName = @"Company";
            } else if ([XTool isEqualFromString:propertyName toString:@"部门"]) {
                propertyName = @"Department";
            } else if ([XTool isEqualFromString:propertyName toString:@"职务"]) {
                propertyName = @"Job Title";
            } else if ([XTool isEqualFromString:propertyName toString:@"备注"]) {
                propertyName = @"Notes";
            } else if ([XTool isEqualFromString:propertyName toString:@"生日"]) {
                propertyName = @"Birthday";
            } else if ([XTool isEqualFromString:propertyName toString:@"电子邮件"]) {
                propertyName = @"Email";
            } else if ([XTool isEqualFromString:propertyName toString:@"电话"]) {
                propertyName = @"Phone";
            } else if ([XTool isEqualFromString:propertyName toString:@"相关名称"]) {
                propertyName = @"Related Names";
            } else if ([XTool isEqualFromString:propertyName toString:@"地址"]) {
                propertyName = @"Address";
            } else if ([XTool isEqualFromString:propertyName toString:@"即时信息"]) {
                propertyName = @"Instant Message";
            } else if ([XTool isEqualFromString:propertyName toString:@"个人资料"]) {
                propertyName = @"Social Profile";
            } else if ([XTool isEqualFromString:propertyName toString:@"日期"]) {
                propertyName = @"Date";
            }

            if ([propertyName rangeOfString:@" "].location != NSNotFound) {
                propertyName = [propertyName stringByReplacingOccurrencesOfString:@" " withString:@""];
            }

            CFTypeRef valueRef = ABRecordCopyValue(person, property);
            if (!valueRef) {
                continue;
            }

            id value = nil;
            BOOL useRuntime = YES;

            if (propertyType == kABStringPropertyType) {
                value = (__bridge NSString *)valueRef;

            } else if (propertyType == kABIntegerPropertyType) {
                value = (__bridge NSNumber *)valueRef;

            } else if (propertyType == kABRealPropertyType) {
            } else if (propertyType == kABDateTimePropertyType) {
                value = (__bridge NSDate *)valueRef;

            } else if (propertyType == kABDictionaryPropertyType) {
                value = (__bridge NSDictionary *)valueRef;

            } else if (propertyType == kABMultiStringPropertyType ||
                       propertyType == kABMultiIntegerPropertyType ||
                       //                           propertyType == kABMultiRealPropertyType ||
                       propertyType == kABMultiDateTimePropertyType ||
                       propertyType == kABMultiDictionaryPropertyType) {
                CFArrayRef valueArrayRef = ABMultiValueCopyArrayOfAllValues(valueRef);
                value = [[NSArray alloc] initWithArray:(__bridge NSArray *)valueArrayRef];
                if (valueArrayRef) {
                    CFRelease(valueArrayRef);
                }

                if (property == kABPersonPhoneProperty ||
                    property == kABPersonEmailProperty ||
                    property == kABPersonAddressProperty) {
                    useRuntime = NO;

                    for (CFIndex index = 0; index < [value count]; index++) {
                        //label
                        CFStringRef labelStringRef = ABMultiValueCopyLabelAtIndex(valueRef, index);
                        NSString *labelString = nil;
                        if (labelStringRef) {
                            labelString = [[NSString alloc] initWithString:(__bridge NSString *)labelStringRef];
                            CFRelease(labelStringRef);
                        }

                        if ([XTool isStringEmpty:labelString]) {
                            continue;
                        }

                        //value
                        CFTypeRef valueTypeRef = ABMultiValueCopyValueAtIndex(valueRef, index);

                        id valueObj = (__bridge id)valueTypeRef;

                        if ([XTool isObjectNull:valueObj]) {
                            if (valueTypeRef) {
                                CFRelease(valueTypeRef);
                            }
                            continue;
                        }

                        //add to model
                        NSMutableArray *valueForLabelArray = nil;
                        NSMutableDictionary *target = nil;

                        if (property == kABPersonPhoneProperty) {
                            target = personModel.Phone;

                        } else if (property == kABPersonEmailProperty) {
                            target = personModel.Email;

                        } else if (property == kABPersonAddressProperty) {
                            target = personModel.Address;
                        }

                        if (!target) {
                            target = [NSMutableDictionary dictionary];
                        }

                        NSMutableArray *allLabels = nil;
                        id labelsObj = [target objectForKey:xPersonLabelsKey];
                        if ([labelsObj isKindOfClass:[NSMutableArray class]]) {
                            allLabels = labelsObj;
                        } else if ([labelsObj isKindOfClass:[NSArray class]]) {
                            allLabels = [[NSMutableArray alloc] initWithArray:labelsObj];
                        }
                        if (!allLabels) {
                            if (valueTypeRef) {
                                CFRelease(valueTypeRef);
                            }
                            continue;
                        }

                        if ([allLabels containsObject:labelString]) {
                            id valueForLabelObj = [target objectForKey:labelString];
                            if ([valueForLabelObj isKindOfClass:[NSMutableArray class]]) {
                                valueForLabelArray = valueForLabelObj;
                            } else if ([valueForLabelObj isKindOfClass:[NSArray class]]) {
                                valueForLabelArray = [[NSMutableArray alloc] initWithArray:valueForLabelObj];
                            }
                        } else {
                            valueForLabelArray = [[NSMutableArray alloc] init];
                            [allLabels x_addObject:labelString];
                            [target x_setObject:allLabels forKey:xPersonLabelsKey];
                        }

                        if (!valueForLabelArray) {
                            valueForLabelArray = [NSMutableArray array];
                        }
                        [valueForLabelArray x_addObject:valueObj];
                        [target x_setObject:valueForLabelArray forKey:labelString];

                        if (valueTypeRef) {
                            CFRelease(valueTypeRef);
                        }
                    }
                }
            }

            if (!useRuntime) {
                if (valueRef) {
                    CFRelease(valueRef);
                }
                continue;
            }

            if (!value) {
                if (valueRef) {
                    CFRelease(valueRef);
                }
                continue;
            }

            Ivar ivar = class_getInstanceVariable([personModel class], [[@"_" stringByAppendingString:propertyName] UTF8String]);
            if (!ivar) {
                if (valueRef) {
                    CFRelease(valueRef);
                }
                continue;
            }

            object_setIvar(personModel, ivar, value);

            if (valueRef) {
                CFRelease(valueRef);
            }
        }

        [peoplesArray x_addObject:personModel];
    }

    CFRelease(allPeople);
    CFRelease(addressBook);

    if (block) {
        block(YES, peoplesArray);
    }
}

+ (void)getAllPersons:(void (^)(BOOL, NSArray<XPerson *> *))block {
    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, nil);
            }
            return;
        }

        [self getAllPersons:addressBook completion:^(BOOL granted2, NSArray<XPerson *> *persons) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, persons);
            }
        }];
    }];
}

/**
 添加联系人
 */
+ (void)addPerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, BOOL))block {
    [self changePerson:person addressBook:addressBook shouldCreate:YES completion:block];
}

+ (void)addPerson:(XPerson *)person completion:(void (^)(BOOL, BOOL))block {
    if (!person) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, NO);
            }
            return;
        }

        [self addPerson:person addressBook:addressBook completion:^(BOOL granted2, BOOL success) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, success);
            }
        }];
    }];
}

/**
 添加多个联系人
 */
+ (void)addPersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {
        NSMutableArray<XPerson *> *failedPersons = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < persons.count; i++) {
            XPerson *person = [persons x_objectAtIndex:i];

            [self addPerson:person addressBook:addressBook completion:^(BOOL granted, BOOL success) {
                if (!success) {
                    [failedPersons x_addObject:person];
                }

                if (i == persons.count - 1) {
                    if (block) {
                        block(granted, failedPersons);
                    }
                }

                sendSignal();
            }];

            waitSignal();
        }
    }];
}

+ (void)addPersons:(NSArray<XPerson *> *)persons completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, nil);
            }
            return;
        }

        [self addPersons:persons addressBook:addressBook completion:^(BOOL granted2, NSArray<XPerson *> *failedPersons) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, failedPersons);
            }
        }];
    }];
}

/**
 删除联系人
 */
+ (void)removePersonWithRecordID:(NSInteger)recordID addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, BOOL))block {
    if (!addressBook) {
        if (block) {
            block(NO, NO);
        }
        return;
    }
    if (recordID <= 0 || recordID == NSNotFound) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    CFRetain(addressBook);

    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, (ABRecordID)recordID);

    if (!person) {
        CFRelease(addressBook);
        if (block) {
            block(YES, NO);
        }
        return;
    }

    BOOL success = ABAddressBookRemoveRecord(addressBook, person, NULL);
    if (success) {
        if (ABAddressBookHasUnsavedChanges(addressBook)) {
            success = ABAddressBookSave(addressBook, NULL);
        }
    }

    CFRelease(addressBook);

    if (block) {
        block(YES, success);
    }
}

+ (void)removePersonWithRecordID:(NSInteger)recordID completion:(void (^)(BOOL, BOOL))block {
    if (recordID <= 0 || recordID == NSNotFound) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, NO);
            }
            return;
        }

        [self removePersonWithRecordID:recordID addressBook:addressBook completion:^(BOOL granted2, BOOL success) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, success);
            }
        }];
    }];
}

+ (void)removePersonWithPerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, BOOL))block {
    if (!addressBook) {
        if (block) {
            block(NO, NO);
        }
        return;
    }
    if (!person) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    [self removePersonWithRecordID:person.RecordID addressBook:addressBook completion:block];
}

+ (void)removePersonWithPerson:(XPerson *)person completion:(void (^)(BOOL, BOOL))block {
    if (!person) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    [self removePersonWithRecordID:person.RecordID completion:block];
}

/**
 删除多个联系人
 */
+ (void)removePersonsWithRecordIDs:(NSArray<NSNumber *> *)recordIDs addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, NSArray<NSNumber *> *))block {
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    if ([XTool isArrayEmpty:recordIDs]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {
        NSMutableArray<NSNumber *> *failedRecordIDs = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < recordIDs.count; i++) {
            NSNumber *recordIDNumber = [recordIDs x_objectAtIndex:i];

            ABRecordID recordID = (ABRecordID)[recordIDNumber intValue];

            if (recordID == NSNotFound || recordID <= 0) {
                [failedRecordIDs x_addObject:recordIDNumber];

            } else {
                [self removePersonWithRecordID:recordID addressBook:addressBook completion:^(BOOL granted, BOOL success) {
                    if (!success) {
                        [failedRecordIDs x_addObject:recordIDNumber];
                    }

                    if (i == recordIDs.count - 1) {
                        if (block) {
                            block(granted, failedRecordIDs);
                        }
                    }

                    sendSignal();
                }];

                waitSignal();
            }
        }
    }];
}

+ (void)removePersonsWithRecordIDs:(NSArray<NSNumber *> *)recordIDs completion:(void (^)(BOOL, NSArray<NSNumber *> *))block {
    if ([XTool isArrayEmpty:recordIDs]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, nil);
            }
            return;
        }

        [self removePersonsWithRecordIDs:recordIDs addressBook:addressBook completion:^(BOOL granted2, NSArray<NSNumber *> *failedRecordIDs) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, failedRecordIDs);
            }
        }];
    }];
}

+ (void)removePersonsWithPersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {
        NSMutableArray<XPerson *> *failedPersons = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < persons.count; i++) {
            XPerson *person = [persons x_objectAtIndex:i];

            [self removePersonWithPerson:person addressBook:addressBook completion:^(BOOL granted, BOOL success) {
                if (!success) {
                    [failedPersons x_addObject:person];
                }

                if (i == persons.count - 1) {
                    if (block) {
                        block(granted, failedPersons);
                    }
                }

                sendSignal();
            }];

            waitSignal();
        }
    }];
}

+ (void)removePersonsWithPersons:(NSArray<XPerson *> *)persons completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, nil);
            }
            return;
        }

        [self removePersonsWithPersons:persons addressBook:addressBook completion:^(BOOL granted2, NSArray<XPerson *> *failedPersons) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, failedPersons);
            }
        }];
    }];
}

/**
 修改联系人
 */
+ (void)changePerson:(XPerson *)person addressBook:(ABAddressBookRef)addressBook shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL, BOOL))block {
    if (!addressBook) {
        if (block) {
            block(NO, NO);
        }
        return;
    }
    if (!person) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    unsigned int ivarsCount = 0;
    Ivar *ivars = class_copyIvarList([person class], &ivarsCount);

    if (!ivars) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    if (ivarsCount == 0) {
        if (ivars) {
            free(ivars);
        }
        if (block) {
            block(YES, NO);
        }
        return;
    }

    BOOL isNewPerson = YES;
    ABRecordRef personRef = NULL;

    CFRetain(addressBook);

    if (person.RecordID <= 0 || person.RecordID == NSNotFound) {
        if (!shouldCreate) {
            if (ivars) {
                free(ivars);
            }
            CFRelease(addressBook);
            if (block) {
                block(YES, NO);
            }
            return;
        }

        personRef = ABPersonCreate();
    } else {
        personRef = ABAddressBookGetPersonWithRecordID(addressBook, (ABRecordID)person.RecordID);

        if (shouldCreate && !personRef) {
            personRef = ABPersonCreate();
        } else {
            isNewPerson = NO;
        }
    }

    if (!personRef) {
        if (ivars) {
            free(ivars);
        }
        CFRelease(addressBook);
        if (block) {
            block(YES, NO);
        }
        return;
    }

    for (int i = 0; i < ivarsCount; i++) {
        Ivar ivar = ivars[i];
        if (!ivar) {
            continue;
        }

        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];

        if ([XTool isStringEmpty:ivarName]) {
            continue;
        }

        BOOL useRuntime = YES;
        ABPropertyID propertyID = 0;

        if ([ivarName isEqualToString:@"_First"]) {
            propertyID = kABPersonFirstNameProperty;

        } else if ([ivarName isEqualToString:@"_Last"]) {
            propertyID = kABPersonLastNameProperty;

        } else if ([ivarName isEqualToString:@"_Address"]) {
            propertyID = kABPersonAddressProperty;

        } else if ([ivarName isEqualToString:@"_Phone"]) {
            propertyID = kABPersonPhoneProperty;

        } else if ([ivarName isEqualToString:@"_Email"]) {
            propertyID = kABPersonEmailProperty;

        } else if ([ivarName isEqualToString:@"_Company"]) {
            propertyID = kABPersonOrganizationProperty;

        } else if ([ivarName isEqualToString:@"_JobTitle"]) {
            propertyID = kABPersonJobTitleProperty;

        } else if ([ivarName isEqualToString:@"_Department"]) {
            propertyID = kABPersonDepartmentProperty;

        } else if ([ivarName isEqualToString:@"_Birthday"]) {
            propertyID = kABPersonBirthdayProperty;

        } else if ([ivarName isEqualToString:@"_Notes"]) {
            propertyID = kABPersonNoteProperty;

        } else if ([ivarName isEqualToString:@"_OriginalImage"]) {
            useRuntime = NO;

            if (person.OriginalImage) {
                ABPersonSetImageData(personRef, (__bridge CFDataRef)person.OriginalImage, NULL);
            }

        } else {
            useRuntime = NO;
        }

        if (!useRuntime) {
            continue;
        }

        id ivarValue = object_getIvar(person, ivar);
        CFTypeRef value = (__bridge CFTypeRef)ivarValue;

        if (value) {
            if (propertyID == kABPersonPhoneProperty ||
                propertyID == kABPersonEmailProperty ||
                propertyID == kABPersonAddressProperty) {
                ABPropertyType propertyType = ABPersonGetTypeOfProperty(propertyID);
                NSMutableDictionary *valueDictionary = (__bridge NSMutableDictionary *)value;

                if ([XTool isDictionaryEmpty:valueDictionary]) {
                    ABRecordRemoveValue(personRef, propertyID, NULL);

                } else {
                    ABMutableMultiValueRef mutableMultiValueRef = ABMultiValueCreateMutable(propertyType);
                    ;
                    if (!mutableMultiValueRef) {
                        continue;
                    }

                    NSArray *allLabels = [valueDictionary objectForKey:xPersonLabelsKey];

                    for (NSString *valueLabel in allLabels) {
                        NSArray *values = [valueDictionary objectForKey:valueLabel];

                        if ([XTool isArrayEmpty:values]) {
                            continue;
                        }

                        for (id valueObj in values) {
                            ABMultiValueIdentifier multivalueIdentifier;
                            ABMultiValueAddValueAndLabel(mutableMultiValueRef, (__bridge CFTypeRef)valueObj, (__bridge CFStringRef)valueLabel, &multivalueIdentifier);
                        }
                    }

                    ABRecordSetValue(personRef, propertyID, mutableMultiValueRef, NULL);
                    CFRelease(mutableMultiValueRef);
                }
            } else {
                ABRecordSetValue(personRef, propertyID, value, NULL);
            }
        } else {
            ABRecordRemoveValue(personRef, propertyID, NULL);
        }
    }

    free(ivars);

    bool success = true;

    if (isNewPerson) {
        success = ABAddressBookAddRecord(addressBook, personRef, NULL);
    }

    if (!success) {
        if (ABAddressBookHasUnsavedChanges(addressBook)) {
            ABAddressBookSave(addressBook, NULL);
        }
        if (isNewPerson) {
            CFRelease(personRef);
        }

        CFRelease(addressBook);
        if (block) {
            block(YES, NO);
        }
        return;
    }

    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        success = ABAddressBookSave(addressBook, NULL);
    }

    if (!success) {
        if (isNewPerson) {
            CFRelease(personRef);
        }
        CFRelease(addressBook);
        if (block) {
            block(YES, NO);
        }
        return;
    }

    //record id
    ABRecordID recordID = ABRecordGetRecordID(personRef);
    if (recordID <= 0 || recordID == NSNotFound) {
        if (isNewPerson) {
            CFRelease(personRef);
        }
        CFRelease(addressBook);
        if (block) {
            block(YES, NO);
        }
        return;
    }
    [person setRecordID:recordID];

    //group

    ABRecordRef currentGroup = ABAddressBookGetGroupWithRecordID(addressBook, recordID);

    ABRecordRef wantGroup = NULL;

    BOOL isWantGroupCreated = NO;

    if (![XTool isStringEmpty:person.Group]) {
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups) {
            CFIndex allGroupsCount = CFArrayGetCount(allGroups);
            for (CFIndex groupIndex = 0; groupIndex < allGroupsCount; groupIndex++) {
                ABRecordRef tempGroup = CFArrayGetValueAtIndex(allGroups, groupIndex);

                if (tempGroup) {
                    CFTypeRef groupNameRef = ABRecordCopyValue(tempGroup, kABGroupNameProperty);
                    NSString *groupName = (__bridge NSString *)groupNameRef;
                    if (![XTool isStringEmpty:groupName] && [groupName isEqualToString:person.Group]) {
                        wantGroup = tempGroup;
                        CFRelease(groupNameRef);
                        break;
                    }
                    CFRelease(groupNameRef);
                }
            }
            CFRelease(allGroups);
        }

        if (!wantGroup) {
            wantGroup = ABGroupCreate();
            if (wantGroup) {
                isWantGroupCreated = YES;

                bool setGroupName = ABRecordSetValue(wantGroup, kABGroupNameProperty, (__bridge CFTypeRef)person.Group, NULL);
                if (setGroupName) {
                    bool groupAdded = ABAddressBookAddRecord(addressBook, wantGroup, NULL);
                    if (groupAdded) {
                        if (ABAddressBookHasUnsavedChanges(addressBook)) {
                            success = ABAddressBookSave(addressBook, NULL);
                        }
                    } else {
                        success = false;
                    }
                } else {
                    success = false;
                }
            } else {
                success = false;
            }
        }
    }

    if (!success) {
        if (isWantGroupCreated) {
            CFRelease(wantGroup);
        }
        if (isNewPerson) {
            CFRelease(personRef);
        }
        CFRelease(addressBook);
        if (block) {
            block(YES, YES);
        }
        return;
    }

    if (wantGroup) {
        if (wantGroup != currentGroup) {
            bool memberRemoved = true;
            if (currentGroup) {
                memberRemoved = ABGroupRemoveMember(currentGroup, personRef, NULL);
            }
            if (memberRemoved) {
                success = ABGroupAddMember(wantGroup, personRef, NULL);
            } else {
                success = false;
            }
        }
        if (isWantGroupCreated) {
            CFRelease(wantGroup);
        }
    } else {
        if (currentGroup) {
            success = ABGroupRemoveMember(currentGroup, personRef, NULL);
        }
    }

    if (isNewPerson) {
        CFRelease(personRef);
    }

    if (!success) {
        CFRelease(addressBook);
        if (block) {
            block(YES, YES);
        }
        return;
    }

    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        ABAddressBookSave(addressBook, NULL);
    }

    CFRelease(addressBook);
    if (block) {
        block(YES, YES);
    }
}

+ (void)changePerson:(XPerson *)person shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL, BOOL))block {
    if (!person) {
        if (block) {
            block(YES, NO);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, NO);
            }
            return;
        }

        [self changePerson:person addressBook:addressBook shouldCreate:shouldCreate completion:^(BOOL granted2, BOOL success) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, success);
            }
        }];

    }];
}

/**
 修改多个联系人
 */
+ (void)changePersons:(NSArray<XPerson *> *)persons addressBook:(ABAddressBookRef)addressBook shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {
        NSMutableArray<XPerson *> *failedPersons = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < persons.count; i++) {
            XPerson *person = [persons x_objectAtIndex:i];

            [self changePerson:person addressBook:addressBook shouldCreate:shouldCreate completion:^(BOOL granted, BOOL success) {
                if (!success) {
                    [failedPersons x_addObject:person];
                }

                if (i == persons.count - 1) {
                    if (block) {
                        block(granted, failedPersons);
                    }
                }

                sendSignal();
            }];

            waitSignal();
        }
    }];
}

+ (void)changePersons:(NSArray<XPerson *> *)persons shouldCreate:(BOOL)shouldCreate completion:(void (^)(BOOL, NSArray<XPerson *> *))block {
    if ([XTool isArrayEmpty:persons]) {
        if (block) {
            block(YES, nil);
        }
        return;
    }

    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, nil);
            }
            return;
        }

        [self changePersons:persons addressBook:addressBook shouldCreate:shouldCreate completion:^(BOOL granted2, NSArray<XPerson *> *failedPersons) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, failedPersons);
            }
        }];
    }];
}

+ (NSString *)chineseForLabel:(NSString *)label {
    if ([XTool isStringEmpty:label]) return label;

    if ([label isEqualToString:xPersonPhoneLabelHome])
        label = @"家庭";
    else if ([label isEqualToString:xPersonPhoneLabelWork])
        label = @"工作";
    else if ([label isEqualToString:xPersonPhoneLabelOther])
        label = @"其他";
    else if ([label isEqualToString:xPersonPhoneLabelMobile])
        label = @"手机";
    else if ([label isEqualToString:xPersonPhoneLabelIPhone])
        label = @"iPhone";
    else if ([label isEqualToString:xPersonPhoneLabelMain])
        label = @"主要";
    else if ([label isEqualToString:xPersonPhoneLabelHomeFAX])
        label = @"家庭传真";
    else if ([label isEqualToString:xPersonPhoneLabelWorkFAX])
        label = @"工作传真";
    else if ([label isEqualToString:xPersonPhoneLabelOtherFAX])
        label = @"其他传真";
    else if ([label isEqualToString:xPersonPhoneLabelPager])
        label = @"传呼";

    else if ([label isEqualToString:xPersonEmailLabelHome])
        label = @"家庭";
    else if ([label isEqualToString:xPersonEmailLabelWork])
        label = @"工作";
    else if ([label isEqualToString:xPersonEmailLabelOther])
        label = @"其他";
    else if ([label isEqualToString:xPersonEmailLabelICloud])
        label = @"iCloud";

    else if ([label isEqualToString:xPersonAddressLabelHome])
        label = @"家庭";
    else if ([label isEqualToString:xPersonAddressLabelWork])
        label = @"工作";
    else if ([label isEqualToString:xPersonAddressLabelOther])
        label = @"其他";

    else if ([label isEqualToString:xPersonAddressKeyCountry])
        label = @"国家";
    else if ([label isEqualToString:xPersonAddressKeyState])
        label = @"省份";
    else if ([label isEqualToString:xPersonAddressKeyCity])
        label = @"城市";
    else if ([label isEqualToString:xPersonAddressKeyStreet])
        label = @"街道";
    else if ([label isEqualToString:xPersonAddressKeyCountryCode])
        label = @"国家代码";
    else if ([label isEqualToString:xPersonAddressKeyZIP])
        label = @"邮政编码";

    return label;
}

+ (NSString *)labelForChinese:(NSString *)chinese {
    if ([XTool isStringEmpty:chinese]) return chinese;

    if ([chinese rangeOfString:@"家庭"].location != NSNotFound ||
        [chinese rangeOfString:@"住宅"].location != NSNotFound) {
        return @"_$!<Home>!$_";

    } else if ([chinese rangeOfString:@"工作"].location != NSNotFound ||
               [chinese rangeOfString:@"单位"].location != NSNotFound ||
               [chinese rangeOfString:@"公司"].location != NSNotFound) {
        return @"_$!<Work>!$_";

    } else {
        return @"_$!<Other>!$_";
    }
}

@end
