//
//  BBSUICostomNavViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICostomNavViewController.h"

@interface BBSUICostomNavViewController ()

@end

@implementation BBSUICostomNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_enableBackBarButton)
    {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0, 0, 44, 44)];
        [backButton setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavigationBarDefault
{
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
}

- (void)setNavigationBarDark
{
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x3C445E)];
    [self.navigationController.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}


@end
