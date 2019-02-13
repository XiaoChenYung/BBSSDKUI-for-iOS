//
//  BBSUIXieYiViewController.m
//  BBSSDKUI_WF
//
//  Created by xiaochen yang on 2019/2/13.
//  Copyright © 2019 MOB. All rights reserved.
//

#import "BBSUIXieYiViewController.h"
#import <WebKit/WebKit.h>

@interface BBSUIXieYiViewController ()

@property (nonatomic, strong) WKWebView* wkWebView;

@end

@implementation BBSUIXieYiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wkWebView = [[WKWebView alloc] init];
    self.title = @"发帖协议";
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
