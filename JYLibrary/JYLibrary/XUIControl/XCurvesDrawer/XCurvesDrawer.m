//
//  XCurvesDrawer.m
//  XCurvesDrawer
//
//  Created by XJY on 16/5/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XCurvesDrawer.h"
#import "XCurveInfo.h"
#import "NSArray+XArray.h"

@interface XCurvesDrawer () {
    NSMutableArray<XCurveInfo *> *currentCurves;        //所有曲线
    NSMutableArray<XCurveInfo *> *currentSelectedCurves;//被选中的曲线
    
    NSMutableArray *actions;        //所有动作的集合
    NSInteger currentActionIndex;   //当前是第几个动作
    
    UIPanGestureRecognizer *drawerRecognizer;
    UITapGestureRecognizer *selectCurvesRecognizer;
    
    NSArray<XCurveInfo *> *initialCurves;
    CGSize normalSize;
}

@end

@implementation XCurvesDrawer

#define actionKey       @"actionKey"
#define actionValue     @"actionValue"

#define actionReplaceTarget @"replaceTarget"
#define actionReplaceReplacement @"replaceReplacement"

typedef NS_ENUM(NSUInteger, XCurvesDrawerAction) {
    XCurvesDrawerActionAdd = 0,
    XCurvesDrawerActionRemove,
    XCurvesDrawerActionReplace
};

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        currentCurves = [NSMutableArray arrayWithCapacity:0];
        currentSelectedCurves = [NSMutableArray arrayWithCapacity:0];
        actions = [NSMutableArray arrayWithCapacity:0];
        currentActionIndex = -1;
        initialCurves = nil;
        normalSize = CGSizeZero;
        
        _user = nil;
        _drawerColor = [UIColor blackColor];
        _drawerWidth = 1.0f;
        _drawerEnabled = YES;
        _curvesSelectionEnabled = NO;
        
        [self createDrawerRecognizer];
        [self addGestureRecognizer:drawerRecognizer];
    }
    
    return self;
}

/**
 初始化时传入初始曲线
 */
- (instancetype)initWithCurves:(NSArray<XCurveInfo *> *)curves {
    self = [self init];
    
    if (self) {
        initialCurves = curves;
        if (curves && curves.count > 0) {
            [currentCurves addObjectsFromArray:curves];
        }
    }
    
    return self;
}

/**
 添加曲线
 */
- (void)addCurve:(XCurveInfo *)aCurve {
    if (!aCurve) {
        return;
    }
    
    if ([currentCurves containsObject:aCurve]) {
        return;
    }
    
    [currentCurves x_addObject:aCurve];
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionAdd), actionValue : @[aCurve]}];
    
    [self draw];
}

/**
 添加多条曲线
*/
- (void)addCurvesFromArray:(NSArray<XCurveInfo *> *)curves {
    if (!curves || curves.count == 0) {
        return;
    }
    
    NSMutableArray *willAddCurves = [NSMutableArray arrayWithCapacity:0];
    
    for (XCurveInfo *aCurve in curves) {
        if ([currentCurves containsObject:aCurve]) {
            continue;
        }
        
        [willAddCurves x_addObject:aCurve];
    }
    
    if (willAddCurves.count == 0) {
        return;
    }
    
    [currentCurves addObjectsFromArray:willAddCurves];
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionAdd), actionValue : curves}];
    
    [self draw];
}

/**
 替换曲线
*/
- (BOOL)replaceCurve:(XCurveInfo *)target withCurve:(XCurveInfo *)replacement {
    if (!target) {
        if (replacement) {
            [self addCurve:replacement];
            return YES;
        }
        return NO;
    }
    
    [self cancelSelectedCurve:target];
    
    if (!target.allowModify) {
        return NO;
    }
    
    if (![currentCurves containsObject:target]) {
        return NO;
    }
    
    if (!replacement) {
        [self removeCurve:target];
        return YES;
    }
    
    if (target == replacement) {
        return NO;
    }
    
    return [self replaceCurves:@[target] withCurves:@[replacement]];
}

