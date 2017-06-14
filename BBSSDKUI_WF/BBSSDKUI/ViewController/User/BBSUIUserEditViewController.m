//
//  BBSUIUserEditViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/19.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserEditViewController.h"

@interface BBSUIUserEditViewController ()

@property (nonatomic, strong) BBSUIUserEditView *editView;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) BBSUIEditUserInfoType type;

@end

@implementation BBSUIUserEditViewController

- (instancetype)initWithUser:(BBSUser *)user editType:(BBSUIEditUserInfoType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _currentUser = user;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置资料";
    
    self.editView = [[BBSUIUserEditView alloc] initWithFrame:self.view.bounds user:self.currentUser editType:self.type];
    [self.view addSubview:self.editView];
    
    
}

- (void)backButtonHandler:(UIButton *)button
{
    if (self.type == BBSUIEditUserInfoTypeRegister) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
