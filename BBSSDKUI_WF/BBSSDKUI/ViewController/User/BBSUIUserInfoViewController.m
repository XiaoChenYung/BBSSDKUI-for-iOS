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
    self.title = @"我的";
    
    _userInfoView = [[BBSUIUserInfoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_userInfoView];
    
    self.editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(eidtButtonHandler:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
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

- (void)eidtButtonHandler:(UIBarButtonItem *)button
{
    BBSUIUserEditViewController *editViewController = [[BBSUIUserEditViewController alloc] initWithUser:self.user editType:BBSUIEditUserInfoTypeEdit];
    [self.navigationController pushViewController:editViewController animated:YES];
}

@end
