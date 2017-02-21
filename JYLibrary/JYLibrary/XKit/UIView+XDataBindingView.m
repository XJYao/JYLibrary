//
//  UIView+XDataBindingView.m
//  JYLibrary
//
//  Created by XJY on 17/2/14.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import "UIView+XDataBindingView.h"
#import <objc/runtime.h>

@interface UIView ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *x_bindingKeyPaths;

@end

@implementation UIView (XDataBindingView)

- (void)setX_bindingDataChangedBlock:(void (^)(UIView *, id, NSString *, id, id))block {
    objc_setAssociatedObject(self, _cmd, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIView *, id, NSString *, id, id))x_bindingDataChangedBlock {
    return objc_getAssociatedObject(self, @selector(setX_bindingDataChangedBlock:));
}

- (void)setX_bindingKeyPaths:(NSMutableDictionary<NSString *,NSMutableDictionary *> *)datasourceAndKeyPaths {
    objc_setAssociatedObject(self, _cmd, datasourceAndKeyPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,NSMutableDictionary *> *)x_bindingKeyPaths {
    NSMutableDictionary *datasourceAndKeyPaths = objc_getAssociatedObject(self, @selector(setX_bindingKeyPaths:));
    if (!datasourceAndKeyPaths) {
        datasourceAndKeyPaths = [NSMutableDictionary dictionary];
        [self setX_bindingKeyPaths:datasourceAndKeyPaths];
    }
    return datasourceAndKeyPaths;
}

- (void)x_addBindingDatasource:(id)datasource keyPath:(NSString *)keyPath {
    if (!datasource || [datasource isEqual:[NSNull null]] || datasource == (id)kCFNull ||
        !keyPath || [keyPath isEqual:[NSNull null]] || keyPath == (id)kCFNull || keyPath.length == 0) {
        return;
    }
    
    for (NSString *key in self.x_bindingKeyPaths.allKeys) {
        NSDictionary *datasourceAndKeyPath = [self.x_bindingKeyPaths objectForKey:key];
        id existDatasource = [datasourceAndKeyPath objectForKey:@"datasource"];
        NSString *existKeyPath = [datasourceAndKeyPath objectForKey:@"keyPath"];
        
        if (existDatasource == datasource &&
            [existKeyPath isEqualToString:keyPath]) {
            return;
        }
    }
    
    [datasource addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld context:NULL];
    
    NSString *key = NSStringFromClass([datasource class]);
    NSMutableDictionary *datasourceAndKeyPaths = [self.x_bindingKeyPaths objectForKey:key];
    if (!datasourceAndKeyPaths) {
        datasourceAndKeyPaths = [NSMutableDictionary dictionary];
        [self.x_bindingKeyPaths setObject:datasourceAndKeyPaths forKey:key];
    }
    [datasourceAndKeyPaths setObject:datasource forKey:@"datasource"];
    [datasourceAndKeyPaths setObject:keyPath forKey:@"keyPath"];
}

- (void)x_removeBindingDatasource:(id)datasource keyPath:(NSString *)keyPath {
    if (!datasource || [datasource isEqual:[NSNull null]] || datasource == (id)kCFNull ||
        !keyPath || [keyPath isEqual:[NSNull null]] || keyPath == (id)kCFNull || keyPath.length == 0) {
        return;
    }
    
    NSString *willRemoveKey = nil;
    for (NSString *key in self.x_bindingKeyPaths.allKeys) {
        NSDictionary *datasourceAndKeyPath = [self.x_bindingKeyPaths objectForKey:key];
        id existDatasource = [datasourceAndKeyPath objectForKey:@"datasource"];
        NSString *existKeyPath = [datasourceAndKeyPath objectForKey:@"keyPath"];
        
        if (existDatasource == datasource &&
            [existKeyPath isEqualToString:keyPath]) {
            
            [datasource removeObserver:self forKeyPath:keyPath];
            willRemoveKey = key;
            
            break;
        }
    }
    
    if (willRemoveKey) {
        [self.x_bindingKeyPaths removeObjectForKey:willRemoveKey];
    }
}

- (void)removeAllBinding {
    if (self.x_bindingKeyPaths.count == 0) {
        return;
    }
    
    for (NSString *key in self.x_bindingKeyPaths.allKeys) {
        NSDictionary *datasourceAndKeyPath = [self.x_bindingKeyPaths objectForKey:key];
        id datasource = [datasourceAndKeyPath objectForKey:@"datasource"];
        NSString *keyPath = [datasourceAndKeyPath objectForKey:@"keyPath"];
        
        [datasource removeObserver:self forKeyPath:keyPath];
    }
    
    [self.x_bindingKeyPaths removeAllObjects];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id oldValue = [change objectForKey:@"old"];
    id newValue = [object valueForKeyPath:keyPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.x_bindingDataChangedBlock) {
            self.x_bindingDataChangedBlock(self, object, keyPath, oldValue, newValue);
        }
    });
}

@end
