//
//  NSLoginViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUILoginViewController.h"
#import "Masonry.h"
#import "BBSUIMacro.h"
#import "BBSUIRegistViewController.h"
#import "NSString+BBSUIRegular.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIContext.h"
#import "BBSUIEmailSendViewController.h"
#import "BBSUIRetrievePasswordViewController.h"
#import "BBSUIButton.h"
#import "BBSUIUserEditViewController.h"

#define THEMEBACKGROUNDCOLOR DZSUIColorFromHex(0x6285F6)

@interface BBSUILoginViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *regionView;
@property (nonatomic, strong) UIView *loginBackGround;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UITextField *verifyQuestionTextField;
@property (nonatomic, strong) UITextField *verifyAnswerTextField;

@property (nonatomic, strong) BBSUIButton *loginBtn;

@property (nonatomic, strong) UIButton *registInterface;
@property (nonatomic, strong) UIButton *resetPassword;

@property (nonatomic, strong) UIButton *bottomAlertLabel;
@property (nonatomic, strong) UIButton *topAlertLabel;
@property (nonatomic, strong) UIPickerView *questionPickerView;

@property (nonatomic, assign) NSInteger questionID;
@property (nonatomic, strong) NSArray *questions;

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *tipLabel;

@end


@implementation BBSUILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    self.backButton.hidden = YES;
    [self configUI];
}


- (void)configUI
{
    self.regionView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.regionView];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setImage:[UIImage BBSImageNamed:@"/Common/LoginClose3@2x.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.regionView addSubview:cancel];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-7);
        make.top.equalTo(self.titleLabel);
    }];
    
    self.avatar =
    ({
        UIImageView *avatar = [[UIImageView alloc] init];
        avatar.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
        [self.regionView addSubview:avatar];
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(@52);
            make.width.height.equalTo(@94);
        }];
        
        avatar;
    });
    
    UILabel *label = [UILabel new];
    label.text = @"欢迎您的登录";
    label.font = [UIFont systemFontOfSize:22];
    label.textColor = DZSUIColorFromHex(0x4E4E4E);
    label.textAlignment = NSTextAlignmentCenter;
    self.tipLabel = label;
    [self.regionView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatar.mas_bottom).offset(15);
        make.height.equalTo(@22);
        make.left.right.equalTo(@0);
    }];
    
    self.loginBackGround =
    ({
        UIView *loginBackGround = [[UIView alloc] init];
        loginBackGround.layer.cornerRadius = 7;
        loginBackGround.clipsToBounds = YES;
        [self.regionView addSubview:loginBackGround];
        
        [loginBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(50);
            make.right.equalTo(self.view).offset(-50);
            make.top.equalTo(label).offset(49);
            make.height.equalTo(@102);
        }];
        loginBackGround ;
    });

    self.usernameTextField =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        usernameTextField.delegate = self;
        usernameTextField.placeholder = @"用户名/邮箱";
        usernameTextField.font = [UIFont systemFontOfSize:13];
        usernameTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:usernameTextField];
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_loginBackGround);
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
        make.top.equalTo(_usernameTextField.mas_bottom);
        make.left.right.equalTo(_loginBackGround);
        make.height.equalTo(@1);
    }];
    
    self.passwordTextField =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.delegate = self;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.placeholder = @"密码";
        passwordTextField.font = [UIFont systemFontOfSize:13];
        passwordTextField.textColor = DZSUIColorFromHex(0x6A7081);

        passwordTextField.rightViewMode = UITextFieldViewModeAlways;
        passwordTextField.rightView =
        ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
            [button setTitleColor:DZSUIColorFromHex(0xABAFBA) forState:UIControlStateNormal];
            [button setTitle:@"忘记密码？" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
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
        make.top.equalTo(_passwordTextField.mas_bottom);
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
            make.top.equalTo(_passwordTextField.mas_bottom);
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
    
    self.loginBtn =
    ({
        NSArray *colors = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
        BBSUIButton *loginBtn = [[BBSUIButton alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width - 100, 45) FromColorArray:colors ByGradientType:leftToRight];

        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        loginBtn.layer.cornerRadius = 5.0;
        [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [self.regionView addSubview:loginBtn];
        [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_loginBackGround);
            make.top.equalTo(_loginBackGround.mas_bottom).offset(23);
            make.height.equalTo(@45);
        }];
        
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        
        loginBtn ;
    });
    
    /**
    UILabel *cutLabel = [[UILabel alloc] init];
    cutLabel.text = @"/";
    cutLabel.textColor = DZSUIColorFromHex(0xB1B1B1);
    cutLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:cutLabel];
    [cutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_loginBtn.mas_bottom).offset(24);
    }];
     */
    
    self.registInterface =
    ({
        UIButton *registInterface = [UIButton buttonWithType:UIButtonTypeSystem];
        [registInterface setTitle:@"立即注册" forState:UIControlStateNormal];
        [registInterface addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
        [registInterface setTitleColor:DZSUIColorFromHex(0x2A2B30) forState:UIControlStateNormal];
        registInterface.titleLabel.font = [UIFont systemFontOfSize:16];
        [registInterface addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
        [self.regionView addSubview:registInterface];
        [registInterface mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(35);
            make.size.mas_equalTo(CGSizeMake(100, 16));
        }];
        registInterface ;
    });
    
    /**
    self.resetPassword =
    ({
        UIButton *resetPassword = [UIButton buttonWithType:UIButtonTypeSystem];
        [resetPassword setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [resetPassword addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
        [resetPassword setTitleColor:DZSUIColorFromHex(0xB1B1B1) forState:UIControlStateNormal];
        resetPassword.titleLabel.font = [UIFont systemFontOfSize:16];
        [resetPassword addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resetPassword];
        [resetPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cutLabel.mas_right).offset(21);
            make.centerY.equalTo(cutLabel);
        }];
        resetPassword ;
    });
     */
    
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
        }];
        alertLabel.enabled = NO;
        alertLabel.alpha = 0;
        alertLabel ;
    });
    
    self.questionPickerView =
    ({
        UIPickerView *questionPickerView = [[UIPickerView alloc] init];
        questionPickerView.backgroundColor = [UIColor whiteColor];
        questionPickerView.delegate = self;
        questionPickerView.dataSource = self;
        questionPickerView.showsSelectionIndicator = YES;
        [self.view addSubview:questionPickerView];
        [questionPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@160);
            make.top.equalTo(self.view.mas_bottom);
        }];
        questionPickerView ;
    });
    
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    if (textField == _verifyQuestionTextField)
    {
        return NO ;
    }
    
    if (_verifyAnswerTextField == textField)
    {
        return _questions.count;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        self.tipLabel.hidden = YES;
        self.avatar.hidden = YES;
        
        if (textField == _verifyAnswerTextField)
        {
            self.regionView.frame = CGRectMake(0, - 170, DZSUIScreen_width, self.regionView.frame.size.height);
        }
        else
        {
            self.regionView.frame = CGRectMake(0, - 130, DZSUIScreen_width, self.regionView.frame.size.height);
        }
        
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        self.tipLabel.hidden = NO;
        self.avatar.hidden = NO;
        
        self.regionView.frame = CGRectMake(0, 0, DZSUIScreen_width, self.regionView.frame.size.height);
    }];
    
    return YES;
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1 ;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.questions.count ;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *question = self.questions[row];
    
    if ([question isKindOfClass:NSDictionary.class])
    {
        self.verifyQuestionTextField.text = question[@"question"];
        _questionID = [question[@"questionId"] integerValue];
    }
    
    [self hideQuestions];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *question = self.questions[row];
    
    if ([question isKindOfClass:NSDictionary.class])
    {
        return question[@"question"];
    }
    return @"null";
}

