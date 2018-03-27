//
//  BBSUIBackViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIBackViewController ()<UIGestureRecognizerDelegate>

@property(nullable,nonatomic,weak) id <UIGestureRecognizerDelegate> delegate;

@end

@implementation BBSUIBackViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置导航栏按钮
    [self setNavigationBarItems];
    
}

- (void)setNavigationBarItems
{
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -20;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/BackButton@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[fixedButton, [[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

@end