/**
 替换多条曲线
*/
- (BOOL)replaceCurves:(NSArray<XCurveInfo *> *)targets withCurves:(NSArray<XCurveInfo *> *)replacements {
    
    BOOL isReplacementsEmpty = !(replacements && replacements.count > 0);
    
    if (!targets || targets.count == 0) {
        if (!isReplacementsEmpty) {
            [self addCurvesFromArray:replacements];
            return YES;
        }
        return NO;
    }
    
    NSMutableArray *newTargets = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *newReplacements = nil;
    if (isReplacementsEmpty) {
        newReplacements = [NSMutableArray arrayWithCapacity:0];
    } else {
        newReplacements = [replacements mutableCopy];
    }
    
    for (XCurveInfo *aCurve in targets) {
        [self cancelSelectedCurve:aCurve];
        
        BOOL isSameCurve = NO;
        for (XCurveInfo *replacement in newReplacements) {
            if ([aCurve isEqualTo:replacement]) {
                [newReplacements removeObject:replacement];
                isSameCurve = YES;
                break;
            }
        }
        
        if (isSameCurve) {
            continue;
        }
        
        if ([currentCurves containsObject:aCurve] && aCurve.allowModify) {
            [newTargets x_addObject:aCurve];
        }
    }
    
    if (newTargets.count == 0) {
        if (newReplacements.count > 0) {
            [self addCurvesFromArray:newReplacements];
            return YES;
        }
        return NO;
    }
    
    if (newReplacements.count == 0) {
        [self removeCurves:newTargets];
        return YES;
    }
    
    [currentCurves removeObjectsInArray:newTargets];
    [currentCurves addObjectsFromArray:newReplacements];
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionReplace), actionValue : @{actionReplaceTarget : newTargets, actionReplaceReplacement : newReplacements}}];
    
    [self draw];
    
    return YES;
}

//替换所有的曲线
- (BOOL)replaceAllCurves:(NSArray<XCurveInfo *> *)replacements {
    return [self replaceCurves:currentCurves withCurves:replacements];
}

//检测是否能继续撤销
- (BOOL)checkCanUndo {
    if (actions.count == 0 || currentActionIndex < 0) {
        return NO;
    }
    
    return YES;
}

//检查是否能继续恢复
- (BOOL)checkCanRecovery {
    NSInteger actionsCount = actions.count;
    if (actionsCount == 0 || currentActionIndex >= actionsCount - 1) {
        return NO;
    }
    
    return YES;
}

//撤销
- (BOOL)undo {
    BOOL canUndo = [self checkCanUndo];
    
    if (canUndo) {
        return [self undoOrRecovery:YES];
    }
    
    return canUndo;
}

//恢复
- (BOOL)recovery {
    BOOL canRecovery = [self checkCanRecovery];
    
    if (canRecovery) {
        return [self undoOrRecovery:NO];
    }
    
    return canRecovery;
}

//生成图片
- (UIImage *)generateImage {
    BOOL hidden = self.isHidden;
    if (hidden) {
        [self setHidden:NO];
    }
    
    CGSize size = self.bounds.size;
    UIScreen *mainScreen = [UIScreen mainScreen];
    if ([mainScreen respondsToSelector:@selector(scale)]) {
        CGFloat scale = mainScreen.scale;
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (hidden) {
        [self setHidden:YES];
    }
    
    return image;
}

//清空曲线，除了不允许修改的曲线
- (void)clearAllCurves {
    if (currentCurves.count == 0) {
        return;
    }
    
    NSMutableArray *willRemoveCurves = [NSMutableArray arrayWithCapacity:0];
    for (XCurveInfo *aCurve in currentCurves) {
        if (!aCurve.allowModify) {
            continue;
        }
        [willRemoveCurves x_addObject:aCurve];
    }
    
    if (willRemoveCurves.count == 0) {
        return;
    }
    
    [currentCurves removeObjectsInArray:willRemoveCurves];
    [self addAction:@{actionKey : @(XCurvesDrawerActionRemove), actionValue : willRemoveCurves}];
    
    [self draw];
}

//清空画布，包括不允许修改的曲线
- (void)clearCanvas {
    if (currentCurves.count == 0) {
        return;
    }
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionRemove), actionValue : [currentCurves copy]}];
    [currentCurves removeAllObjects];
    
    [self draw];
}

