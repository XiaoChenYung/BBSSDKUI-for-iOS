//
//  BBSUIFansViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIFansViewController.h"

@interface BBSUIFansViewController ()

@property (nonatomic, strong) BBSUIFansView *fansView;

@end

@implementation BBSUIFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_fansViewType == BBSUIFansTypeFirendsMe) {
        self.title = @"我的关注";
    }else if (_fansViewType == BBSUIFansTypeFollowersMe){
        self.title = @"我的粉丝";
    }else if (_fansViewType == BBSUIFansTypeFirendsOther){
        self.title = @"他的关注";
    }else if (_fansViewType == BBSUIFansTypeFollowersOther){
        self.title = @"他的粉丝";
    }
    
    _fansView = [[BBSUIFansView alloc] initWithFrame: self.view.bounds tpye:_fansViewType currentUser:_currentUser];
    [self.view addSubview:_fansView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置数据
    [_fansView refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
