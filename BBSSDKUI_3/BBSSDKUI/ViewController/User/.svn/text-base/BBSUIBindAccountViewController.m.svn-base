//
//  BBSUIBindAccountViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/11/22.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBindAccountViewController.h"
#import "Masonry.h"
#import "BBSUIButton.h"
#import <BBSSDK/BBSSDK.h>

@interface BBSUIBindAccountViewController ()

@property (nonatomic, strong) UITextField *nameTf;
@property (nonatomic, strong) UITextField *passwordTf;
@property (nonatomic, strong) UITextField *verifyQuestionTextField;
@property (nonatomic, strong) UITextField *verifyAnswerTextField;
@property (nonatomic, strong) UIView *loginBackGround;

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
    
    self.loginBackGround =
    ({
        UIView *loginBackGround = [[UIView alloc] init];
        loginBackGround.layer.cornerRadius = 7;
        loginBackGround.clipsToBounds = YES;
        [self.view addSubview:loginBackGround];
        
        [loginBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(50);
            make.right.equalTo(self.view).offset(-50);
            make.top.equalTo(label).offset(23);
            make.height.equalTo(@102);
        }];
        loginBackGround ;
    });
    
    self.nameTf =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        usernameTextField.delegate = self;
        usernameTextField.placeholder = @"用户名/邮箱";
        usernameTextField.font = [UIFont systemFontOfSize:13];
        usernameTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:usernameTextField];
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_loginBackGround.mas_bottom).offset(23);
            make.left.equalTo(_loginBackGround);
            make.right.equalTo(_loginBackGround);
            make.height.equalTo(@50);
        }];
        usernameTextField ;
    });
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [_loginBackGround addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameTf.mas_bottom);
        make.left.right.equalTo(_loginBackGround);
        make.height.equalTo(@1);
    }];
    
    self.passwordTf =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.delegate = self;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.placeholder = @"密码";
        passwordTextField.font = [UIFont systemFontOfSize:13];
        passwordTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:passwordTextField];
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom);
            make.left.equalTo(_loginBackGround);
            make.right.equalTo(_loginBackGround);
            make.height.equalTo(@50);
        }];
        
        passwordTextField ;
    });
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [_loginBackGround addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_passwordTf.mas_bottom);
        make.left.right.equalTo(_loginBackGround);
        make.height.equalTo(@1);
    }];
    
    
    self.verifyQuestionTextField =
    ({
        UITextField *verifyQuestionTextField = [[UITextField alloc] init];
        verifyQuestionTextField.delegate = self;
        
        verifyQuestionTextField.rightViewMode = UITextFieldViewModeAlways;
        verifyQuestionTextField.rightView =
        ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 30, 30);
            [btn addTarget:self action:@selector(showQuestions:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage BBSImageNamed:@"/Common/LoginShowQuestions@2x.png"] forState:UIControlStateNormal];
            btn;
        });
        
        verifyQuestionTextField.placeholder = @"验证问题(未设置可忽略)";
        verifyQuestionTextField.font = [UIFont systemFontOfSize:13];
        verifyQuestionTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:verifyQuestionTextField];
        [verifyQuestionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_passwordTf.mas_bottom);
            make.left.equalTo(_loginBackGround);
            make.right.equalTo(_loginBackGround);
            make.height.equalTo(@50);
        }];
        verifyQuestionTextField ;
    });
    
    UIView *line3 = [[UIView alloc] init];
    line3.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [_loginBackGround addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_verifyQuestionTextField.mas_bottom);
        make.left.right.equalTo(_loginBackGround);
        make.height.equalTo(@1);
    }];
    
    self.verifyAnswerTextField =
    ({
        UITextField *verifyAnswerTextField = [[UITextField alloc] init];
        verifyAnswerTextField.delegate = self;
        
        verifyAnswerTextField.placeholder = @"验证答案";
        verifyAnswerTextField.font = [UIFont systemFontOfSize:13];
        verifyAnswerTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:verifyAnswerTextField];
        [verifyAnswerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line3.mas_bottom).offset(2);
            make.left.equalTo(_loginBackGround);
            make.right.equalTo(_loginBackGround);
            make.height.equalTo(@44);
        }];
        verifyAnswerTextField ;
    });
    
    UIView *line4 = [[UIView alloc] init];
    line4.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [_loginBackGround addSubview:line4];
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_verifyAnswerTextField.mas_bottom);
        make.left.right.equalTo(_loginBackGround);
        make.height.equalTo(@1);
    }];
    
    
    
    
    
//    UITextField *nameTf = [UITextField new];
//    nameTf.font = [UIFont systemFontOfSize:14];
//    nameTf.borderStyle = UITextBorderStyleNone;
//    nameTf.placeholder = @"用户名/邮箱";
//    _nameTf = nameTf;
//
//    UIView *line1 = [UIView new];
//    line1.backgroundColor = [UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:0.5];
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
//    [self.view addSubview:label];
//    [self.view addSubview:nameTf];
//    [self.view addSubview:line1];
//    [self.view addSubview:passwordTf];
//    [self.view addSubview:line2];
//
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@50);
//        make.right.equalTo(@-50);
//        make.top.equalTo(@114);
//    }];
//
//    [nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(label.mas_bottom).offset(23);
//        make.left.equalTo(@50);
//        make.right.equalTo(@-50);
//        make.height.equalTo(@46);
//    }];
//
//    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(nameTf);
//        make.top.equalTo(nameTf.mas_bottom).offset(0);
//        make.height.equalTo(@1);
//    }];
//
//    [passwordTf mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.height.equalTo(nameTf);
//        make.top.equalTo(line1.mas_bottom).offset(0);
//    }];
//
//    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(nameTf);
//        make.top.equalTo(passwordTf.mas_bottom).offset(0);
//        make.height.equalTo(@1);
//    }];
    
    NSArray *colors = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
    BBSUIButton *bindBtn = [[BBSUIButton alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width - 100, 45) FromColorArray:colors ByGradientType:leftToRight];
    [bindBtn setTitle:@"立即绑定" forState:UIControlStateNormal];
    [bindBtn addTarget:self action:@selector(_bindAccountAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bindBtn];
    
    [bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_nameTf);
        make.top.equalTo(line2.mas_bottom).offset(54);
        make.height.equalTo(@45);
    }];
    
    UIButton *enterBtn = [UIButton new];
    [enterBtn setTitle:@"直接进入" forState:UIControlStateNormal];
    [enterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    [BBSSDK authLoginWithOpenid:_params[@"openID"]
                        unionid:_params[@"rawData"][@"unionid"]
                       authType:_params[@"authTypeName"]
                      createNew:@0
                       userName:_nameTf.text
                          email:nil
                       password:_passwordTf.text
                     questionId:nil
                         answer:nil
                         result:^(BBSUser *user, id res, NSError *error) {
        
    }];
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