- (void)showQuestions:(id)sender
{
    if (self.questions.count == 0) {
        return;
    }
    [self.view endEditing:YES];
    
    [self.questionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-160);
    }];
    
    [UIView animateWithDuration:0.33 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideQuestions
{
    [self.questionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.33 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Click Events

- (void)forgetPassword:(id)sender
{
    BBSUIRetrievePasswordViewController *retrievePasswordVC = [[BBSUIRetrievePasswordViewController alloc] init];
    [self.navigationController pushViewController:retrievePasswordVC animated:YES];
}

- (void)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (self.cancelLoginBlock) {
            self.cancelLoginBlock();
        }
    }];
}

- (void)login:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *userName = nil;
    NSString *email = nil;
    
    if ([_usernameTextField.text isUserName])
    {
        userName = _usernameTextField.text;
    }
    else if ([_usernameTextField.text isEmail])
    {
        email = _usernameTextField.text;
    }
    else
    {
        [self showBottomAlertWithText:@"用户名/邮箱格式错误"];
        return ;
    }
    
    if(![_passwordTextField.text isPassword])
    {
         [self showBottomAlertWithText:@"密码格式错误"];
        return ;
    }
    
    [SVProgressHUD setStatus:@"正在登陆..."];
    [BBSSDK loginWithUserName:userName email:email password:_passwordTextField.text questionid:_questionID answer:_verifyAnswerTextField.text result:^(BBSUser *user,id res,NSError *error) {
        
        [SVProgressHUD dismiss];
        if (!error)
        {
            NSLog(@"login Sucess，token:%@",user.token);
            //登录成功，可以通过BBSUser 或者res拿到数据
            [BBSUIContext shareInstance].currentUser = user;
            
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            [SVProgressHUD dismissWithDelay:2.5 completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            return ;
        }
        
        if (error.code == 9001205)
        {
            [self showTopAlertWithText:@"请选择安全问题，并正确填写"];
            if ([res isKindOfClass:NSArray.class])
            {
                self.questions = res;
                
                [self.questionPickerView reloadAllComponents];
    
                [_loginBackGround mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@205);
                }];
                
                [UIView animateWithDuration:0.25 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
            return;
        }
        
        if (error.code == 9001206)
        {
            BBSUIEmailSendViewController *vc = [[BBSUIEmailSendViewController alloc] initWithEmail:email userName:userName sendType:BBSUIEmailSendTypeNeedIdentity];
            
            [self.navigationController pushViewController:vc animated:YES];
            
            return;
        }
        
        if (error.code == -1009) {
            [self showTopAlertWithText:@"网络超时"];
            return;
        }
        
        [self showTopAlertWithText:error.userInfo[@"description"]];
        NSLog(@"LoginFailed:%@",error);
        
    }];
}

- (void)regist:(id)sender
{
    BBSUIRegistViewController *reg = [[BBSUIRegistViewController alloc] init];
    BBSUIUserEditViewController * vc = [BBSUIUserEditViewController new];
    
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

@end
