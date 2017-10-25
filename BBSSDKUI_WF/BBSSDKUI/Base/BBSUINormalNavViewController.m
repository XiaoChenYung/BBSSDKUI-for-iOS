//
//  BBSUINormalNavViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUINormalNavViewController.h"
#import "UIImage+BBSFunction.h"

@interface BBSUINormalNavViewController ()

@end

@implementation BBSUINormalNavViewController

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
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
}

@end
