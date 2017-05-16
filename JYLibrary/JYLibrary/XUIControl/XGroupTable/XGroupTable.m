//
//  XGroupTable.m
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTable.h"
#import "XGroupTableModel.h"
#import "XGroupTableCell.h"
#import "XTool.h"
#import "UITableView+XTableView.h"
#import "XTableView.h"
#import "XConstraint.h"
#import "NSDictionary+XDictionary.h"
#import "NSArray+XArray.h"


@interface XGroupTable () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *groupsDictionary;
    NSMutableDictionary *groupTableCellClassesNameDic;

    GetNextLevelDataBlock getNextLevelDataBlock;

    XGroupTableStyle groupTableStyle;
}

@end


@implementation XGroupTable

#pragma mark---------- Public ----------

- (instancetype)initWithGroups:(NSArray *)groups style:(XGroupTableStyle)style {
    self = [super init];
    if (self) {
        [self initialize:style];
        [self loadGroups:groups];
        [self addGroupsTableView];
    }
    return self;
}

- (instancetype)initWithGroups:(NSArray *)groups {
    return [self initWithGroups:groups style:XGroupTableStyleSingle];
}

- (instancetype)initWithStyle:(XGroupTableStyle)style {
    return [self initWithGroups:nil style:style];
}

- (void)showScrollIndicator:(BOOL)show {
    if (!_tableView) {
        return;
    }

    [_tableView setShowsHorizontalScrollIndicator:show];
    [_tableView setShowsVerticalScrollIndicator:show];
}

#pragma mark reload data

- (void)reloadData:(NSArray *)groups {
    [self loadGroups:groups];
    [self reloadData];
}

- (void)reloadData {
    if (!_tableView) {
        return;
    }

    [self registerCellClass];
    [_tableView reloadData];
}

#pragma mark get data

- (void)getNextLevelData:(GetNextLevelDataBlock)block {
    getNextLevelDataBlock = block;
}

#pragma mark select