//删除指定曲线
- (BOOL)removeCurve:(XCurveInfo *)aCurve {
    if (!aCurve) {
        return NO;
    }
    
    [self cancelSelectedCurve:aCurve];
    
    if (!aCurve.allowModify) {
        return NO;
    }
    
    if (![currentCurves containsObject:aCurve]) {
        return NO;
    }
    
    [currentCurves removeObject:aCurve];
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionRemove), actionValue : @[aCurve]}];
    
    [self draw];
    
    return YES;
}

//删除指定多条曲线
- (BOOL)removeCurves:(NSArray<XCurveInfo *> *)curves {
    if (!curves || curves.count == 0) {
        return NO;
    }
    
    NSArray<XCurveInfo *> *copyCurves = [curves copy];
    
    NSMutableArray *willRemoveCurves = [NSMutableArray arrayWithCapacity:0];
    
    for (XCurveInfo *aCurve in copyCurves) {
        [self cancelSelectedCurve:aCurve];
        if (!aCurve.allowModify) {
            continue;
        }
        [willRemoveCurves x_addObject:aCurve];
        if ([currentCurves containsObject:aCurve]) {
            [currentCurves removeObject:aCurve];
        }
    }
    
    if (willRemoveCurves.count == 0) {
        return NO;
    }
    
    [self addAction:@{actionKey : @(XCurvesDrawerActionRemove), actionValue : willRemoveCurves}];
    
    [self draw];
    
    return YES;
}

//取消选中
- (BOOL)cancelSelectedCurve:(XCurveInfo *)aCurve {
    if (!aCurve) {
        return NO;
    }
    if ([currentSelectedCurves containsObject:aCurve]) {
        [currentSelectedCurves removeObject:aCurve];
        
        return YES;
    }
    
    return NO;
}

- (void)cancelSelectedCurves {
    [currentSelectedCurves removeAllObjects];
}

- (void)draw {
    [self setNeedsDisplay];
}

//根据两点计算矩形区域
- (CGRect)rectForFirstPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint offset:(CGFloat)offset {
    CGFloat x = MIN(firstPoint.x, secondPoint.x) - offset / 2.0;
    if (x < 0) {
        x = 0;
    }
    
    CGFloat y = MIN(firstPoint.y, secondPoint.y) - offset / 2.0;
    if (y < 0) {
        y = 0;
    }
    
    CGFloat width = firstPoint.x - secondPoint.x;
    if (width < 0) {
        width = -width;
    }
    width += offset;
    
    CGFloat height = firstPoint.y - secondPoint.y;
    if (height < 0) {
        height = -height;
    }
    height += offset;
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    return rect;
}

#pragma - mark Private

NSDate *getCurrentDate(void) {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [dateformatter dateFromString:[dateformatter stringFromDate:date]];
    return currentDate;
}

CGSize fitPageToNormalSize(CGSize page, CGSize screen) {
    float hscale = screen.width / page.width;
    float vscale = screen.height / page.height;
    float scale = MIN(hscale, vscale);
    hscale = floorf(page.width * scale) / page.width;
    vscale = floorf(page.height * scale) / page.height;
    return CGSizeMake(hscale, vscale);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(normalSize, CGSizeZero)) {
        normalSize = self.bounds.size;
    }
}

- (void)createDrawerRecognizer {
    drawerRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    [drawerRecognizer setMaximumNumberOfTouches:1];
}

