//
//  BBSUIBindAccountViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/11/22.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBindAccountViewController.h"
#import "Masonry.h"
#define THEMEBACKGROUNDCOLOR DZSUIColorFromHex(0xEBEEF3)

@interface BBSUIBindAccountViewController ()

@property (nonatomic, strong) UITextField *nameTf;
@property (nonatomic, strong) UITextField *passwordTf;

@end

@implementation BBSUIBindAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _configure];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)_configure
{
    self.title = @"绑定账号";
    self.view.backgroundColor = THEMEBACKGROUNDCOLOR;
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
//    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    label.textColor = DZSUIColorFromHex(0xACADB8);
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"您如果已通过其他方式注册过本论坛的账号可输入注册的用户名和密码进行绑定";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@50);
        make.right.equalTo(@-50);
        make.top.equalTo(@114);
    }];
    
    UIView *loginBackGround = [[UIView alloc] init];
    loginBackGround.backgroundColor = [UIColor whiteColor];
    loginBackGround.layer.cornerRadius = 7;
    loginBackGround.layer.borderWidth = 1;
    loginBackGround.layer.borderColor = DZSUIColorFromHex(0xD8D8D8).CGColor;
    loginBackGround.clipsToBounds = YES;
    [self.view addSubview:loginBackGround];
    [loginBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(23);
        make.left.equalTo(@50);
        make.right.equalTo(@-50);
        make.height.equalTo(@101);
    }];
    
    self.nameTf =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        [self.view addSubview:usernameTextField];
        
        usernameTextField.placeholder = @"用户名/邮箱";
        usernameTextField.font = [UIFont systemFontOfSize:13];
        usernameTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        usernameTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Avartar.png"];
            imageView;
        });
    
        [loginBackGround addSubview:usernameTextField];
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(loginBackGround);
            make.left.equalTo(loginBackGround).offset(15);
            make.right.equalTo(loginBackGround).offset(-15);
            make.height.equalTo(@50);
        }];
        
        usernameTextField ;
    });
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = [UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:0.5];
    [loginBackGround addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameTf.mas_bottom);
        make.left.right.equalTo(loginBackGround);
        make.height.equalTo(@1);
    }];
    
    self.passwordTf =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.secureTextEntry = YES;
        passwordTextField.placeholder = @"密码";
        passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        passwordTextField.font = [UIFont systemFontOfSize:13];
        passwordTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        passwordTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Key.png"];
            imageView;
        });
        
        [loginBackGround addSubview:passwordTextField];
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom);
            make.left.equalTo(loginBackGround).offset(15);
            make.right.equalTo(loginBackGround).offset(-15);
            make.height.equalTo(@50);
        }];
        
        passwordTextField ;
    });
    
    
    

    
//    UITextField *nameTf = [UITextField new];
//    nameTf.font = [UIFont systemFontOfSize:14];
//    nameTf.borderStyle = UITextBorderStyleNone;
//    nameTf.placeholder = @"用户名/邮箱";
//    _nameTf = nameTf;
//
//
//
//    UITextField *passwordTf = [UITextField new];
//    passwordTf.font = [UIFont systemFontOfSize:14];
//    passwordTf.borderStyle = UITextBorderStyleNone;
//    passwordTf.placeholder = @"密码";
//    passwordTf.secureTextEntry = YES;
//    _passwordTf = passwordTf;
//
//    UIView *line2 = [UIView new];
//    line2.backgroundColor = [UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:0.5];
//
//
//
//    [loginBackGround addSubview:passwordTf];
//    [loginBackGround addSubview:line2];
    
    
    
    
    
    
    
//    [nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@0);
//        make.left.equalTo(@50);
//        make.right.equalTo(@-50);
//        make.height.equalTo(@46);
//    }];
    
    
    
//    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(nameTf);
//        make.top.equalTo(nameTf.mas_bottom).offset(0);
//        make.height.equalTo(@1);
//    }];
    
    
    
//    [passwordTf mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.height.equalTo(nameTf);
//        make.top.equalTo(line1.mas_bottom).offset(0);
//    }];
    
//    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(nameTf);
//        make.top.equalTo(passwordTf.mas_bottom).offset(0);
//        make.height.equalTo(@1);
//    }];
    
    UIButton *bindBtn = [[UIButton alloc] init];
    bindBtn.layer.cornerRadius = 7;
    bindBtn.clipsToBounds = YES;
    [bindBtn setTitle:@"立即绑定" forState:UIControlStateNormal];
    [bindBtn setBackgroundColor:DZSUIColorFromHex(0x6285F6)];
    [bindBtn addTarget:self action:@selector(_bindAccountAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bindBtn];
    
    [bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(loginBackGround);
        make.top.equalTo(loginBackGround.mas_bottom).offset(54);
        make.height.equalTo(@45);
    }];
    
    UIButton *enterBtn = [UIButton new];
    [enterBtn setTitle:@"直接进入" forState:UIControlStateNormal];
    [enterBtn setTitleColor:DZSUIColorFromHex(0x6285F6) forState:UIControlStateNormal];
    enterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [enterBtn addTarget:self action:@selector(_enterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterBtn];
    
    [enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-85);
        make.width.equalTo(@60);
        make.centerX.equalTo(self.view);
    }];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nameTf resignFirstResponder];
    [_passwordTf resignFirstResponder];
}

- (void)_bindAccountAction
{
    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    [SVProgressHUD dismissWithDelay:2.5 completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)_enterAction
{
    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    [SVProgressHUD dismissWithDelay:2.5 completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
@end
