//
//  ViewController.m
//  JYLibraryExample
//
//  Created by XJY on 16/10/10.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "ViewController.h"
#include <JYLibrary/JYLibrary.h>
#import "TestModel.h"
//#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController () <XWebManagerDelegate> {
    XWebManager *web;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    web = [[XWebManager alloc] init];
    [web setDelegate:self];
    
    [web addScriptMessageHandlerWithName:@"AppModel"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"File" ofType:@"html"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:path] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    [web loadRequest:request];
    [self.view addSubview:web.webView];
    
    web.webView.x_edge.x_equalTo(self.view).x_constant(0);
    
//    JSContext *context = [[JSContext alloc] init];
    
//    NSString *js = @"function add(a,b) {return a+b}";
//    
//    [context evaluateScript:js];
//    
//    JSValue *n = [context[@"add"] callWithArguments:@[@2, @3]];
//    
//    NSLog(@"---%@", @([n toInt32]));//---5
    
    
//    context[@"add"] = ^(NSInteger a, NSInteger b) {
//        NSLog(@"---%@", @(a + b));
//    };
//    
//    [context evaluateScript:@"add(2,3)"];
    

    //设置异常处理
//    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
//        [JSContext currentContext].exception = exception;
//        NSLog(@"exception:%@",exception);
//    };
//    //将obj添加到context中
//    TestModel *model4 = [[TestModel alloc] init];
//    context[@"OCObj"] = model4;
//    //JS里面调用Obj方法，并将结果赋值给Obj的sum属性
//    [context evaluateScript:@"OCObj.sum = OCObj.add(2,3)"];
    
    
    
    NSDictionary *dic = @{@"unknownObj" : [NSNull null], @"str" : @"abc", @"mutableStr" : @"cdef", @"attributedStr" : @"wewr", @"mutableAttributedStr" : @"sdcwwwe", @"number" : @(9),
                          @"cInt" : @(-1), @"democUInt" : @(2), @"cShort" : @(-10), @"cUShort" : @(11), @"cLong" : @(1234), @"cULong" : @(1232),
                          @"cLongLong" : @(-1287362), @"cULongLong" : @(2112112), @"cChar" : @(false), @"ocBOOL" : @(YES), @"cbool" : @(true),
                          @"cFloat" : @(1.09), @"cDouble" : @(2.09382), @"cLongDouble" : @(3.12134), @"cCGFloat" : @(23.13412),
                          @"cInteger" : @"-9834", @"cUInteger" : @"9821",
                          
                          @"arr" : @[@"12", @"23"],
                          @"subTestModelArr" : @[@{@"name" : @"小明", @"age" : @(3)}, @{@"name" : @"老王", @"age" : @(88)}],
                          @"mutableArr" : @[@"dsf", @"ewcew", @(993)],
                          
                          @"dic" : @{@"heh" : @"zzcc"},
                          @"mutableDic" : @{@"cca" : @"dwwe"},
                          
                          @"set" : @[@"cwe", @"qwaf"],
                          @"mutableSet" : @[@{@"name" : @"哈哈", @"age" : @(11)}, @{@"name" : @"呵呵", @"age" : @(13)}],
                          @"countedSet" : @[@(YES), @"NO", @"dfede"],
                          
                          @"subTestModel" : @{@"name" : @"翠花", @"age" : @(18)},
                          
                          @"name" : @"自定义"
                          };
    
    NSData *jsonData = [XJsonParser jsonDataWithObject:dic error:NULL];
    NSString *jsonString = [XJsonParser jsonStringWithObject:dic error:NULL];
    
    TestModel *model1 = [TestModel modelFromDictionary:dic];
    TestModel *model2 = [TestModel modelFromJson:jsonData];
    TestModel *model3 = [TestModel modelFromJson:jsonString];

    TestModel *model4 = [[TestModel alloc] init];
    [model4 setValueFromDictionary:dic];
    TestModel *model5 = [[TestModel alloc] init];
    [model5 setValueFromJson:jsonData];
    TestModel *model6 = [[TestModel alloc] init];
    [model6 setValueFromJson:jsonString];
    
    id models7 = [TestModel modelsFromCollection:@[dic, [dic mutableCopy]]];
    id models8 = [TestModel modelsFromCollection:[NSSet setWithObjects:dic, @{@"name" : @"大废物废物"}, nil]];
    
    TestModel *model9 = [[TestModel alloc] init];
    [model1 copyValueTo:model9];
    
    debugLog(@"hja");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XWebManagerDelegate

/*! @abstract 捕捉到JavaScript执行alert
 */
- (void)webManager:(XWebManager *)manager alertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alertView show];
}

/*! @abstract 捕捉到JavaScript执行confirm
 */
- (void)webManager:(XWebManager *)manager confirmWithMessage:(NSString *)message completionHandler:(nonnull void (^)(BOOL result))completionHandler {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message object:nil buttonTitles:@[@"否", @"是"] alertViewBlock:^(UIAlertView *alert, NSString *buttonTitle, NSInteger buttonIndex, id object) {
        if (completionHandler) {
            completionHandler(buttonIndex == 1);
        }
    }];
    [alertView show];
}

/*! @abstract 捕捉到JavaScript执行prompt
 */
- (void)webManager:(XWebManager *)manager textInputWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText completionHandler:(void (^)(NSString * result))completionHandler {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:prompt message:defaultText object:nil buttonTitles:@[@"确定"] alertViewBlock:^(UIAlertView *alert, NSString *buttonTitle, NSInteger buttonIndex, id object) {
        if (completionHandler) {
            completionHandler([alert textFieldAtIndex:0].text);
        }
    }];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

/*! @abstract 捕捉到JavaScript调oc的消息
 */
- (void)webManager:(XWebManager *)manager didReceiveScriptMessage:(nonnull id)message handlerName:(nonnull NSString *)name {
    NSLog(@"%@", name);
    NSLog(@"%@", message);
}

- (void)webManager:(XWebManager *)manager newManager:(XWebManager *)newManager URL:(NSURL *)URL {
    NSLog(@"打开新窗口");
}

@end
