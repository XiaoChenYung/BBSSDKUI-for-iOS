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
#import "BBSUISignInViewController.h"
#import <MOBFoundation/MOBFoundation.h>

//#import "BBSContext.h"




@interface BBSUIUserMeInfoViewController ()

@property (nonatomic, strong) BBSUIUserOtherInfoView *userOtherView;

@property (nonatomic, strong) BBSUser *user;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, assign) BOOL needRequestData;

@property (nonatomic, strong) UIButton *signButton;

/**
 签到的url
 */
@property (nonatomic, strong) NSString *signUrl;

@end

@implementation BBSUIUserMeInfoViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    _needRequestData = NO;
    [self setInformationImage];

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

#pragma mark - init UI
- (void)configUI {
    self.title = @"个人中心";
    _userOtherView = [[BBSUIUserOtherInfoView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height - 44) :UserTypeMe];
    [self.view addSubview:_userOtherView];
    [self setupRightBarButton];
}

- (void)setupRightBarButton
{
    //SignIn
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 72, 30)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc]initWithCustomView:itemView];
    self.navigationItem.rightBarButtonItem = editButtonItem;

    //签到
    _signButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [itemView addSubview:_signButton];
    [_signButton setImage:[UIImage BBSImageNamed:@"User/SignIn.png"]forState:UIControlStateNormal];
    [_signButton addTarget:self action:@selector(informationAction:) forControlEvents:UIControlEventTouchUpInside];
    _signButton.tag = 10;
    
    //消息
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(42,0,30,30)];
    [itemView addSubview:_rightButton];
    [_rightButton setImage:[UIImage BBSImageNamed:@"User/information@2x.png"]forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(informationAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.tag = 11;
}

- (void)informationAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 10://签到
        {
            BBSUISignInViewController *vc = [[BBSUISignInViewController alloc] init];
            [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
        }
            break;
        case 11://消息
        {
            BBSUIInformationViewController *vc = [[BBSUIInformationViewController alloc] init];
            [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
        }
        default:
            break;
    }
}

- (void)email:(UIButton *)sender {
    
}

@end
