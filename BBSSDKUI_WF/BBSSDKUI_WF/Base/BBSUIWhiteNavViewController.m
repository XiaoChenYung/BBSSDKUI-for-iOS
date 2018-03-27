//
//  BBSUIWhiteNavViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/30.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIWhiteNavViewController.h"
#import "UIImage+BBSFunction.h"
#define DZSUIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

@interface BBSUIWhiteNavViewController ()

@end

@implementation BBSUIWhiteNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setNavAndStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.navigationController.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavAndStatusBar
{
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:DZSUIColorFromHex(0x6A7081),NSFontAttributeName:[UIFont systemFontOfSize:17]};
}


@end
