//
//  NSDictionary+XDictionary.h
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (XDictionary)

+ (NSData *)dataWithDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryWithData:(NSData *)data;

- (NSData *)toData;

@end


@interface NSMutableDictionary (XMutableDictionary)

- (void)x_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