- (void)didSelectRowForModel:(id)model {
    if (!model) {
        return;
    }

    NSIndexPath *indexPath = [self indexPathForModel:model];
    if (!indexPath) {
        return;
    }

    [self didSelectRowAtIndexPath:indexPath];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    XGroupTableCell *cell = (XGroupTableCell *)[_tableView cellForRowAtIndexPath:indexPath];
    if (!cell.currentGroupTableModel) {
        return;
    }
    if (_showSelectedBackground) {
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

    if (cell.currentGroupTableModel.nextIsShowing) { //下一级已展开,点击后收起, 从当前点击的行往下查找, 当level比当前行高(即等级更低), 就删除, 一旦遇到等级一样或者更高时, 就退出循环。
        [cell.currentGroupTableModel setNextIsShowing:NO];
        [self closeGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
    } else { //下一级未展开, 点击后展开
        if (groupTableStyle == XGroupTableStyleSingle) {
            [self closeThisGroupOtherSameLevelOrLowerShowingRows:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
        }
        [cell.currentGroupTableModel setNextIsShowing:YES];
        if ([XTool isArrayEmpty:cell.currentGroupTableModel.nextLevelModels]) { //下一级无数据
            NSArray *nextLevelModels = nil;
            if (getNextLevelDataBlock) {
                nextLevelModels = getNextLevelDataBlock(cell.currentGroupTableModel);
            }
            if ([XTool isArrayEmpty:nextLevelModels]) {
                //下一级确实没有数据
            } else {
                //搜索到下一级的数据
                [cell.currentGroupTableModel setNextLevelModels:nextLevelModels];
                [self openGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
            }
        } else { //下一级有数据
            [self openGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
        }
    }
}

#pragma mark insert

- (void)insertRoot:(id)newRootModel atIndex:(NSInteger)atIndex {
    if (!newRootModel) {
        return;
    }

    if (!groupsDictionary) {
        return;
    }

    if (atIndex < 0 || atIndex == NSNotFound || atIndex > groupsDictionary.count) {
        return;
    }
    if (atIndex < groupsDictionary.count) {
        for (NSInteger section = groupsDictionary.count - 1; section >= atIndex; section--) {
            NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
            NSNumber *newSectionNumber = [NSNumber numberWithInteger:section + 1];
            NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
            [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];
        }
    }

    [groupsDictionary x_setObject:@[ newRootModel ] forKey:[NSNumber numberWithInteger:atIndex]];

    [self addCellClassesName:((XGroupTableModel *)newRootModel).cellClassName];
    [self registerCellClass];

    if (_animated) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:atIndex];
        [_tableView beginUpdates];
        [_tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)insertRoot:(id)newRootModel {
    [self insertRoot:newRootModel atIndex:groupsDictionary.count];
}

- (void)insertRoots:(NSArray *)rootModels atIndex:(NSInteger)atIndex {
    if ([XTool isArrayEmpty:rootModels]) {
        return;
    }

    if (!groupsDictionary) {
        return;
    }

    if (atIndex < 0 || atIndex == NSNotFound || atIndex > groupsDictionary.count) {
        return;
    }
    if (atIndex < groupsDictionary.count) {
        for (NSInteger section = groupsDictionary.count - 1; section >= atIndex; section--) {
            NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
            NSNumber *newSectionNumber = [NSNumber numberWithInteger:section + rootModels.count];
            NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
            [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];
        }
    }

    NSInteger insertIndex = atIndex;
    for (id model in rootModels) {
        [groupsDictionary x_setObject:@[ model ] forKey:[NSNumber numberWithInteger:insertIndex]];
        [self addCellClassesName:((XGroupTableModel *)model).cellClassName];
        insertIndex++;
    }

    [self registerCellClass];

    if (_animated) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(atIndex, rootModels.count)];
        [_tableView beginUpdates];
        [_tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)insertRoots:(NSArray *)rootModels {
    [self insertRoots:rootModels atIndex:groupsDictionary.count];
}

- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel atIndex:(NSInteger)atIndex {
    if (newModel && !fatherModel && !rootModel) {
        [self insertRoot:newModel atIndex:atIndex];
        return;
    }

    if (!newModel || !rootModel || !fatherModel) {
        return;
    }

    if (atIndex < 0 || atIndex == NSNotFound) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    NSInteger rootIndex = [self indexForRoot:rootModel];
    if (rootIndex == NSNotFound) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;

    if (atIndex > fatherGroupModel.nextLevelModels.count) {
        return;
    }

    NSMutableArray *fatherModelNextLevelModels = [[NSMutableArray alloc] init];
    if (![XTool isArrayEmpty:fatherGroupModel.nextLevelModels]) {
        [fatherModelNextLevelModels addObjectsFromArray:fatherGroupModel.nextLevelModels];
    }
    [fatherModelNextLevelModels x_insertObject:newModel atIndex:atIndex];
    [fatherGroupModel setNextLevelModels:fatherModelNextLevelModels];

    if (!fatherGroupModel.nextIsShowing) {
        return;
    }

    XGroupTableModel *rootGroupModel = (XGroupTableModel *)rootModel;
    if (!rootGroupModel.nextIsShowing) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:rootIndex];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

    NSInteger fatherIndex = [groupModelForRowArray indexOfObject:fatherGroupModel];
    if (fatherIndex == NSNotFound) {
        return;
    }

    NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] init];
    if (![XTool isArrayEmpty:groupModelForRowArray]) {
        [groupModelForRowMutableArray addObjectsFromArray:groupModelForRowArray];
    }

    XGroupTableModel *newGroupModel = (XGroupTableModel *)newModel;

    if (atIndex == 0) {
        NSInteger insertRow = fatherIndex + 1;
        [groupModelForRowMutableArray x_insertObject:newGroupModel atIndex:insertRow];
        [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertRow inSection:[sectionNumber integerValue]];

        [self addCellClassesName:newGroupModel.cellClassName];
        [self registerCellClass];

        if (_animated) {
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
        } else {
            [_tableView reloadData];
        }

        return;
    }

    NSInteger brothersCount = 0;
    for (NSInteger i = fatherIndex + 1; i < groupModelForRowMutableArray.count; i++) {
        XGroupTableModel *model = [groupModelForRowMutableArray x_objectAtIndex:i];
        if (model.level <= fatherGroupModel.level) {
            return;
        }
        if (model.level == newGroupModel.level) {
            brothersCount++;
            if (atIndex == brothersCount) {
                NSInteger insertRow = NSNotFound;
                for (NSInteger j = i + 1; j < groupModelForRowMutableArray.count; j++) {
                    XGroupTableModel *subModel = [groupModelForRowMutableArray x_objectAtIndex:j];
                    if (subModel.level <= newGroupModel.level) {
                        insertRow = j;
                        break;
                    }
                }
                if (insertRow == NSNotFound) {
                    insertRow = groupModelForRowMutableArray.count;
                }

                if (insertRow < 0 || insertRow > groupModelForRowMutableArray.count) {
                    return;
                }

                [groupModelForRowMutableArray x_insertObject:newGroupModel atIndex:insertRow];
                [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertRow inSection:[sectionNumber integerValue]];

                [self addCellClassesName:newGroupModel.cellClassName];
                [self registerCellClass];

                if (_animated) {
                    [_tableView beginUpdates];
                    [_tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                } else {
                    [_tableView reloadData];
                }

                return;
            }
        }
    }
}

- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (newModel && !fatherModel && !rootModel) {
        [self insertRoot:newModel];
        return;
    }

    if (!newModel || !rootModel || !fatherModel) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;
    NSInteger insertIndex = 0;
    if (![XTool isArrayEmpty:fatherGroupModel.nextLevelModels]) {
        insertIndex = fatherGroupModel.nextLevelModels.count;
    }

    [self insertRowForModel:newModel rootModel:rootModel fatherModel:fatherModel atIndex:insertIndex];
}

#pragma mark remove

- (void)removeRootAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    if (atIndex >= groupsDictionary.count) {
        return;
    }

    if (atIndex == groupsDictionary.count - 1) {
        [groupsDictionary removeObjectForKey:[NSNumber numberWithInteger:atIndex]];
    } else {
        for (NSInteger section = atIndex + 1; section < groupsDictionary.count; section++) {
            NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
            NSNumber *newSectionNumber = [NSNumber numberWithInteger:section - 1];
            NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
            [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];

            if (section == groupsDictionary.count - 1) {
                [groupsDictionary removeObjectForKey:oldSectionNumber];
            }
        }
    }

    if (_animated) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:atIndex];
        [_tableView beginUpdates];
        [_tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)removeRootsAtIndexs:(NSArray *)atIndexs {
    if ([XTool isArrayEmpty:atIndexs]) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    NSMutableArray *newAtIndexs = [[NSMutableArray alloc] init];
    for (NSNumber *atIndexNumber in atIndexs) {
        NSInteger atIndex = [atIndexNumber integerValue];
        if (atIndex == NSNotFound || atIndex < 0 || atIndex >= groupsDictionary.count) {
            continue;
        }

        [newAtIndexs x_addObject:atIndexNumber];
    }

    if ([XTool isArrayEmpty:newAtIndexs]) {
        return;
    }

    for (NSInteger i = newAtIndexs.count - 1; i >= 0; i--) {
        NSInteger atIndex = [[newAtIndexs x_objectAtIndex:i] integerValue];

        if (atIndex == groupsDictionary.count - 1) {
            [groupsDictionary removeObjectForKey:[NSNumber numberWithInteger:atIndex]];
        } else {
            for (NSInteger section = atIndex + 1; section < groupsDictionary.count; section++) {
                NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
                NSNumber *newSectionNumber = [NSNumber numberWithInteger:section - 1];
                NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
                [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];

                if (section == groupsDictionary.count - 1) {
                    [groupsDictionary removeObjectForKey:oldSectionNumber];
                }
            }
        }
    }

    if (_animated) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSNumber *atIndexNumber in newAtIndexs) {
            NSInteger atIndex = [atIndexNumber integerValue];
            [indexSet addIndex:atIndex];
        }

        [_tableView beginUpdates];
        [_tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)removeRoot:(id)rootModel {
    if (!rootModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    NSInteger waitRemoveSection = [self indexForRoot:rootModel];

    if (waitRemoveSection == NSNotFound || waitRemoveSection < 0) {
        return;
    }

    [self removeRootAtIndex:waitRemoveSection];
}

- (void)removeRoots:(NSArray *)rootModels {
    if ([XTool isArrayEmpty:rootModels]) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    NSMutableArray *indexs = [[NSMutableArray alloc] init];
    for (id rootModel in rootModels) {
        NSInteger waitRemoveSection = [self indexForRoot:rootModel];

        if (waitRemoveSection == NSNotFound || waitRemoveSection < 0) {
            continue;
        }

        [indexs x_addObject:[NSNumber numberWithInteger:waitRemoveSection]];
    }

    [self removeRootsAtIndexs:indexs];
}

- (void)removeFirstRoot {
    [self removeRootAtIndex:0];
}

- (void)removeLastRoot {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }
    [self removeRootAtIndex:groupsDictionary.count - 1];
}

- (void)removeRowAtIndex:(NSInteger)atIndex rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }

    if (!rootModel && !fatherModel) {
        [self removeRootAtIndex:atIndex];
        return;
    }

    if (!rootModel || !fatherModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;

    if (atIndex >= fatherGroupModel.nextLevelModels.count) {
        return;
    }

    id removeModel = [fatherGroupModel.nextLevelModels x_objectAtIndex:atIndex];
    [self removeRowForModel:removeModel rootModel:rootModel fatherModel:fatherModel];
}

