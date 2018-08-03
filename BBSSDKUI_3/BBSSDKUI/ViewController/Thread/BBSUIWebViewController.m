//
//  BBSUIWebViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/22.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIWebViewController.h"
#import "Masonry.h"
#import "NSBundle+BBSSDKUI.h"
#import <MOBFoundation/MOBFRegex.h>
#import <MOBFoundation/MOBFoundation.h>

@interface BBSUIWebViewController ()

@end

@implementation BBSUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addWebview];
    
//    [self setupJSNative];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self delNavLine];
}

- (void)addWebview
{
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
//    [self.webView setBackgroundColor:[UIColor whiteColor]];
//    [self.webView sizeToFit];
    self.webView.scalesPageToFit = YES;
}

- (void)setupJSNativeWithNativeExtPath:(NSString *)extPath
{
    if ([MOBFDevice versionCompare:@"8.0"] >= 0) {
        self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        self.jsContext = [[MOBFJSContext alloc] initWithContext:self.context];
    }else{
        self.jsContext = [[MOBFJSContext alloc] initWithWebView:self.webView];;
    }
    
    //加载NativeExt
    NSString *path = [[NSBundle bbsLoadBundle] pathForResource:extPath ofType:@"js"];
    NSString *pluginID = [self pluginIDByPath:path];
    if (pluginID)
    {
        [self.jsContext loadPluginWithPath:path forName:pluginID];
    }
    
    
}

/**
 *  根据路径获取插件标志
 *
 *  @param path 插件路径
 *
 *  @return 插件标志
 */
- (NSString *)pluginIDByPath:(NSString *)path
{
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content)
    {
        NSArray *matchedStringArr = [MOBFRegex captureComponentsMatchedByRegex:@"var\\s+\\$pluginID\\s*=\\s*\\\"([^\\\"]+)\\\";" withString:content];
        if (matchedStringArr.count > 1)
        {
            return matchedStringArr[1];
        }
    }
    
    return nil;
}

- (void)delNavLine
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"head_bar_pink_.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[self createImageWithColor:[UIColor clearColor]]];
}

- (UIImage *)createImageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
    
}

@end
