//
//  BBSUIUserMeInfoViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/27.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserMeInfoViewController.h"
#import "BBSUIUserOtherInfoView.h"
#import "BBSUIInformationViewController.h"
#import "BBSUIContext.h"

@interface BBSUIUserMeInfoViewController ()

@property (nonatomic, strong) BBSUIUserOtherInfoView *userOtherView;

@property (nonatomic, strong) BBSUser *user;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, assign) BOOL needRequestData;

@end

@implementation BBSUIUserMeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
    _needRequestData = NO;
    
    [self setInformationImage];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_needRequestData) {
        __weak typeof (self) weakSelf = self;
        [_userOtherView refreshData:^(NSInteger informationCount) {
            [weakSelf setInformationImage];
        }];
    }
    
    _needRequestData = YES;
}

- (void)setInformationImage{
    if ([[BBSUIContext shareInstance].currentUser.notices integerValue] > 0) {
        [_rightButton setImage:[UIImage BBSImageNamed:@"User/information2@2x.png"] forState:UIControlStateNormal];
    }else{
        [_rightButton setImage:[UIImage BBSImageNamed:@"User/information@2x.png"] forState:UIControlStateNormal];
    }
}

- (instancetype)initWithUser:(BBSUser *)user
{
    self = [super init];
    if (self) {
        self.user = user;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configUI {
    self.title = @"个人中心";
    
    _userOtherView = [[BBSUIUserOtherInfoView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height - 44) :UserTypeMe];

    [self.view addSubview:_userOtherView];
    
    [self setupRightBarButton];
}

- (void)informationAction {
    BBSUIInformationViewController *vc = [[BBSUIInformationViewController alloc] init];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)setupRightBarButton
{
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [_rightButton setImage:[UIImage BBSImageNamed:@"User/information@2x.png"]forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(informationAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem= editButtonItem;
}

- (void)email:(UIButton *)sender {
    
}

@end
