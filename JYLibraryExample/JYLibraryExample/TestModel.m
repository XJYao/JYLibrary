//
//  TestModel.m
//  JYLibraryExample
//
//  Created by XJY on 16/10/11.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

- (NSDictionary *)XModelParserModelPropertyNameMapper {
    return @{@"cUInt" : @"democUInt"};
}

- (NSDictionary *)XModelParserModelPropertyContainerClassMapper {
    return @{@"subTestModelArr" : @"SubTestModel",
             @"mutableSet" : @"SubTestModel"};
}

- (BOOL)XModelParserModelPropertyCustomTransform:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"cInteger"]) {
        self.cInteger = 9999;
        return YES;
    }
    return NO;
}

@end

@implementation SubTestModel



@end
