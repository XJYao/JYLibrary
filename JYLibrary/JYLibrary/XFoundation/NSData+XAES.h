//
//  NSData+XAES.h
//  JYLibrary
//
//  Created by XJY on 16/8/4.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (XAES)

- (NSData *)AES256EncryptWithKey:(NSString *)key;

- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
