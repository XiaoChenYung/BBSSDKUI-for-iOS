//
//  BBSUIMainStyleNavigationController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIMainStyleNavigationController.h"

@interface BBSUIMainStyleNavigationController ()

@end

@implementation BBSUIMainStyleNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarDark];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarDark
{
    //导航栏
    [self.navigationBar setBarTintColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}


@end
