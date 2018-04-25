//
//  BBSUISignInViewController.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/2.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUISignInViewController.h"
#import <WebKit/WebKit.h>
#import <MOBFoundation/MOBFoundation.h>
#import "BBSUIContext.h"
#import "BBSUIWhiteNavViewController.h"



@interface BBSUISignInViewController ()

@property (nonatomic, strong) WKWebView *webView;

@end


@implementation BBSUISignInViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _createWKWebView];
    [self _updateWkWebView];

}

- (void)_createBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/BackButton@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)setNavAndStatusBar
{
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:DZSUIColorFromHex(0x6A7081),NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    //253 169 77
    [self.navigationController.navigationBar setBackgroundImage:[super  createImageWithColor:DZSUIColorFromHex(0xFFAA42)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[super createImageWithColor:DZSUIColorFromHex(0xFFAA42)]];
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_createWKWebView
{
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height)];
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView setOpaque:NO];
    [self.view addSubview:self.webView];
}

- (void)_updateWkWebView
{
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    NSString *randomStr = [self getRandomStringWithNum:10];
    
    [SVProgressHUD showWithStatus:@"loading..."];
    [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
        if (!error) {
            [BBSSDK getSginUrlWithType:@"1" Result:^(NSString *objStr, NSError *error) {
                 NSString *url = [NSString stringWithFormat:@"%@&uid=%@&sign=%@&time=%ld&type=1&nonce=%@",user.signurl, user.uid,objStr,time,randomStr];
                NSURL * ubanAgreementUrl = [NSURL URLWithString:url];
                NSURLRequest * ubanAgreementRequest = [NSURLRequest requestWithURL:ubanAgreementUrl];
                [self.webView loadRequest:ubanAgreementRequest];
            self.webView.scrollView.showsVerticalScrollIndicator = NO;
                [SVProgressHUD dismissWithDelay:0.5];
            }];
        }
    }];
}

#pragma mark - 获取随机数
- (NSString *)getRandomStringWithNum:(NSInteger)num
{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < num; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