- (void)setDrawerEnabled:(BOOL)drawerEnabled {
    //YES就加入手势，NO就移除
    if (_drawerEnabled == drawerEnabled) {
        return;
    }
    
    _drawerEnabled = drawerEnabled;
    
    BOOL hasRecognizer = NO;
    if (drawerRecognizer && self.gestureRecognizers.count > 0) {
        for (UIGestureRecognizer *rec in self.gestureRecognizers) {
            if (![rec isKindOfClass:[UIPanGestureRecognizer class]]) {
                continue;
            }
            if (rec != drawerRecognizer) {
                continue;
            }
            
            hasRecognizer = YES;
            break;
        }
    }
    
    if (hasRecognizer) {
        [self removeGestureRecognizer:drawerRecognizer];
    }
    
    if (_drawerEnabled) {
        if (!drawerRecognizer) {
            [self createDrawerRecognizer];
        }
        [self addGestureRecognizer:drawerRecognizer];
    }
    
    [self setCurvesSelectionEnabled:!_drawerEnabled];
}

- (void)setCurvesSelectionEnabled:(BOOL)curvesSelectionEnabled {
    //YES就加入手势，NO就移除
    if (_curvesSelectionEnabled == curvesSelectionEnabled) {
        return;
    }
    
    _curvesSelectionEnabled = curvesSelectionEnabled;
    
    BOOL hasRecognizer = NO;
    if (selectCurvesRecognizer && self.gestureRecognizers.count > 0) {
        for (UIGestureRecognizer *rec in self.gestureRecognizers) {
            if (![rec isKindOfClass:[UITapGestureRecognizer class]]) {
                continue;
            }
            if (rec != selectCurvesRecognizer) {
                continue;
            }
            
            hasRecognizer = YES;
            break;
        }
    }
    
    if (hasRecognizer) {
        [self removeGestureRecognizer:selectCurvesRecognizer];
    }
    
    if (_curvesSelectionEnabled) {
        if (!selectCurvesRecognizer) {
            selectCurvesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        }
        [self addGestureRecognizer:selectCurvesRecognizer];
    }
    
    [self setDrawerEnabled:!_curvesSelectionEnabled];
}

- (NSArray<XCurveInfo *> *)curves {
    
    return currentCurves;
}

- (NSArray<XCurveInfo *> *)selectedCurves {
    return currentSelectedCurves;
}

- (BOOL)hasChanged {
    if (initialCurves && initialCurves.count > 0) {
        if (currentCurves.count != initialCurves.count) {
            return YES;
        }
        
        for (NSInteger i = 0; i < initialCurves.count; i ++) {
            XCurveInfo *aCurveFromCurrent = [currentCurves x_objectAtIndex:i];
            XCurveInfo *aCurveFromInitial = [initialCurves x_objectAtIndex:i];
            
            if (aCurveFromCurrent != aCurveFromInitial) {
                return YES;
            }
        }
        
        return NO;
    }
    
    if (currentCurves.count == 0) {
        return NO;
    }
    
    return YES;
}

- (void)addAction:(NSDictionary *)action {
    if (!action || action.count == 0) {
        return;
    }
    
    if (currentActionIndex < 0) {
        if (actions.count > 0) {
            [actions removeAllObjects];
        }
    }
    
    NSInteger actionsCount = actions.count;
    if (actionsCount > 0 && currentActionIndex < actionsCount - 1) {
        [actions removeObjectsInRange:NSMakeRange(currentActionIndex + 1, actionsCount - currentActionIndex - 1)];
    }
    
    [actions x_addObject:action];
    
    actionsCount = actions.count;
    currentActionIndex = actionsCount - 1;
}

