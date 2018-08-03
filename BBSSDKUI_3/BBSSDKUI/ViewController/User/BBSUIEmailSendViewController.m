//
//  BBSUIEmailSendViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIEmailSendViewController.h"
#import "BBSUIEmailSendView.h"
#import "Masonry.h"

@interface BBSUIEmailSendViewController ()

@property (nonatomic, strong) BBSUIEmailSendView *emailSendView;

@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BBSUIEmailSendType sendType;

@end

@implementation BBSUIEmailSendViewController

- (instancetype)initWithEmail:(NSString *)email userName:(NSString *)userName sendType:(BBSUIEmailSendType)sendType
{
    self = [super init];
    if (self) {
        _email = email;
        _userName = userName;
        _sendType = sendType;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.sendType == BBSUIEmailSendTypeRetrievePassword) {
        self.title = @"找回密码";
        
    }else{
        self.title = @"激活邮箱";
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.emailSendView = [[BBSUIEmailSendView alloc] initWithFrame:self.view.bounds email:self.email userName:self.userName sendType:self.sendType];
    [self.view addSubview:self.emailSendView];
    [self.emailSendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(NavigationBar_Height);
        make.right.equalTo(self.view);
        make.bottom.mas_equalTo(-NavigationBar_Height);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.sendType == BBSUIEmailSendTypeNeedIdentity) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
