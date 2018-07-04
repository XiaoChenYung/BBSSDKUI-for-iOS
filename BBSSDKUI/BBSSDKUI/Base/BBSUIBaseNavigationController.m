//
//  BBSUIBaseNavigationController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/16.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseNavigationController.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIBaseNavigationController ()

@end

@implementation BBSUIBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationBar.barStyle = UIBarStyleBlack;
    
    //设置导航栏和状态栏
    [self setNavAndStatusBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavAndStatusBar
{
    //导航栏
    [self.navigationBar setBarTintColor:DZSUIColorFromHex(0x38373d)];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor,
                                                [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont,
                                                nil]];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

@end
