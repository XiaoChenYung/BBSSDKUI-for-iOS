//
//  BBSUICustomNavViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/5/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICustomNavViewController.h"

@interface BBSUICustomNavViewController ()

@end

@implementation BBSUICustomNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.navigationBarStyle == BBSUINavigationBarStyleDarkBlue)
    {
        [self setNavigationBarDarkBlue];
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

- (void)setNavigationBarDarkBlue
{
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x3C445E)];
    [self.navigationController.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

@end
