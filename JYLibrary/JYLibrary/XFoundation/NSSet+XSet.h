//
//  NSSet+XSet.h
//  JYLibrary
//
//  Created by XJY on 16/5/10.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSSet (XSet)

@end


@interface NSMutableSet (XMutableSet)

- (void)x_addObject:(id)object;

- (void)x_removeObject:(id)object;

@end


@interface NSCountedSet (XCountedSet)

- (void)x_addObject:(id)object;

- (void)x_removeObject:(id)object;

@end
