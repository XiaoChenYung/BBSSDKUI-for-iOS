//
//  BBSUIInformationViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIInformationViewController.h"
#import "BBSUIInformationView.h"

@interface BBSUIInformationViewController ()

@property (nonatomic, strong) BBSUIInformationView *informationView;

@end

@implementation BBSUIInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的消息";
    
    _informationView = [[BBSUIInformationView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_informationView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    // 加载数据
    // ...
}


@end
