//
//  UIActionSheet+XActionSheet.m
//  JYLibrary
//
//  Created by XJY on 2017/5/11.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import "UIActionSheet+XActionSheet.h"

@implementation UIActionSheet (XActionSheet)

static const void *XActionSheetUserObjectKey = &XActionSheetUserObjectKey;

- (void)setUserObject:(id)userObject {
    objc_setAssociatedObject(self, XActionSheetUserObjectKey, userObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userObject {
    return objc_getAssociatedObject(self, XActionSheetUserObjectKey);
}

@end
