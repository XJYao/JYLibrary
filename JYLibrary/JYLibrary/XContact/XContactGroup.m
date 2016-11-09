//
//  XContactGroup.m
//  JYLibrary
//
//  Created by XJY on 16/3/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XContactGroup.h"
#import "XContactAccess.h"
#import "XTool.h"

@implementation XContactGroup

/**
 获取联系人分组
 */
+ (void)getAllGroups:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, CFArrayRef))block {
    if (!addressBook) {
        if (block) {
            block(NO, NULL);
        }
        return;
    }
    
    CFRetain(addressBook);
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    CFRelease(addressBook);
    
    if (block) {
        block(YES, groups);
    } else {
        if (groups) {
            CFRelease(groups);
        }
    }
}

+ (void)getAllGroups:(void (^)(BOOL, CFArrayRef))block {
    [XContactAccess addressBookRequestAccess:^(BOOL granted1, ABAddressBookRef addressBook) {
        if (!granted1) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted1, NULL);
            }
            return;
        }
        
        [self getAllGroups:addressBook completion:^(BOOL granted2, CFArrayRef groups) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, groups);
            }
        }];
    }];
}

+ (void)getAllGroupsName:(ABAddressBookRef)addressBook completion:(void (^)(BOOL, NSArray<NSString *> *))block {
    
    if (!addressBook) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    
    CFRetain(addressBook);
    
    [self getAllGroups:addressBook completion:^(BOOL granted, CFArrayRef groups) {
        CFRelease(addressBook);
        
        CFIndex groupsCount = 0;
        if (groups) {
            groupsCount = CFArrayGetCount(groups);
        }
        
        if (groupsCount == 0) {
            if (groups) {
                CFRelease(groups);
            }
            if (block) {
                block(granted, nil);
            }
            return;
        }
        
        NSMutableArray *groupsName = [[NSMutableArray alloc] init];
        for (CFIndex groupIndex = 0; groupIndex < groupsCount; groupIndex ++) {
            ABRecordRef group = CFArrayGetValueAtIndex(groups, groupIndex);
            
            if (!group) {
                continue;
            }
            
            CFTypeRef groupNameRef = ABRecordCopyValue(group, kABGroupNameProperty);
            
            NSString *groupName = (__bridge NSString *)groupNameRef;
            
            if ([XTool isStringEmpty:groupName]) {
                groupName = @"";
            }
            
            [groupsName x_addObject:groupName];
            
            if (groupNameRef) {
                CFRelease(groupNameRef);
            }
        }
        
        if (groups) {
            CFRelease(groups);
        }
        
        if (block) {
            block(granted, groupsName);
        }
    }];
}

+ (void)getAllGroupsName:(void (^)(BOOL, NSArray<NSString *> *))block {
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
        
        [self getAllGroupsName:addressBook completion:^(BOOL granted2, NSArray<NSString *> *groups) {
            if (addressBook) {
                CFRelease(addressBook);
            }
            if (block) {
                block(granted2, groups);
            }
        }];
    }];
}

/**
 获取分组里的成员
 */
+ (CFArrayRef)getMembersFromGroup:(ABRecordRef)group {
    if (!group) {
        return NULL;
    }
    
    CFArrayRef membersFromGroup = ABGroupCopyArrayOfAllMembers(group);
    CFRelease(membersFromGroup);
    return membersFromGroup;
}

/**
 向分组中添加成员
 */
+ (BOOL)addMemberToGroup:(ABRecordRef)group person:(ABRecordRef)person {
    if (!group || !person) {
        return NO;
    }
    
    bool memberAdded = ABGroupAddMember(group, person, NULL);
    
    return memberAdded ? YES : NO;
}

/**
 从分组中删除成员
 */
+ (BOOL)removeMemberFromGroup:(ABRecordRef)group person:(ABRecordRef)person {
    if (!group || !person) {
        return NO;
    }
    
    return ABGroupRemoveMember(group, person, NULL) ? YES : NO;
}

@end
