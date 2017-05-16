//
//  NSArray+XArray.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (XArray)

- (id)x_objectAtIndex:(NSUInteger)index;

@end


@interface NSMutableArray (XMutableArray)

- (void)x_addObject:(id)anObject;

- (void)x_removeObjectAtIndex:(NSInteger)index;

- (void)x_insertObject:(id)anObject atIndex:(NSInteger)index;

- (void)x_replaceObjectAtIndex:(NSInteger)index withObject:(id)anObject;

@end
