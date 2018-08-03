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
#import "BBSUIBaseView.h"


@interface BBSUISignInViewController ()

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UIImageView *noDataImageView;
@end


@implementation BBSUISignInViewController


#pragma mark - 懒加载 Lazy Load
- (UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height)];
        _noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DZSUIScreen_width - 80) / 2, DZSUIScreen_height/4, 80, 80)];
        [_noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];
        [_noDataView addSubview:_noDataImageView];
        
        _noDataLabel = [UILabel new];
        [_noDataLabel setFrame:CGRectMake(0, BBS_BOTTOM(_noDataImageView), DZSUIScreen_width, 40)];
        [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [_noDataLabel setTextColor:[UIColor grayColor]];
        [_noDataLabel setText:@"暂无内容"];
        [_noDataView addSubview:_noDataLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        tap.numberOfTapsRequired = 1;
        [_noDataView addGestureRecognizer:tap];
        
    }
    return _noDataView;
}

- (void)tapClick
{
    [self _updateWkWebView];
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _createWKWebView];
    [self _updateWkWebView];
    self.noDataView.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
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
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0xFFA941)];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:DZSUIColorFromHex(0x6A7081),NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    //253 169 77 FFAA42
    [self.navigationController.navigationBar setBackgroundImage:[super  createImageWithColor:DZSUIColorFromHex(0xFFA941)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[super createImageWithColor:DZSUIColorFromHex(0xFFA941)]];
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
    
    UIView *insetView = [[UIView alloc] init];
    [self.view addSubview:insetView];
    [insetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.size.height.mas_equalTo(64);
    }];
    insetView.backgroundColor = DZSUIColorFromHex(0xFFA941);
}

- (void)_updateWkWebView
{
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD show];
    [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
        if (!error)
        {
             self.noDataView.hidden = YES;
            [BBSSDK getSginUrlWithType:@"1" userUid:user.uid enterSignUrl:user.signurl time:time Result:^(NSString *sginUrl, NSError *error) {
                NSURL * ubanAgreementUrl = [NSURL URLWithString:sginUrl];
                NSURLRequest * ubanAgreementRequest = [NSURLRequest requestWithURL:ubanAgreementUrl];
                [self.webView loadRequest:ubanAgreementRequest];
                self.webView.scrollView.showsVerticalScrollIndicator = NO;
                [SVProgressHUD dismissWithDelay:0.5];
            }];
        }
        else
        {
            self.noDataView.hidden = NO;
            [self.view addSubview:self.noDataView];
            [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wwl@2x.png"]];
            [self.noDataLabel setText:@"网络不佳，请再次刷新"];
            self.view.backgroundColor = [UIColor clearColor];
            [SVProgressHUD dismissWithDelay:0.5];
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
