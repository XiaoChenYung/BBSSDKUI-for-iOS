//
//  BBSUIAttentionDynamicViewController.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/12.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIAttentionDynamicViewController.h"
#import "BBSUIThreadListTableViewController.h"
#import "Masonry.h"

@interface BBSUIAttentionDynamicViewController ()

@property (nonatomic, strong) BBSUIThreadListTableViewController *threadVC;

@end

@implementation BBSUIAttentionDynamicViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _configUI];
}

- (void)_configUI {
    self.title = @"关注动态";
    
    _threadVC = [[BBSUIThreadListTableViewController alloc] initWithPageType:PageTypeAttion];
    _threadVC.view.frame = CGRectMake(0, 40, DZSUIScreen_width, DZSUIScreen_height - 40);
    [self.view addSubview:_threadVC.tableView];
    [self addChildViewController:_threadVC];
    
    [_threadVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.bottom.equalTo(@0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