- (BOOL)undoOrRecovery:(BOOL)isUndo {
    NSInteger actionsCount = actions.count;
    if (actionsCount == 0) {
        return NO;
    }
    
    NSInteger currentIndex = currentActionIndex;
    if (isUndo) {
        if (currentIndex < 0) {
            return NO;
        }
        currentActionIndex --;
    } else {
        if (currentIndex >= actionsCount - 1) {
            return NO;
        }
        currentActionIndex ++;
        currentIndex = currentActionIndex;
    }
    
    NSDictionary *action = [actions x_objectAtIndex:currentIndex];
    XCurvesDrawerAction type = [[action objectForKey:actionKey] unsignedIntegerValue];
    id value = [action objectForKey:actionValue];
    
    BOOL needDraw = NO;
    
    if ((isUndo && type == XCurvesDrawerActionAdd) || (!isUndo && type == XCurvesDrawerActionRemove)) {
        
        NSArray *curves = (NSArray *)value;
        
        if (curves && curves.count > 0) {
            
            for (XCurveInfo *aCurve in curves) {
                if ([currentCurves containsObject:aCurve]) {
                    [currentCurves removeObject:aCurve];
                    needDraw = YES;
                }
            }
        }
        
    } else if ((isUndo && type == XCurvesDrawerActionRemove) || (!isUndo && type == XCurvesDrawerActionAdd)) {
        
        NSArray *curves = (NSArray *)value;
        
        if (curves && curves.count > 0) {
            
            for (XCurveInfo *aCurve in curves) {
                if (![currentCurves containsObject:aCurve]) {
                    [currentCurves x_addObject:aCurve];
                    needDraw = YES;
                }
            }
        }
    } else if (type == XCurvesDrawerActionReplace) {
        NSString *keyForTarges = nil;
        NSString *keyForReplacements = nil;

        if (isUndo) {
            keyForTarges = actionReplaceReplacement;
            keyForReplacements = actionReplaceTarget;
        } else {
            keyForTarges = actionReplaceTarget;
            keyForReplacements = actionReplaceReplacement;
        }
        NSDictionary *valueDictionary = (NSDictionary *)value;
        
        NSArray<XCurveInfo *> *willRepleacedTargets = [valueDictionary objectForKey:keyForTarges];
        NSArray<XCurveInfo *> *replacements = [valueDictionary objectForKey:keyForReplacements];
        
        [currentCurves removeObjectsInArray:willRepleacedTargets];
        [currentCurves addObjectsFromArray:replacements];
        
        needDraw = YES;
    }
    
    if (needDraw) {
        [self draw];
    }
    
    return YES;
}

//手势滑动事件，获取曲线
- (void)onDrag:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    
    if (isnan(point.x) || isnan(point.y)) {
        return;
    }
    
    if (!CGSizeEqualToSize(normalSize, CGSizeZero)) {
        CGSize scale = fitPageToNormalSize(normalSize, self.bounds.size);
        if (!isnan(scale.width) && !isnan(scale.height) &&
            !CGSizeEqualToSize(scale, CGSizeMake(1, 1))) {
            point.x /= scale.width;
            point.y /= scale.height;
        }
    }
    
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    if (!pointValue) {
        return;
    }
    
    XCurveInfo *aCurve = nil;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        aCurve = [[XCurveInfo alloc] init];
        [aCurve setColor:_drawerColor];
        [aCurve setWidth:_drawerWidth];
        [aCurve setAllowModify:YES];
        [aCurve setUser:_user];
        
        NSDate *date = getCurrentDate();
        [aCurve setCreateDate:date];
        [aCurve setModificationDate:date];
        
        [currentCurves x_addObject:aCurve];
        
        [self addAction:@{actionKey : @(XCurvesDrawerActionAdd), actionValue : @[aCurve]}];
    } else {
        if (currentCurves.count == 0) {
            return;
        }
        
        aCurve = [currentCurves lastObject];
    }
    
    if (!aCurve) {
        return;
    }
    
    [aCurve.points x_addObject:pointValue];
    
    [self draw];
}

