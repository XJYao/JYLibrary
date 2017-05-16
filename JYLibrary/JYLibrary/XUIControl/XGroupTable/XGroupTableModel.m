//
//  XGroupTableModel.m
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTableModel.h"


@implementation XGroupTableModel

- (instancetype)init {
    return [self initWithLevel:0
               nextLevelModels:nil
                 cellClassName:@""];
}

- (instancetype)initWithLevel:(NSInteger)level
              nextLevelModels:(NSArray *)nextLevelModels
                cellClassName:(NSString *)cellClassName {
    self = [super init];
    if (self) {
        _level = level;
        _nextIsShowing = NO;
        _nextLevelModels = nextLevelModels;
        _cellClassName = cellClassName;
        _allowSelect = NO;
    }
    return self;
}

@end
