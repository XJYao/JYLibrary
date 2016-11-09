//
//  XGroupTableModel.h
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGroupTableModel : NSObject

@property (nonatomic, assign)   NSInteger       level;          //0, 1, 2, 3....high -> low
@property (nonatomic, assign)   BOOL            nextIsShowing;  //default is NO.
@property (nonatomic, strong)   NSArray     *   nextLevelModels;//default is nil.
@property (nonatomic, copy)     NSString    *   cellClassName;  //default is nil.
@property (nonatomic, assign)   BOOL            allowSelect;    //default is NO.

- (instancetype)initWithLevel:(NSInteger)level
              nextLevelModels:(NSArray *)nextLevelModels
                cellClassName:(NSString *)cellClassName;

@end
