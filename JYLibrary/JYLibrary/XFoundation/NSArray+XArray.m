//
//  NSArray+XArray.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSArray+XArray.h"

@implementation NSArray (XArray)

- (id)x_objectAtIndex:(NSUInteger)index {
#ifdef DEBUG
    return [self objectAtIndex:index];
#else
    if (index != NSNotFound && index >= 0 && index < self.count) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
#endif
}

@end

@implementation NSMutableArray (XMutableArray)

- (void)x_addObject:(id)anObject {
#ifdef DEBUG
        [self addObject:anObject];
#else
    if (anObject) {
        [self addObject:anObject];
    }
#endif
}

- (void)x_removeObjectAtIndex:(NSInteger)index {
#ifdef DEBUG
        [self removeObjectAtIndex:index];
#else
    if (self.count > 0 && index != NSNotFound && index >= 0 && index < self.count) {
        [self removeObjectAtIndex:index];
    }
#endif
}

- (void)x_insertObject:(id)anObject atIndex:(NSInteger)index {
#ifdef DEBUG
    [self insertObject:anObject atIndex:index];
#else
    if (anObject) {
        if (self.count == 0) {
            if (index == 0) {
                [self insertObject:anObject atIndex:index];
            }
        } else if (self.count > 0) {
            if (index != NSNotFound && index >= 0 && index <= self.count) {
                [self insertObject:anObject atIndex:index];
            }
        }
    }
#endif
}

- (void)x_replaceObjectAtIndex:(NSInteger)index withObject:(id)anObject {
#ifdef DEBUG
        [self replaceObjectAtIndex:index withObject:anObject];
#else
    if (anObject) {
        if (self.count > 0 && index != NSNotFound && index >= 0 && index < self.count) {
            [self replaceObjectAtIndex:index withObject:anObject];
        }
    }
#endif
}

@end
