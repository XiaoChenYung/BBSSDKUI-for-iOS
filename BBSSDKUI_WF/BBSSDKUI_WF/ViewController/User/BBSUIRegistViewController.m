//
//  BBSUIRegistViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIRegistViewController.h"
#import "Masonry.h"
#import "NSString+BBSUIRegular.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIContext.h"
#import "BBSUIEmailSendViewController.h"
#import "BBSUIUserEditViewController.h"

@interface BBSUIRegistViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *registBackGround;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIButton *registBtn;
@property (nonatomic, strong) UIButton *topAlertLabel;
@property (nonatomic, strong) UIButton *bottomAlertLabel;

@end

@implementation BBSUIRegistViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"注册";
    [self configUI];
}

- (void)configUI
{
    self.view.backgroundColor = DZSUIColorFromHex(0x5B7EF0);
    
    self.registBackGround =
    ({
        UIView *registBackGround = [[UIView alloc] init];
        registBackGround.backgroundColor = [UIColor whiteColor];
        registBackGround.layer.cornerRadius = 5;
        registBackGround.layer.borderWidth = 1;
        registBackGround.layer.borderColor = DZSUIColorFromHex(0xECECEC).CGColor;
        
        [self.view addSubview:registBackGround];
        [registBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view).offset(95);
            make.height.equalTo(@154);
        }];
        registBackGround;
    });

    self.usernameTextField =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        usernameTextField.delegate = self ;
        usernameTextField.placeholder = @"用户名";
        [usernameTextField setFont:[UIFont systemFontOfSize:13]];
        [self.view addSubview:usernameTextField];
        
        usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        usernameTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Avartar.png"];
            imageView;
        });
        
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_registBackGround);
            make.left.equalTo(_registBackGround).offset(15);
            make.right.equalTo(_registBackGround).offset(-15);
            make.height.equalTo(@50);
        }];
        usernameTextField ;
    });
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = DZSUIColorFromHex(0xECECEC);
    [self.view addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_usernameTextField.mas_bottom);
        make.left.right.equalTo(_registBackGround);
        make.height.equalTo(@1);
    }];
    
    self.emailTextField =
    ({
        UITextField *emailTextField = [[UITextField alloc] init];
        emailTextField.placeholder = @"邮箱";
        [emailTextField setFont:[UIFont systemFontOfSize:13]];
        [self.view addSubview:emailTextField];
        
        emailTextField.leftViewMode = UITextFieldViewModeAlways;
        emailTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/email@2x.png"];
            imageView;
        });
        
        [emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom);
            make.left.equalTo(_registBackGround).offset(15);
            make.right.equalTo(_registBackGround).offset(-15);
            make.height.equalTo(@50);
        }];
        
        emailTextField ;
    });
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = DZSUIColorFromHex(0xECECEC);
    [_registBackGround addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_emailTextField.mas_bottom);
        make.left.right.equalTo(_registBackGround);
        make.height.equalTo(@1);
    }];
    
    self.passwordTextField =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.secureTextEntry = YES;
        [passwordTextField setFont:[UIFont systemFontOfSize:13]];
        passwordTextField.placeholder = @"密码";
        
        [self.view addSubview:passwordTextField];
        
        passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        passwordTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Key.png"];
            imageView;
        });
        
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line2.mas_bottom).offset(2);
            make.left.equalTo(_registBackGround).offset(15);
            make.right.equalTo(_registBackGround).offset(-15);
            make.height.equalTo(@50);
        }];
        passwordTextField ;
    });
    
    self.registBtn =
    ({
        UIButton *registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [registBtn setTitle:@"注册" forState:UIControlStateNormal];
        [registBtn setTitleColor:DZSUIColorFromHex(0x2D3037) forState:UIControlStateNormal];
        registBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        registBtn.backgroundColor = [UIColor whiteColor];
        registBtn.layer.cornerRadius = 5.0;
        [registBtn addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registBtn];
        [registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_registBackGround);
            make.top.equalTo(_registBackGround.mas_bottom).offset(23);
            make.height.equalTo(@45);
        }];
        registBtn ;
    });
    
    self.bottomAlertLabel =
    ({
        UIButton *alertLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [alertLabel setTitle:@"提示语句:xxxxx" forState:UIControlStateDisabled];
        alertLabel.backgroundColor = DZSUIColorFromHex(0x3C445E);
        alertLabel.titleLabel.font = [UIFont systemFontOfSize:13];
        alertLabel.layer.cornerRadius = 17.5 ;
        [self.view addSubview:alertLabel];
        [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-88);
            make.height.equalTo(@35);
            make.width.equalTo(@180);
        }];
        alertLabel.enabled = NO;
        alertLabel.alpha = 0;
        alertLabel ;
    });
    
    self.topAlertLabel =
    ({
        UIButton *alertLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [alertLabel setTitle:@"提示语句:xxxxx" forState:UIControlStateDisabled];
        alertLabel.backgroundColor = [UIColor redColor];
        alertLabel.titleLabel.font = [UIFont systemFontOfSize:13];
        alertLabel.layer.cornerRadius = 17.5 ;
        [self.view addSubview:alertLabel];
        [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(88);
            make.height.equalTo(@35);
            make.width.equalTo(@180);
        }];
        alertLabel.enabled = NO;
        alertLabel.alpha = 0;
        alertLabel ;
    });
}

