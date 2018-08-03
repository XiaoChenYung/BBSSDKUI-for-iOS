//
//  BBSUIUserInfoViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserInfoViewController.h"
#import "BBSUIUserInfoView.h"
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
    
    self.title = @"个人资料";
    _userInfoView = [[BBSUIUserInfoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_userInfoView];
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
