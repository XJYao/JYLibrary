//
//  NSSet+XSet.m
//  JYLibrary
//
//  Created by XJY on 16/5/10.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSSet+XSet.h"


@implementation NSSet (XSet)

@end


@implementation NSMutableSet (XMutableSet)

- (void)x_addObject:(id)object {
#ifdef DEBUG
    [self addObject:object];
#else
    if (object) {
        [self addObject:object];
    }
#endif
}

- (void)x_removeObject:(id)object {
#ifdef DEBUG
    [self removeObject:object];
#else
    if (object) {
        [self removeObject:object];
    }
#endif
}

@end


@implementation NSCountedSet (XCountedSet)

- (void)x_addObject:(id)object {
#ifdef DEBUG
    [self addObject:object];
#else
    if (object) {
        [self addObject:object];
    }
#endif
}

- (void)x_removeObject:(id)object {
#ifdef DEBUG
    [self removeObject:object];
#else
    if (object) {
        [self removeObject:object];
    }
#endif
}

@end
