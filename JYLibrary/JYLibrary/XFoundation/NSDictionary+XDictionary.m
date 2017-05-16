//
//  NSDictionary+XDictionary.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSDictionary+XDictionary.h"


@implementation NSDictionary (XDictionary)

+ (NSData *)dataWithDictionary:(NSDictionary *)dict {
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:NULL];
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
}

- (NSData *)toData {
    return [NSDictionary dataWithDictionary:self];
}

@end


@implementation NSMutableDictionary (XMutableDictionary)

- (void)x_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
#ifdef DEBUG
    [self setObject:anObject forKey:aKey];
#else
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
#endif
}

@end
