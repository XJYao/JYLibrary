//
//  XNotification.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XNotification.h"
#import "XIOSVersion.h"
#import "XThread.h"
#import <AudioToolbox/AudioToolbox.h>
#import "XTool.h"
#import <UserNotifications/UserNotifications.h>
#import "NSArray+XArray.h"
#import "NSDictionary+XDictionary.h"


@interface XNotification ()
{
    NSMutableDictionary *observersDictionary;
    NSMutableDictionary *observersKVODictionary;
}

@end


@implementation XNotification

+ (instancetype)sharedManager {
    static XNotification *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[XNotification alloc] init];
        });
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        observersDictionary = [[NSMutableDictionary alloc] init];
        observersKVODictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - notification center

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    if (!observer || [XTool isStringEmpty:aName]) {
        return;
    }

    NSMutableArray *observers = [[NSMutableArray alloc] init];

    if (![XTool isDictionaryEmpty:observersDictionary] && [observersDictionary.allKeys containsObject:aName]) {
        id obj = [observersDictionary objectForKey:aName];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSArray *currentObservers = (NSArray *)obj;
            if ([currentObservers containsObject:observer]) {
                return;
            }
            [observers addObjectsFromArray:currentObservers];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:anObject];

    [observers x_addObject:observer];
    [observersDictionary x_setObject:observers forKey:aName];
}

- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    if (![XTool isDictionaryEmpty:observersDictionary] && [observersDictionary.allKeys containsObject:aName]) {
        id obj = [observersDictionary objectForKey:aName];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *observers = [[NSMutableArray alloc] initWithArray:(NSArray *)obj];
            if ([observers containsObject:observer]) {
                [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:anObject];
                [observers removeObject:observer];
                if ([XTool isArrayEmpty:observers]) {
                    [observersDictionary removeObjectForKey:aName];
                } else {
                    [observersDictionary x_setObject:observers forKey:aName];
                }
            }
        }
    }
}

- (void)removeAllObservers {
    if ([XTool isDictionaryEmpty:observersDictionary]) {
        return;
    }

    for (NSString *aName in observersDictionary.allKeys) {
        id obj = [observersDictionary objectForKey:aName];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            for (id observer in (NSArray *)obj) {
                if (observer) {
                    [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:nil];
                }
            }
        }
    }

    [observersDictionary removeAllObjects];
}

#pragma mark - KVO

- (void)addKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!observer || !anObject || [XTool isStringEmpty:keyPath]) {
        return;
    }

    NSMutableArray *observers = [[NSMutableArray alloc] init];

    if (![XTool isDictionaryEmpty:observersKVODictionary] && [observersKVODictionary.allKeys containsObject:keyPath]) {
        id obj = [observersKVODictionary objectForKey:keyPath];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSArray *currentObservers = (NSArray *)obj;
            for (id param in currentObservers) {
                if (param && [param isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *paramDic = (NSDictionary *)param;
                    NSObject *tempObserver = [paramDic objectForKey:@"observer"];
                    NSObject *tempObj = [paramDic objectForKey:@"object"];
                    if (tempObserver == observer && tempObj == anObject) {
                        return;
                    }
                }
            }
            [observers addObjectsFromArray:currentObservers];
        }
    }

    [anObject addObserver:observer forKeyPath:keyPath options:options context:context];

    NSMutableDictionary *observerDic = [[NSMutableDictionary alloc] init];
    [observerDic x_setObject:observer forKey:@"observer"];
    [observerDic x_setObject:anObject forKey:@"object"];
    [observers x_addObject:observerDic];
    [observersKVODictionary x_setObject:observers forKey:keyPath];
}

- (void)removeKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath context:(void *)context {
    [self removeKVO:observer forObject:anObject forKeyPath:keyPath context:context hasContext:YES];
}

- (void)removeKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath {
    [self removeKVO:observer forObject:anObject forKeyPath:keyPath context:NULL hasContext:NO];
}

- (void)removeKVO:(NSObject *)observer forObject:(NSObject *)anObject forKeyPath:(NSString *)keyPath context:(void *)context hasContext:(BOOL)hasContext {
    if (![XTool isDictionaryEmpty:observersKVODictionary] && [observersKVODictionary.allKeys containsObject:keyPath]) {
        id obj = [observersKVODictionary objectForKey:keyPath];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *observers = [[NSMutableArray alloc] initWithArray:(NSArray *)obj];
            for (id param in observers) {
                if (param && [param isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *paramDic = (NSDictionary *)param;
                    NSObject *tempObserver = [paramDic objectForKey:@"observer"];
                    NSObject *tempObj = [paramDic objectForKey:@"object"];
                    if (tempObserver == observer && tempObj == anObject) {
                        if (hasContext) {
                            [anObject removeObserver:observer forKeyPath:keyPath context:context];
                        } else {
                            [anObject removeObserver:observer forKeyPath:keyPath];
                        }

                        [observers removeObject:param];
                        if ([XTool isArrayEmpty:observers]) {
                            [observersKVODictionary removeObjectForKey:keyPath];
                        } else {
                            [observersKVODictionary x_setObject:observers forKey:keyPath];
                        }
                        return;
                    }
                }
            }
        }
    }
}

- (void)removeAllKVO {
    if ([XTool isDictionaryEmpty:observersKVODictionary]) {
        return;
    }

    for (NSString *keyPath in observersKVODictionary.allKeys) {
        id obj = [observersKVODictionary objectForKey:keyPath];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *observers = [[NSMutableArray alloc] initWithArray:(NSArray *)obj];
            for (id param in observers) {
                if (param && [param isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *paramDic = (NSDictionary *)param;
                    NSObject *tempObserver = [paramDic objectForKey:@"observer"];
                    NSObject *tempObj = [paramDic objectForKey:@"object"];

                    [tempObj removeObserver:tempObserver forKeyPath:keyPath];
                }
            }
        }
    }

    [observersKVODictionary removeAllObjects];
}

#pragma mark - notification

+ (void)sendNotificationOnMainThread:(NSString *)notificationName withObject:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:object userInfo:nil];
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
    }
}

+ (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:object userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

+ (void)sendNotificationOnNewThread:(NSString *)notificationName withObject:(id)object {
    x_dispatch_async_default(^{
        [self sendNotification:notificationName withObject:object];
    });
}

#pragma mark - push

+ (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber {
    if (badgeNumber < 0) {
        badgeNumber = 0;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

+ (void)clearNotification {
    [self setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (void)registerRemoteNotification {
    if ([XIOSVersion isIOS10OrGreater]) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError *_Nullable error){

        }];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if ([XIOSVersion isIOS8OrGreater]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                                                                            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                                                              categories:nil]];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                                               (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

+ (void)registerUserNotification {
    //ios8后，需要添加这个注册，才能得到授权
    if ([XIOSVersion isIOS8OrGreater] &&
        [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

+ (void)alertLocalNotification:(NSString *)alertBody alertAction:(NSString *)alertAction userInfo:(NSDictionary *)userInfo interval:(double)interval {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    [notification setFireDate:pushDate];
    [notification setRepeatInterval:0];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    //去掉下面2行就不会弹出提示框
    [notification setAlertBody:alertBody];
    [notification setAlertAction:alertAction];
    [notification setUserInfo:userInfo];

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    //声音提醒
    AudioServicesPlaySystemSound(1007);
}

@end
