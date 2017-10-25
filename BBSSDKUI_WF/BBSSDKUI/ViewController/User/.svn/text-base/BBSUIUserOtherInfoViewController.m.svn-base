//
//  BBSUIUserOtherInfoViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserOtherInfoViewController.h"
#import "BBSUIUserOtherInfoView.h"

@interface BBSUIUserOtherInfoViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) BBSUIUserOtherInfoView *userOtherView;

@property (nonatomic, assign) NSInteger authorid;

@end

@implementation BBSUIUserOtherInfoViewController

- (instancetype)initWithAuthorid:(NSInteger)authorid
{
    self = [super init];
    if (self) {
        self.authorid = authorid;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [MOBFViewController currentViewController].navigationController.navigationBar.hidden = YES;
    [_userOtherView refreshData:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [MOBFViewController currentViewController].navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configUI {
    _userOtherView = [[BBSUIUserOtherInfoView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height + NavigationBar_Height) :UserTypeOther];
    _userOtherView.authorid = self.authorid;
    [self.view addSubview:_userOtherView];
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