- (void)removeRowsAtIndexs:(NSArray *)atIndexs rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if ([XTool isArrayEmpty:atIndexs]) {
        return;
    }

    if (!rootModel && !fatherModel) {
        [self removeRootsAtIndexs:atIndexs];
        return;
    }

    if (!rootModel || !fatherModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;

    NSMutableArray *removeModels = [[NSMutableArray alloc] init];

    for (NSNumber *atIndexNumber in atIndexs) {
        NSInteger atIndex = [atIndexNumber integerValue];
        if (atIndex >= fatherGroupModel.nextLevelModels.count) {
            continue;
        }

        id removeModel = [fatherGroupModel.nextLevelModels x_objectAtIndex:atIndex];
        [removeModels x_addObject:removeModel];
    }

    [self removeRowsForModels:removeModels rootModel:rootModel fatherModel:fatherModel];
}

- (void)removeRowForModel:(id)removeModel rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (removeModel && !rootModel && !fatherModel) {
        [self removeRoot:removeModel];
        return;
    }

    if (!removeModel || !rootModel || !fatherModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;

    if ([fatherGroupModel.nextLevelModels containsObject:removeModel]) {
        NSMutableArray *fatherModelNextLevelModels = [[NSMutableArray alloc] init];
        if (![XTool isArrayEmpty:fatherGroupModel.nextLevelModels]) {
            [fatherModelNextLevelModels addObjectsFromArray:fatherGroupModel.nextLevelModels];
        }
        [fatherModelNextLevelModels removeObject:removeModel];
        [fatherGroupModel setNextLevelModels:fatherModelNextLevelModels];
    }

    if (!fatherGroupModel.nextIsShowing) {
        return;
    }

    XGroupTableModel *rootGroupModel = (XGroupTableModel *)rootModel;
    if (!rootGroupModel.nextIsShowing) {
        return;
    }

    NSInteger rootIndex = [self indexForRoot:rootGroupModel];

    if (rootIndex == NSNotFound) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:rootIndex];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

    NSInteger removeModelIndex = [groupModelForRowArray indexOfObject:removeModel];

    if (removeModelIndex == NSNotFound || removeModelIndex < 0) {
        return;
    }

    NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] init];
    if (![XTool isArrayEmpty:groupModelForRowArray]) {
        [groupModelForRowMutableArray addObjectsFromArray:groupModelForRowArray];
    }
    [groupModelForRowMutableArray removeObject:removeModel];
    [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:removeModelIndex inSection:[sectionNumber integerValue]];

    if (_animated) {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)removeRowsForModels:(NSArray *)removeModels rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (![XTool isArrayEmpty:removeModels] && !rootModel && !fatherModel) {
        [self removeRoots:removeModels];
        return;
    }

    if ([XTool isArrayEmpty:removeModels] || !rootModel || !fatherModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;

    NSMutableArray *fatherModelNextLevelModels = [[NSMutableArray alloc] init];
    if (![XTool isArrayEmpty:fatherGroupModel.nextLevelModels]) {
        [fatherModelNextLevelModels addObjectsFromArray:fatherGroupModel.nextLevelModels];
    }
    [fatherModelNextLevelModels removeObjectsInArray:removeModels];
    [fatherGroupModel setNextLevelModels:fatherModelNextLevelModels];

    if (!fatherGroupModel.nextIsShowing) {
        return;
    }

    XGroupTableModel *rootGroupModel = (XGroupTableModel *)rootModel;
    if (!rootGroupModel.nextIsShowing) {
        return;
    }

    NSInteger rootIndex = [self indexForRoot:rootGroupModel];

    if (rootIndex == NSNotFound) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:rootIndex];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

    NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] init];
    if (![XTool isArrayEmpty:groupModelForRowArray]) {
        [groupModelForRowMutableArray addObjectsFromArray:groupModelForRowArray];
    }

    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

    for (id removeModel in removeModels) {
        NSInteger removeModelIndex = [groupModelForRowArray indexOfObject:removeModel];

        if (removeModelIndex == NSNotFound || removeModelIndex < 0) {
            continue;
        }

        [groupModelForRowMutableArray removeObject:removeModel];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:removeModelIndex inSection:[sectionNumber integerValue]];
        [indexPaths x_addObject:indexPath];
    }

    [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];

    if (_animated) {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

#pragma mark reload row

- (void)reloadRootAllRow:(id)rootModel {
    if (!rootModel) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return;
    }

    NSInteger waitReloadSection = [self indexForRoot:rootModel];

    if (waitReloadSection == NSNotFound || waitReloadSection < 0 || waitReloadSection >= groupsDictionary.count) {
        return;
    }

    XGroupTableModel *groupTableModel = (XGroupTableModel *)rootModel;
    if (!groupTableModel.nextIsShowing) {
        return;
    }

    NSMutableArray *newGroupModelForRowArray = [[NSMutableArray alloc] init];
    [newGroupModelForRowArray x_addObject:groupTableModel];
    [self reloadRootRowAndChildrenData:groupTableModel storageArray:newGroupModelForRowArray];
    [groupsDictionary x_setObject:newGroupModelForRowArray forKey:[NSNumber numberWithInteger:waitReloadSection]];

    [self registerCellClass];

    [_tableView reloadData];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    if (_animated) {
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)reloadRowForModel:(id)model {
    if (!model) {
        return;
    }
    NSIndexPath *indexPath = [self indexPathForModel:model];

    if (!indexPath) {
        return;
    }

    [self reloadRowAtIndexPath:indexPath];
}

#pragma mark help

- (id)getCellForIndexPath:(NSIndexPath *)indexPath {
    if (!_tableView || !indexPath) {
        return nil;
    }

    id cell = [_tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (id)getCellForModel:(id)model {
    return [self getCellForIndexPath:[self indexPathForModel:model]];
}

- (id)getModelAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == NSNotFound || section < 0 || section >= groupsDictionary.count ||
        row == NSNotFound || row < 0) {
        return nil;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:section];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return nil;
    }

    if (row >= groupModelForRowArray.count) {
        return nil;
    }

    return [groupModelForRowArray x_objectAtIndex:row];
}

