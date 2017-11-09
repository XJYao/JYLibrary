//
//  NSData+XMD5.h
//  Pods
//
//  Created by XJY on 2017/8/8.
//
//

#import <Foundation/Foundation.h>


@interface NSData (XMD5)

+ (NSString *)getFileMD5WithPath:(NSString *)path;

@end