//点击选择曲线事件
- (void)onTap:(UITapGestureRecognizer*)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(curvesDrawerBeginSelectCurve:)]) {
        [_delegate curvesDrawerBeginSelectCurve:self];
    }
    
    if (currentCurves.count == 0) {
        if(_delegate && [_delegate respondsToSelector:@selector(curvesDrawerEndSelectCurve:)]) {
            [_delegate curvesDrawerEndSelectCurve:self];
        }
        return;
    }
    
    CGPoint point = [sender locationInView:self];
    
    if (isnan(point.x) || isnan(point.y)) {
        return;
    }
    
    if (!CGSizeEqualToSize(normalSize, CGSizeZero)) {
        CGSize scale = fitPageToNormalSize(normalSize, self.bounds.size);
        if (!isnan(scale.width) && !isnan(scale.height) &&
            !CGSizeEqualToSize(scale, CGSizeMake(1, 1))) {
            point.x /= scale.width;
            point.y /= scale.height;
        }
    }
    
    XCurveInfo *selectedCurve = nil;
    
    for (XCurveInfo *aCurve in currentCurves) {
        if (!aCurve.allowModify) {
            continue;
        }
        
        if (aCurve.points.count < 2) {
            continue;
        }
        
        for (NSInteger i = 0; i < aCurve.points.count; i ++) {
            if (i == aCurve.points.count - 1) {
                break;
            }
            
            CGPoint beginPoint = [[aCurve.points x_objectAtIndex:i] CGPointValue];
            CGPoint lastPoint = [[aCurve.points x_objectAtIndex:(i + 1)] CGPointValue];
            
            CGRect rect = [self rectForFirstPoint:beginPoint secondPoint:lastPoint offset:20];
            
            if (CGRectContainsPoint(rect, point)) {
                selectedCurve = aCurve;
                
                break;
            }
        }
        
        if (selectedCurve) {
            break;
        }
    }
    
    if (selectedCurve) {
        BOOL isCancel = [self cancelSelectedCurve:selectedCurve];
        if (!isCancel) {
            [currentSelectedCurves x_addObject:selectedCurve];
        }
        
        if(_delegate && [_delegate respondsToSelector:@selector(curvesDrawer:selectedCurve:isCancel:)]) {
            [_delegate curvesDrawer:self selectedCurve:selectedCurve isCancel:isCancel];
        }
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(curvesDrawerEndSelectCurve:)]) {
        [_delegate curvesDrawerEndSelectCurve:self];
    }
}

//绘制
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!CGSizeEqualToSize(normalSize, CGSizeZero)) {
        CGSize scale = fitPageToNormalSize(normalSize, self.bounds.size);
        if (!isnan(scale.width) && !isnan(scale.height) &&
            !CGSizeEqualToSize(scale, CGSizeMake(1, 1))) {
            
            CGContextScaleCTM(context, scale.width, scale.height);
        }
    }
    
    for (XCurveInfo *aCurve in currentCurves) {
        CGPoint point = [[aCurve.points x_objectAtIndex:0] CGPointValue];
        
        if (isnan(point.x) || isnan(point.y)) {
            continue;
        }
        
        if (!aCurve.color) {
            [aCurve setColor:_drawerColor];
        }
        [aCurve.color set];
        if (aCurve.width <= 0) {
            [aCurve setWidth:_drawerWidth];
        }
        
        CGContextSetLineWidth(context, aCurve.width);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, point.x, point.y);
        CGPoint lastPoint = point;
        
        for (NSUInteger i = 1; i < aCurve.points.count; i++) {
            point = [[aCurve.points x_objectAtIndex:i] CGPointValue];
            if (isnan(point.x) || isnan(point.y)) {
                continue;
            }
            
            CGContextAddQuadCurveToPoint(context, lastPoint.x, lastPoint.y, (point.x + lastPoint.x)/2, (point.y + lastPoint.y)/2);
            lastPoint = point;
        }
        
        CGContextAddLineToPoint(context, point.x, point.y);
        CGContextStrokePath(context);
    }
}

@end