- (NSIndexPath *)indexPathForModel:(id)model {
    if (!model) {
        return nil;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSIndexPath *indexPath = nil;

    for (NSNumber *sectionNumber in groupsDictionary.allKeys) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
        if (![XTool isArrayEmpty:groupModelForRowArray]) {
            NSInteger row = [groupModelForRowArray indexOfObject:model];
            if (row != NSNotFound) {
                NSInteger section = [sectionNumber integerValue];
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                return indexPath;
            }
        }
    }

    return indexPath;
}

- (NSArray *)getFullGroupItemsForIndexPath:(NSIndexPath *)indexPath {
    id model = [self getModelAtIndexPath:indexPath];
    return [self getFullGroupItems:model];
}

- (NSArray *)getFullGroupItems:(id)model {
    NSIndexPath *indexPath = [self indexPathForModel:model];
    return [self getFullGroupItems:model atIndexPath:indexPath];
}

- (NSArray *)getFullGroupItems:(id)model atIndexPath:(NSIndexPath *)indexPath {
    if (!model || !indexPath) {
        return nil;
    }

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    [itemsArray x_addObject:model];

    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    NSInteger fatherLevel = ((XGroupTableModel *)model).level;

    for (NSInteger i = indexPath.row - 1; i >= 0; i--) {
        XGroupTableModel *groupTableModel = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:i];
        if (groupTableModel.level < fatherLevel) {
            fatherLevel = groupTableModel.level;
            [itemsArray x_insertObject:groupTableModel atIndex:0];
        }
        if (groupTableModel.level == 0) {
            break;
        }
    }

    return itemsArray;
}

