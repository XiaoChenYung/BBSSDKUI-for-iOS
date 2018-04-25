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
    
    [self setNavAndStatusBar];
}

- (void)setNavigationBarItems
{
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -20;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/BackButton3@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[fixedButton, [[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavAndStatusBar
{
    // 导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    // 状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:DZSUIColorFromHex(0x2A2B30),NSFontAttributeName:[UIFont systemFontOfSize:16]};
    
    // 去掉下边线
    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor clearColor]]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[self createImageWithColor:[UIColor clearColor]]];
}


/**
 通过color创建image

 @param color color
 @return image
 */
- (UIImage *)createImageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
    
}


@end

