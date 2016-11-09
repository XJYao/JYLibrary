//
//  XConstraint.m
//  JYLibrary
//
//  Created by XJY on 16/2/15.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XConstraint.h"
#import <objc/runtime.h>
#import "XIOSVersion.h"

@interface UIView ()

@property (nonatomic, strong) id x_firstItem;
@property (nonatomic, strong) NSMutableArray *x_firstAttributes;
@property (nonatomic, assign) NSLayoutRelation x_relation;
@property (nonatomic, strong) id x_secondItem;
@property (nonatomic, strong) NSMutableArray *x_secondAttributes;

@property (nonatomic, assign) CGFloat x_multi;
@property (nonatomic, assign) CGFloat x_cons;

@end

@implementation UIView (XConstraint)

#pragma mark - Public

- (XConstraintMaker *)x_left {
    return [self x_addAttribute:NSLayoutAttributeLeft];
}

- (XConstraintMaker *)x_right {
    return [self x_addAttribute:NSLayoutAttributeRight];
}

- (XConstraintMaker *)x_top {
    return [self x_addAttribute:NSLayoutAttributeTop];
}

- (XConstraintMaker *)x_bottom {
    return [self x_addAttribute:NSLayoutAttributeBottom];
}

- (XConstraintMaker *)x_leading {
    return [self x_addAttribute:NSLayoutAttributeLeading];
}

- (XConstraintMaker *)x_trailing {
    return [self x_addAttribute:NSLayoutAttributeTrailing];
}

- (XConstraintMaker *)x_width {
    return [self x_addAttribute:NSLayoutAttributeWidth];
}

- (XConstraintMaker *)x_height {
    return [self x_addAttribute:NSLayoutAttributeHeight];
}

- (XConstraintMaker *)x_centerX {
    return [self x_addAttribute:NSLayoutAttributeCenterX];
}

- (XConstraintMaker *)x_centerY {
    return [self x_addAttribute:NSLayoutAttributeCenterY];
}

- (XConstraintMaker *)x_centerXY {
    [self x_addAttribute:NSLayoutAttributeCenterX];
    return [self x_addAttribute:NSLayoutAttributeCenterY];
}

- (XConstraintMaker *)x_edge {
    [self x_addAttribute:NSLayoutAttributeLeading];
    [self x_addAttribute:NSLayoutAttributeTrailing];
    [self x_addAttribute:NSLayoutAttributeTop];
    return [self x_addAttribute:NSLayoutAttributeBottom];
}

- (XConstraintMaker *)x_size {
    [self x_addAttribute:NSLayoutAttributeWidth];
    return [self x_addAttribute:NSLayoutAttributeHeight];
}

- (XConstraintMaker *(^)(CGFloat))x_multiplier {
    __weak typeof(self) weak_self = self;
    
    return ^id(CGFloat multi) {
        weak_self.x_multi = multi;
        return weak_self;
    };
}

- (XConstraintMaker *(^)(CGFloat))x_constant {
    __weak typeof(self) weak_self = self;
    
    return ^id(CGFloat cons) {
        weak_self.x_cons = cons;
        
        if (weak_self.x_secondItem) {
            [weak_self x_addConstraint];
        } else {
            [weak_self x_clear];
        }
        
        return weak_self;
    };
}

- (XConstraintMaker *(^)(id))x_equalTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        weak_self.x_relation = NSLayoutRelationEqual;
        [weak_self x_relationTo:reference];
        return weak_self;
    };
}

- (XConstraintMaker *(^)(id))x_lessThanOrEqualTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        weak_self.x_relation = NSLayoutRelationLessThanOrEqual;
        [weak_self x_relationTo:reference];
        return weak_self;
    };
}

- (XConstraintMaker *(^)(id))x_greaterThanOrEqualTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        weak_self.x_relation = NSLayoutRelationGreaterThanOrEqual;
        [weak_self x_relationTo:reference];
        return weak_self;
    };
}

- (XConstraintMaker *(^)(id))x_update_equalTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        NSMutableArray *firstAttris = [weak_self.x_firstAttributes mutableCopy];
        weak_self.x_remove();
        weak_self.x_firstAttributes = firstAttris;
        return weak_self.x_equalTo(reference);
    };
}

