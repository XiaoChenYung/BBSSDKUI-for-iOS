//
//  BBSUIWebViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/22.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUINormalNavViewController.h"
#import <MOBFoundation/MOBFJSContext.h>

@interface BBSUIWebViewController : BBSUINormalNavViewController<UIWebViewDelegate>

/**
 *  网页视图
 */
@property (nonatomic, strong) UIWebView *webView;

/**
 *  链接地址
 */
@property (nonatomic, copy) NSString *urlString;

/**
 *  请求对象
 */
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) JSContext *context;

@property (nonatomic, strong) MOBFJSContext *jsContext;

- (void)setupJSNativeWithNativeExtPath:(NSString *)extPath;

- (void)addWebview;

@end
