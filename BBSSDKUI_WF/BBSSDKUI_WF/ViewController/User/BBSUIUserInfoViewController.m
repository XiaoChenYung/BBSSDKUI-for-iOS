//
//  BBSUIUserInfoViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserInfoViewController.h"
#import "BBSUIUserInfoView.h"
#import "BBSUIUserEditViewController.h"
#import "BBSUIContext.h"

@interface BBSUIUserInfoViewController ()

@property (nonatomic, strong) BBSUIUserInfoView *userInfoView;

@property (nonatomic, strong) BBSUser *user;

@property (nonatomic, strong) UIBarButtonItem *editButtonItem;

@end

@implementation BBSUIUserInfoViewController

- (instancetype)initWithUser:(BBSUser *)user
{
    self = [super init];
    if (self) {
        self.user = user;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人资料";
    
    _userInfoView = [[BBSUIUserInfoView alloc] init];
    [self.view addSubview:_userInfoView];
    [_userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_userInfoView setCurrentUser:[BBSUIContext shareInstance].currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