- (NSInteger)indexForRoot:(id)rootModel {
    if (!rootModel || [XTool isDictionaryEmpty:groupsDictionary]) {
        return NSNotFound;
    }

    NSInteger rootIndex = NSNotFound;
    for (NSString *sectionNumber in groupsDictionary.allKeys) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
        if (![XTool isArrayEmpty:groupModelForRowArray]) {
            id firstModel = [groupModelForRowArray x_objectAtIndex:0];
            if (rootModel == firstModel) {
                rootIndex = [sectionNumber integerValue];
                return rootIndex;
            }
        }
    }

    return NSNotFound;
}

- (NSInteger)numberOfRoot {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return 0;
    }

    return groupsDictionary.count;
}

- (id)getRootModelAtIndex:(NSInteger)atIndex {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    if (atIndex < 0 || atIndex == NSNotFound || atIndex >= groupsDictionary.count) {
        return nil;
    }

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:atIndex]];
    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return nil;
    }

    return [groupModelForRowArray x_objectAtIndex:0];
}

- (NSArray *)getRootModels {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSMutableArray *rootModels = [[NSMutableArray alloc] init];
    NSInteger rootsCount = groupsDictionary.count;
    for (NSInteger section = 0; section < rootsCount; section++) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
        if (![XTool isArrayEmpty:groupModelForRowArray]) {
            [rootModels x_addObject:[groupModelForRowArray x_objectAtIndex:0]];
        }
    }
    return rootModels;
}

