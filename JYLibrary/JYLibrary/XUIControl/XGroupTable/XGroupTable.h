//
//  XGroupTable.h
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XGroupTableStyle) {
    XGroupTableStyleSingle  =   0,  // default, 展开的同时收起其他已展开的同级列表
    XGroupTableStyleMulti           // 展开时不收起其他列表
};

@protocol XGroupTableDelegate <NSObject>

@optional

// 点击某行时回调, 可取得当前点击行的indexPath和model
- (void)selectedRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath model:(id)model;

// 当前选择项以及往上一级一级搜索, 一直到根为止, 获取整个分组路径
- (void)fullGroupItemsForSelectedRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath items:(NSArray *)items;

// 当收起其他已展开的同级列表时，可对需要收起的行进行更新处理
- (void)shouldUpdateRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath model:(id)model;

@end

@interface XGroupTable : UIView

#pragma mark ---------- property ----------

typedef NSArray * (^GetNextLevelDataBlock)(id model);//用于获取下一级数据的block

@property (nonatomic, strong, readonly) UITableView    *   tableView;

@property (nonatomic, weak) id <XGroupTableDelegate> delegate;

@property (nonatomic, assign)   BOOL  animated; //default is YES. 如果为YES, 则有动画效果, 所有操作都是只针对需要修改的行或者根分组,效率更高. 如果为NO, 则是调用reloadData, 整个tableview刷新, 效率低.

@property (nonatomic, assign)   UITableViewCellSeparatorStyle separatorStyle;//分割线样式

@property (nonatomic, assign) BOOL showSelectedBackground;//显示cell选中背景，默认为NO

#pragma mark ---------- method ----------

#pragma mark init

- (instancetype)initWithGroups:(NSArray *)groups style:(XGroupTableStyle)style;

- (instancetype)initWithGroups:(NSArray *)groups;

- (instancetype)initWithStyle:(XGroupTableStyle)style;

- (void)showScrollIndicator:(BOOL)show; //default is NO.

#pragma mark get data

- (void)reloadData:(NSArray *)groups;

- (void)reloadData;

- (void)getNextLevelData:(GetNextLevelDataBlock)block;

#pragma mark select

- (void)didSelectRowForModel:(id)model;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark insert

- (void)insertRoot:(id)newRootModel atIndex:(NSInteger)atIndex;

- (void)insertRoots:(NSArray *)rootModels atIndex:(NSInteger)atIndex;

//紧跟在最后一个根分组插入
- (void)insertRoot:(id)newRootModel;

- (void)insertRoots:(NSArray *)rootModels;

//插入行, 需要传入根model和上级model, 如果二者都为空, 则为插入根分组.
- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel atIndex:(NSInteger)atIndex;

- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel;

#pragma mark remove

- (void)removeRootAtIndex:(NSInteger)atIndex;

- (void)removeRootsAtIndexs:(NSArray *)atIndexs;

- (void)removeRoot:(id)rootModel;

- (void)removeRoots:(NSArray *)rootModels;

- (void)removeFirstRoot;

- (void)removeLastRoot;

//删除行, 需要传入根model和上级model, 如果二者都为空, 则执行删除根分组.
- (void)removeRowAtIndex:(NSInteger)atIndex rootModel:(id)rootModel fatherModel:(id)fatherModel;

- (void)removeRowForModel:(id)removeModel rootModel:(id)rootModel fatherModel:(id)fatherModel;

- (void)removeRowsAtIndexs:(NSArray *)atIndexs rootModel:(id)rootModel fatherModel:(id)fatherModel;

- (void)removeRowsForModels:(NSArray *)removeModels rootModel:(id)rootModel fatherModel:(id)fatherModel;

#pragma mark reload

- (void)reloadRootAllRow:(id)rootModel;

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadRowForModel:(id)model;

#pragma mark help

- (id)getCellForIndexPath:(NSIndexPath *)indexPath;

- (id)getCellForModel:(id)model;

- (id)getModelAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForModel:(id)model;

- (NSArray *)getFullGroupItemsForIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)getFullGroupItems:(id)model;

- (NSArray *)getFullGroupItems:(id)model atIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)indexForRoot:(id)rootModel;

- (NSInteger)numberOfRoot;

- (id)getRootModelAtIndex:(NSInteger)atIndex;

- (NSArray *)getRootModels;

- (NSArray *)getRootCells;

@end
