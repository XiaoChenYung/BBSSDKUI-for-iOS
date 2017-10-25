//
//  BBSUIBackNavViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/10.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackNavViewController.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIBackNavViewController ()

@end

@implementation BBSUIBackNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置返回按钮
    [self _setupLeftBarButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)_setupLeftBarButtonItem
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    
    [backButton.layer setMasksToBounds:YES];
    [backButton.layer setCornerRadius:15];
    UIImage *scaleImage = [UIImage BBSImageNamed:@"/Common/backBlack@2x.png"];
    [backButton setImage:scaleImage forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