- (NSArray *)getRootCells {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSMutableArray *rootCells = [[NSMutableArray alloc] init];
    NSInteger rootsCount = groupsDictionary.count;
    for (NSInteger section = 0; section < rootsCount; section++) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
        if (![XTool isArrayEmpty:groupModelForRowArray]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            id cell = [_tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                [rootCells x_addObject:cell];
            }
        }
    }
    return rootCells;
}

#pragma mark---------- Private ----------

#pragma mark init

- (void)initialize:(XGroupTableStyle)style {
    [self setBackgroundColor:[UIColor clearColor]];

    getNextLevelDataBlock = nil;
    groupsDictionary = [[NSMutableDictionary alloc] init];
    groupTableCellClassesNameDic = [[NSMutableDictionary alloc] init];

    _animated = YES;
    _showSelectedBackground = NO;
    _separatorStyle = UITableViewCellSeparatorStyleNone;
    groupTableStyle = style;
}

- (void)loadGroups:(NSArray *)groups {
    if (groupsDictionary) {
        [groupsDictionary removeAllObjects];
    } else {
        groupsDictionary = [[NSMutableDictionary alloc] init];
    }

    if (groupTableCellClassesNameDic) {
        [groupTableCellClassesNameDic removeAllObjects];
    } else {
        groupTableCellClassesNameDic = [[NSMutableDictionary alloc] init];
    }

    NSInteger section = 0;
    for (XGroupTableModel *model in groups) {
        NSMutableArray *groupModelForRowArray = [[NSMutableArray alloc] init];
        [groupModelForRowArray x_addObject:model];
        [groupsDictionary x_setObject:groupModelForRowArray forKey:[NSNumber numberWithInteger:section]];

        [self addCellClassesName:model.cellClassName];
        section++;
    }
}

- (void)addGroupsTableView {
    _tableView = [[XTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:_separatorStyle];
    [_tableView setNoDelaysContentTouches];
    [_tableView clearRemainSeparators];
    [self showScrollIndicator:NO];
    [self registerCellClass];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self addSubview:_tableView];

    _tableView.x_edge.x_equalTo(self).x_edge.x_multiplier(1.0).x_constant(0.0);
}

#pragma mark property

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    if (!_tableView) {
        return;
    }
    [_tableView setSeparatorStyle:_separatorStyle];
}

#pragma mark method

- (void)addCellClassesName:(NSString *)cellClassName {
    if (![groupTableCellClassesNameDic.allKeys containsObject:cellClassName]) {
        [groupTableCellClassesNameDic x_setObject:[NSNumber numberWithBool:NO] forKey:cellClassName];
    }
}

- (void)registerCellClass {
    if (!_tableView) {
        return;
    }

    if ([XTool isDictionaryEmpty:groupTableCellClassesNameDic]) {
        return;
    }

    for (NSString *cellClassName in groupTableCellClassesNameDic.allKeys) {
        BOOL isRegistered = [[groupTableCellClassesNameDic objectForKey:cellClassName] boolValue];
        if (!isRegistered) {
            [_tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:cellClassName];
            [groupTableCellClassesNameDic x_setObject:[NSNumber numberWithBool:YES] forKey:cellClassName];
        }
    }
}

