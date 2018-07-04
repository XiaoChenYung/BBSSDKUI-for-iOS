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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers.count > 1) {
        // 记录系统返回手势的代理
//        _delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
//        
//        //设置系统返回收拾的代理为当前控制器
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return self.navigationController.childViewControllers.count > 1;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return self.navigationController.childViewControllers.count > 1;
//}

@end

//
//- (void)viewDidLoad
//{
//            [super viewDidLoad];        // 自定义返回按钮
//            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//            [button setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
//            [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
//}
// 
//- (void)back:(UIButton *)button {
//            [self.navigationController popViewControllerAnimated:YES];
//}
// 
//- (void)viewWillAppear:(BOOL)animated
//{
//        [super viewWillAppear:animated];
//    if (self.navigationController.viewControllers.count > 1) {          // 记录系统返回手势的代理
//                _delegate = self.navigationController.interactivePopGestureRecognizer.delegate;          // 设置系统返回手势的代理为当前控制器
//                self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    }
//}
// 
//- (void)viewWillDisappear:(BOOL)animated {
//        [super viewWillDisappear:animated];     // 设置系统返回手势的代理为我们刚进入控制器的时候记录的系统的返回手势代理
//        self.navigationController.interactivePopGestureRecognizer.delegate = _delegate;
//}
//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return self.navigationController.childViewControllers.count > 1;
//}
// 
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return self.navigationController.viewControllers.count > 1;
//}