- (void)showBottomAlertWithText:(NSString *)text
{
    [_bottomAlertLabel setTitle:text forState:UIControlStateDisabled];
    
    [UIView animateWithDuration:0.25 animations:^{
        _bottomAlertLabel.alpha = 1 ;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _bottomAlertLabel.alpha = 0 ;
        }];
    });
}

- (void)showTopAlertWithText:(NSString *)text
{
    [_topAlertLabel setTitle:[NSString stringWithFormat:@"   %@   ",text] forState:UIControlStateDisabled];
    
    [UIView animateWithDuration:0.25 animations:^{
        _topAlertLabel.alpha = 1 ;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _topAlertLabel.alpha = 0 ;
        }];
    });
}

#pragma mark - Click Events

- (void)regist:(id)sender
{
    [self.view endEditing:YES];
    
    if (![_usernameTextField.text isUserName])
    {
        [self showBottomAlertWithText:@"用户名格式错误"];
        return ;
    }
    
    if(![_emailTextField.text isEmail])
    {
        [self showBottomAlertWithText:@"邮箱格式错误"];
        return;
    }
    
    if(![_passwordTextField.text isPassword])
    {
        [self showBottomAlertWithText:@"密码格式错误"];
        return;
    }

    [BBSSDK registUserWithUserName:_usernameTextField.text email:_emailTextField.text password:_passwordTextField.text result:^(BBSUser *user, NSError *error) {
        if (!error)
        {
            //登录成功，可以通过BBSUser 或者res拿到数据
            [BBSUIContext shareInstance].currentUser = user ;
            
            BBSUIUserEditViewController *vc = [[BBSUIUserEditViewController alloc] initWithUser:[BBSUIContext shareInstance].currentUser editType:BBSUIEditUserInfoTypeRegister];
            
            [self.navigationController pushViewController:vc animated:YES];
            
            return ;
        }
        
        //需要邮件认证
        if (error.code == 9001206)
        {
            BBSUIEmailSendViewController *vc = [[BBSUIEmailSendViewController alloc] initWithEmail:_emailTextField.text userName:_usernameTextField.text sendType:BBSUIEmailSendTypeNeedIdentity];
            
            [self.navigationController pushViewController:vc animated:YES];
            
            return;
        }
        
        [self showTopAlertWithText:error.userInfo[@"description"]];
        NSLog(@"regist Failed:%@",error);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _usernameTextField)
    {
        NSInteger preChangeLength = textField.text.length-(range.length);
        
        if (preChangeLength + string.length <= 15)
        {
            return YES ;
        }
        else
        {
            return NO ;
        }
    }
    
    return YES ;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