- (void)openGroupWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (!tableView || !indexPath || !currentGroupModel) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];

    NSMutableArray *groupModelForRowArray = [[NSMutableArray alloc] init];
    NSArray *tempGroupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    if (![XTool isArrayEmpty:tempGroupModelForRowArray]) {
        [groupModelForRowArray addObjectsFromArray:tempGroupModelForRowArray];
    }

    NSInteger currentRow = [groupModelForRowArray indexOfObject:currentGroupModel];
    NSIndexSet *indexSets = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(currentRow + 1, currentGroupModel.nextLevelModels.count)];

    [groupModelForRowArray insertObjects:currentGroupModel.nextLevelModels atIndexes:indexSets];
    [groupsDictionary x_setObject:groupModelForRowArray forKey:sectionNumber];

    NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentGroupModel.nextLevelModels.count; i++) {
        XGroupTableModel *groupTableModel = [currentGroupModel.nextLevelModels x_objectAtIndex:i];
        [self addCellClassesName:groupTableModel.cellClassName];
        [self registerCellClass];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:currentRow + 1 + i inSection:indexPath.section];
        [indexPathsArray x_addObject:insertIndexPath];
    }

    if (_animated) {
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else {
        [tableView reloadData];
    }

    if (currentGroupModel.level == 0) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:_animated];
    } else {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:_animated];
    }
}

- (void)closeGroupWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (!tableView || !indexPath || !currentGroupModel) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

    NSMutableArray *waitDeleteModelArray = [[NSMutableArray alloc] init];
    NSMutableArray *waitDeleteIndexPathsArray = [[NSMutableArray alloc] init];

    for (NSInteger i = (indexPath.row + 1); i < groupModelForRowArray.count; i++) {
        XGroupTableModel *model = [groupModelForRowArray x_objectAtIndex:i];
        if (model.level > currentGroupModel.level) {
            [model setNextIsShowing:NO];
            [waitDeleteModelArray x_addObject:model];
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            [waitDeleteIndexPathsArray x_addObject:deleteIndexPath];
        } else {
            break;
        }
    }
    if (![XTool isArrayEmpty:waitDeleteModelArray]) {
        NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] init];
        if (![XTool isArrayEmpty:groupModelForRowArray]) {
            [groupModelForRowMutableArray addObjectsFromArray:groupModelForRowArray];
        }
        [groupModelForRowMutableArray removeObjectsInArray:waitDeleteModelArray];
        [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
    }

    if (_animated) {
        if (![XTool isArrayEmpty:waitDeleteIndexPathsArray]) {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:waitDeleteIndexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    } else {
        [tableView reloadData];
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath withCurrentGroupModel:(XGroupTableModel *)currentGroupModel {
    if (!indexPath || !currentGroupModel) {
        return;
    }

    if (!currentGroupModel.allowSelect) {
        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(selectedRow:atIndexPath:model:)]) {
        [_delegate selectedRow:_tableView atIndexPath:indexPath model:currentGroupModel];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(fullGroupItemsForSelectedRow:atIndexPath:items:)]) {
        NSArray *itemsArray = [self getFullGroupItems:currentGroupModel atIndexPath:indexPath];
        [_delegate fullGroupItemsForSelectedRow:_tableView atIndexPath:indexPath items:itemsArray];
    }
}

