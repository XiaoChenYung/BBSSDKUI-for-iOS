//
//  BBSUIRetrievePasswordViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/5/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIRetrievePasswordViewController.h"
#import "BBSUIRetrievePasswordView.h"
#import "Masonry.h"

@interface BBSUIRetrievePasswordViewController ()

@property (nonatomic, strong) BBSUIRetrievePasswordView *retrievePasswordView;

@end

@implementation BBSUIRetrievePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"找回密码";
    [self.view setBackgroundColor:DZSUIColorFromHex(0x5B7EF0)];
    
    self.retrievePasswordView = [[BBSUIRetrievePasswordView alloc] init];
    [self.view addSubview:self.retrievePasswordView];
    [self.retrievePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(64);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