- (XConstraintMaker *(^)(id))x_update_lessThanOrEqualTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        NSMutableArray *firstAttris = [weak_self.x_firstAttributes mutableCopy];
        weak_self.x_remove();
        weak_self.x_firstAttributes = firstAttris;
        return weak_self.x_lessThanOrEqualTo(reference);
    };
}

- (XConstraintMaker *(^)(id))x_update_greaterThanOrEqualTo {
    __weak typeof(self) weak_self = self;
    
    return ^id(id reference) {
        NSMutableArray *firstAttris = [weak_self.x_firstAttributes mutableCopy];
        weak_self.x_remove();
        weak_self.x_firstAttributes = firstAttris;
        return weak_self.x_greaterThanOrEqualTo(reference);
    };
}

- (XConstraintMaker *(^)(void))x_remove {
    __weak typeof(self) weak_self = self;
    
    return ^id(void) {
        weak_self.x_firstItem = weak_self;
        
        for (NSLayoutConstraint *existConstraint in weak_self.superview.constraints) {
            if (existConstraint.firstItem == weak_self.x_firstItem)
            {
                id existFirstAttributeObject = @(existConstraint.firstAttribute);
                if (existFirstAttributeObject) {
                    if ([weak_self.x_firstAttributes containsObject:existFirstAttributeObject]) {
                        [weak_self x_removeExistConstraint:existConstraint];
                    }
                }
            }
        }
        
        id widthObject = @(NSLayoutAttributeWidth);
        id heightObject = @(NSLayoutAttributeHeight);
        
        if ([weak_self.x_firstAttributes containsObject:widthObject] ||
            [weak_self.x_firstAttributes containsObject:heightObject]) {
            
            for (NSLayoutConstraint *existConstraint in weak_self.constraints) {
                if (existConstraint.firstItem == weak_self.x_firstItem) {
                    
                    id existFirstAttributeObject = @(existConstraint.firstAttribute);
                    if (existFirstAttributeObject) {
                        if ([weak_self.x_firstAttributes containsObject:existFirstAttributeObject]) {
                            [weak_self x_removeExistConstraint:existConstraint];
                        }
                    }
                }
            }
        }
        [weak_self x_clear];
        return weak_self;
    };
}

#pragma mark - Private

#pragma mark property

static const void *XConstraintFirstItemKey = &XConstraintFirstItemKey;
static const void *XConstraintFirstAttributesKey = &XConstraintFirstAttributesKey;

static const void *XConstraintRelationKey = &XConstraintRelationKey;

static const void *XConstraintSecondItemKey = &XConstraintSecondItemKey;
static const void *XConstraintSecondAttributesKey = &XConstraintSecondAttributesKey;

static const void *XConstraintMultiplierKey = &XConstraintMultiplierKey;
static const void *XConstraintConstantKey = &XConstraintConstantKey;