- (void)closeThisGroupOtherSameLevelOrLowerShowingRows:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (!tableView || !indexPath || !currentGroupModel) {
        return;
    }

    NSMutableArray *waitDeleteIndexPathsArray = [[NSMutableArray alloc] init];
    NSMutableArray *shouldReloadRowIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *shouldReloadRowModels = [[NSMutableArray alloc] init];

    if (currentGroupModel.level == 0) {
        for (NSNumber *sectionNumber in groupsDictionary.allKeys) {
            NSInteger section = [sectionNumber integerValue];
            if (section != indexPath.section) {
                NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
                for (NSInteger row = 0; row < groupModelForRowArray.count; row++) {
                    XGroupTableModel *model = [groupModelForRowArray x_objectAtIndex:row];
                    if (model.nextIsShowing) {
                        [model setNextIsShowing:NO];

                        if (row == 0) {
                            NSIndexPath *shouldReloadRowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            [shouldReloadRowIndexPaths x_addObject:shouldReloadRowIndexPath];
                            [shouldReloadRowModels x_addObject:model];
                        }
                    }

                    if (row != 0) {
                        NSIndexPath *waitDeleteIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        [waitDeleteIndexPathsArray x_addObject:waitDeleteIndexPath];
                    }
                }
                if (groupModelForRowArray.count > 1) {
                    NSMutableArray *newGroupModelForRowArray = [[NSMutableArray alloc] init];
                    [newGroupModelForRowArray x_addObject:[groupModelForRowArray x_objectAtIndex:0]];
                    [groupsDictionary x_setObject:newGroupModelForRowArray forKey:sectionNumber];
                }
            }
        }


    } else {
        NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];

        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];

        NSMutableArray *waitDeleteModelArray = [[NSMutableArray alloc] init];

        for (NSInteger row = 0; row < groupModelForRowArray.count; row++) {
            XGroupTableModel *model = [groupModelForRowArray x_objectAtIndex:row];
            if (model.level == currentGroupModel.level) {
                if (model != currentGroupModel && model.nextIsShowing) {
                    [model setNextIsShowing:NO];
                    NSIndexPath *shouldReloadRowIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
                    [shouldReloadRowIndexPaths x_addObject:shouldReloadRowIndexPath];
                    [shouldReloadRowModels x_addObject:model];
                }
            } else if (model.level > currentGroupModel.level) {
                [model setNextIsShowing:NO];
                [waitDeleteModelArray x_addObject:model];

                NSIndexPath *waitDeleteIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
                [waitDeleteIndexPathsArray x_addObject:waitDeleteIndexPath];
            }
        }

        if (![XTool isArrayEmpty:waitDeleteModelArray]) {
            NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] init];
            if (![XTool isArrayEmpty:groupModelForRowArray]) {
                [groupModelForRowMutableArray addObjectsFromArray:groupModelForRowArray];
            }
            [groupModelForRowMutableArray removeObjectsInArray:waitDeleteModelArray];
            [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
        }
    }

    if (![XTool isArrayEmpty:shouldReloadRowIndexPaths] &&
        ![XTool isArrayEmpty:shouldReloadRowModels] &&
        shouldReloadRowIndexPaths.count == shouldReloadRowModels.count) {
        if (_delegate && [_delegate respondsToSelector:@selector(shouldUpdateRow:atIndexPath:model:)]) {
            for (NSInteger i = 0; i < shouldReloadRowIndexPaths.count; i++) {
                NSIndexPath *shouldReloadRowIndexPath = [shouldReloadRowIndexPaths x_objectAtIndex:i];
                id shouldReloadRowModel = [shouldReloadRowModels x_objectAtIndex:i];
                [_delegate shouldUpdateRow:tableView atIndexPath:shouldReloadRowIndexPath model:shouldReloadRowModel];
            }
        }
    }

    if (![XTool isArrayEmpty:waitDeleteIndexPathsArray]) {
        if (_animated) {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:waitDeleteIndexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        } else {
            [tableView reloadData];
        }
    }
}

- (void)reloadRootRowAndChildrenData:(XGroupTableModel *)model storageArray:(NSMutableArray *)storageArray {
    if (!model) {
        return;
    }

    [self addCellClassesName:model.cellClassName];

    if ([XTool isArrayEmpty:model.nextLevelModels]) {
        return;
    }

    for (XGroupTableModel *subModel in model.nextLevelModels) {
        if (subModel.nextIsShowing) {
            [self reloadRootRowAndChildrenData:subModel storageArray:storageArray];
        } else {
            [self addCellClassesName:subModel.cellClassName];
            [storageArray x_addObject:subModel];
        }
    }
}

#pragma mark TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionsCount = 0;

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return sectionsCount;
    }

    sectionsCount = groupsDictionary.count;

    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount = 0;

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return rowsCount;
    }

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return rowsCount;
    }

    rowsCount = groupModelForRowArray.count;

    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XGroupTableCell *cell = nil;

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return cell;
    }

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return cell;
    }

    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (!model) {
        return cell;
    }

    if ([XTool isStringEmpty:model.cellClassName]) {
        return cell;
    }

    cell = (XGroupTableCell *)[tableView dequeueReusableCellWithIdentifier:model.cellClassName forIndexPath:indexPath];
    if (!cell) {
        cell = [[XGroupTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.cellClassName];
    }
    [cell setDelegate:_delegate];
    [cell addModel:model];

    return cell;
}

#pragma mark TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 0;

    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return rowHeight;
    }

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return rowHeight;
    }

    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (!model) {
        return rowHeight;
    }

    if ([XTool isStringEmpty:model.cellClassName]) {
        return rowHeight;
    }

    rowHeight = [NSClassFromString(model.cellClassName) getCellHeight:model width:tableView.frame.size.width];

    return rowHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([XTool isDictionaryEmpty:groupsDictionary]) {
        return nil;
    }

    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray]) {
        return nil;
    }

    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (!model) {
        return nil;
    }

    if (model.allowSelect) {
        return indexPath;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_showSelectedBackground) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    XGroupTableCell *cell = (XGroupTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self selectRowAtIndexPath:indexPath withCurrentGroupModel:cell.currentGroupTableModel];
}

@end
