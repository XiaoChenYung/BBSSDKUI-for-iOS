//
//  BBSUIHistoryViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIHistoryViewController.h"
#import "Masonry.h"

@interface BBSUIHistoryViewController ()

@end

@implementation BBSUIHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configUI {
    self.title = @"浏览记录";
    
    _threadVC = [[BBSUIThreadListTableViewController alloc]initWithForum:nil selectType:BBSUIThreadSelectTypeLatest pageType:PageTypeHistory];
    _threadVC.view.frame = CGRectMake(0, 40, DZSUIScreen_width, DZSUIScreen_height - 40);
    [self.view addSubview:_threadVC.tableView];
    [self addChildViewController:_threadVC];
    
    [_threadVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.bottom.equalTo(@0);
    }];
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