- (void)setX_firstItem:(id)x_firstItem {
    objc_setAssociatedObject(self, XConstraintFirstItemKey, x_firstItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)x_firstItem {
    return objc_getAssociatedObject(self, XConstraintFirstItemKey);
}

- (void)setX_firstAttributes:(NSMutableArray *)x_firstAttributes {
    objc_setAssociatedObject(self, XConstraintFirstAttributesKey, x_firstAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)x_firstAttributes {
    NSMutableArray *firstAttributes = objc_getAssociatedObject(self, XConstraintFirstAttributesKey);
    if (!firstAttributes) {
        firstAttributes = [[NSMutableArray alloc] init];
        self.x_firstAttributes = firstAttributes;
    }
    return firstAttributes;
}

- (void)setX_relation:(NSLayoutRelation)x_relation {
    objc_setAssociatedObject(self, XConstraintRelationKey, [NSNumber numberWithInteger:x_relation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutRelation)x_relation {
    id relationObj = objc_getAssociatedObject(self, XConstraintRelationKey);
    if (!relationObj) {
        self.x_relation = NSLayoutRelationEqual;
    }
    return relationObj ? [relationObj integerValue] : NSLayoutRelationEqual;
}

- (void)setX_secondItem:(id)x_secondItem {
    objc_setAssociatedObject(self, XConstraintSecondItemKey, x_secondItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)x_secondItem {
    return objc_getAssociatedObject(self, XConstraintSecondItemKey);
}

- (void)setX_secondAttributes:(NSMutableArray *)x_secondAttributes {
    objc_setAssociatedObject(self, XConstraintSecondAttributesKey, x_secondAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)x_secondAttributes {
    NSMutableArray *secondAttributes = objc_getAssociatedObject(self, XConstraintSecondAttributesKey);
    if (!secondAttributes) {
        secondAttributes = [[NSMutableArray alloc] init];
        self.x_secondAttributes = secondAttributes;
    }
    return secondAttributes;
}

- (void)setX_multi:(CGFloat)x_multi {
    objc_setAssociatedObject(self, XConstraintMultiplierKey, [NSNumber numberWithFloat:x_multi], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)x_multi {
    id multiObj = objc_getAssociatedObject(self, XConstraintMultiplierKey);
    if (!multiObj) {
        self.x_multi = 0.0;
    }
    return multiObj ? [multiObj floatValue] : 0.0;
}

- (void)setX_cons:(CGFloat)x_cons {
    objc_setAssociatedObject(self, XConstraintConstantKey, [NSNumber numberWithFloat:x_cons], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)x_cons {
    id consObj = objc_getAssociatedObject(self, XConstraintConstantKey);
    if (!consObj) {
        self.x_cons = 0.0;
    }
    return consObj ? [consObj floatValue] : 0.0;
}

#pragma mark Method

- (XConstraintMaker *)x_addAttribute:(NSLayoutAttribute)attribute {
    if (self.x_secondItem) {
        [self.x_secondAttributes x_addObject:@(attribute)];
    } else {
        [self.x_firstAttributes x_addObject:@(attribute)];
    }
    return self;
}

- (void)x_relationTo:(id)reference {
    if ([reference isKindOfClass:[UIView class]]) {
        self.x_secondItem = reference;
        self.x_multi = 1.0;
    } else {
        self.x_secondItem = nil;
        self.x_multi = 0.0;
        self.x_cons = [reference floatValue];
    }
    
    if (!self.x_secondItem) {
        [self x_addConstraint];
    }
}

- (void)x_addConstraint {
    if (self.x_firstAttributes && self.x_firstAttributes.count > 0) {
        if (self.translatesAutoresizingMaskIntoConstraints) {
            [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        
        self.x_firstItem = self;
        
        BOOL isSecondNotAttribute = NO;
        if (!self.x_secondItem) {
            isSecondNotAttribute = YES;
        }
        
        for (NSInteger i = 0; i < self.x_firstAttributes.count; i ++) {
            NSLayoutAttribute firstAttribute = [[self.x_firstAttributes x_objectAtIndex:i] integerValue];
            NSLayoutAttribute secondAttribute = NSLayoutAttributeNotAnAttribute;
            
            if (!isSecondNotAttribute) {
                if (self.x_secondAttributes && self.x_secondAttributes.count > 0) {
                    if (i < self.x_secondAttributes.count) {
                        secondAttribute = [[self.x_secondAttributes x_objectAtIndex:i] integerValue];
                    }
                } else {
                    secondAttribute = firstAttribute;
                }
            }
            
            NSLayoutConstraint *constraint =
            [NSLayoutConstraint constraintWithItem:self.x_firstItem attribute:firstAttribute
                                         relatedBy:self.x_relation
                                            toItem:self.x_secondItem attribute:secondAttribute
                                        multiplier:self.x_multi constant:self.x_cons];
            
            if ([XIOSVersion isIOS8OrGreater]) {
                [constraint setActive:YES];
            } else {
                [self.superview addConstraint:constraint];
            }
        }
    }
    
    [self x_clear];
}

- (void)x_removeExistConstraint:(NSLayoutConstraint *)constraint {
    if ([XIOSVersion isIOS8OrGreater]) {
        [constraint setActive:NO];
    } else {
        [self.superview removeConstraint:constraint];
    }
}

- (void)x_clear {
    self.x_firstItem = nil;
    [self.x_firstAttributes removeAllObjects];
    self.x_relation = NSLayoutRelationEqual;
    self.x_secondItem = nil;
    [self.x_secondAttributes removeAllObjects];
    self.x_multi = 0.0;
    self.x_cons = 0.0;
}

@end
