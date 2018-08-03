//
//  BBSUIDarkBlueViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIDarkBlueViewController.h"

@interface BBSUIDarkBlueViewController ()

@end

@implementation BBSUIDarkBlueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_flag)
    {
        [self setNavigationBarDark];
    }
    else
    {
        [self setNavigationBarDefault];
    }
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
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.navigationController.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}


@end
