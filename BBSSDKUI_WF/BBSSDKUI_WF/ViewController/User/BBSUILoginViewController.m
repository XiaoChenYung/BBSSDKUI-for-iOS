//
//  BBSUILoginViewController.m
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
#import "BBSUIBindAccountViewController.h"
#import "BBSUILBSLocationManager.h"
#import <BBSSDK/BBSSDK+ShareSDK.h>

#define THEMEBACKGROUNDCOLOR DZSUIColorFromHex(0x6285F6)
#define TYPELOGIN self.loginType == BBSLoginTypeLogin

@interface BBSUILoginViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *loginBackGround;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UITextField *verifyQuestionTextField;
@property (nonatomic, strong) UITextField *verifyAnswerTextField;

@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) UIButton *registInterface;
@property (nonatomic, strong) UIButton *resetPassword;

@property (nonatomic, strong) UIButton *bottomAlertLabel;
@property (nonatomic, strong) UIButton *topAlertLabel;
@property (nonatomic, strong) UIPickerView *questionPickerView;

@property (nonatomic, assign) NSInteger questionID;
@property (nonatomic, strong) NSArray *questions;

@end


@implementation BBSUILoginViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = YES;
    self.backButton.hidden = YES;
    self.titleLabel.text = @"登录";
    self.titleLabel.textColor = [UIColor whiteColor];
    [self configUI];
    [[BBSUILBSLocationManager shareManager] startLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (self.loginType == BBSLoginTypeBindAccount)
    {
        self.title = @"绑定账号";
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (self.loginType == BBSLoginTypeBindAccount)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)configUI
{
    UILabel *label = [UILabel new];
    if (self.loginType == BBSLoginTypeLogin)
    {
        self.view.backgroundColor = THEMEBACKGROUNDCOLOR;
    }
    else
    {
        self.view.backgroundColor = DZSUIColorFromHex(0xEBEEF3);
        label.numberOfLines = 0;
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
    }
    
    
    if (self.loginType == BBSLoginTypeLogin)
    {
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setImage:[UIImage BBSImageNamed:@"/Common/LoginClose@2x.png"] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancel];
        [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-7);
            make.top.equalTo(self.titleLabel);
        }];
    }
    
    self.loginBackGround =
    ({
        UIView *loginBackGround = [[UIView alloc] init];
        loginBackGround.backgroundColor = [UIColor whiteColor];
        loginBackGround.layer.cornerRadius = 7;
        loginBackGround.layer.borderWidth = 1;
        loginBackGround.layer.borderColor = DZSUIColorFromHex(0xD8D8D8).CGColor;
        loginBackGround.clipsToBounds = YES;
        [self.view addSubview:loginBackGround];
        
        if (self.loginType == BBSLoginTypeLogin)
        {
            [loginBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).offset(15);
                make.right.equalTo(self.view).offset(-15);
                make.top.equalTo(self.view).offset(95);
                make.height.equalTo(@102);
            }];
        }
        else
        {
            [loginBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(label.mas_bottom).offset(23);
                make.left.equalTo(@50);
                make.right.equalTo(@-50);
                make.height.equalTo(@101);
            }];
        }
        
        loginBackGround ;
    });

    self.usernameTextField =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        usernameTextField.delegate = self;
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
        
        
        [_loginBackGround addSubview:usernameTextField];
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_loginBackGround);
            make.left.equalTo(_loginBackGround).offset(15);
            make.right.equalTo(_loginBackGround).offset(-15);
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
        passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        passwordTextField.font = [UIFont systemFontOfSize:13];
        passwordTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        passwordTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Key.png"];
            imageView;
        });
        
        if (TYPELOGIN)
        {
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
        }
        
        [_loginBackGround addSubview:passwordTextField];
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom);
            make.left.equalTo(_loginBackGround).offset(15);
            make.right.equalTo(_loginBackGround).offset(-15);
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
        
        verifyQuestionTextField.leftViewMode = UITextFieldViewModeAlways;
        verifyQuestionTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Verify.png"];
            imageView;
        });
        
        
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
            make.left.equalTo(_loginBackGround).offset(15);
            make.right.equalTo(_loginBackGround).offset(-15);
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

        verifyAnswerTextField.leftViewMode = UITextFieldViewModeAlways;
        verifyAnswerTextField.leftView =
        ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [UIImage BBSImageNamed:@"Login&Register/Login_Answer.png"];
            imageView;
        });
        
        verifyAnswerTextField.placeholder = @"验证答案";
        verifyAnswerTextField.font = [UIFont systemFontOfSize:13];
        verifyAnswerTextField.textColor = DZSUIColorFromHex(0x6A7081);
        
        [_loginBackGround addSubview:verifyAnswerTextField];
        [verifyAnswerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line3.mas_bottom).offset(2);
            make.left.equalTo(_loginBackGround).offset(15);
            make.right.equalTo(_loginBackGround).offset(-15);
            make.height.equalTo(@44);
        }];
        verifyAnswerTextField ;
    });

    self.loginBtn =
    ({
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (TYPELOGIN)
        {
            [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
            [loginBtn setTitleColor:DZSUIColorFromHex(0x2D) forState:UIControlStateNormal];
            loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            loginBtn.backgroundColor = [UIColor whiteColor];
            loginBtn.layer.cornerRadius = 5.0;
            [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:loginBtn];
            [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_loginBackGround);
                make.top.equalTo(_loginBackGround.mas_bottom).offset(23);
                make.height.equalTo(@45);
            }];
        }
        else
        {
            loginBtn.layer.cornerRadius = 7;
            loginBtn.clipsToBounds = YES;
            [loginBtn setTitle:@"立即绑定" forState:UIControlStateNormal];
            [loginBtn setBackgroundColor:DZSUIColorFromHex(0x6285F6)];
            [loginBtn addTarget:self action:@selector(_bindAccountAction) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:loginBtn];
            [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_loginBackGround);
                make.top.equalTo(_loginBackGround.mas_bottom).offset(54);
                make.height.equalTo(@45);
            }];
        }
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
        if (TYPELOGIN)
        {
            [registInterface setTitle:@"注册新用户" forState:UIControlStateNormal];
            [registInterface addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
            [registInterface setTitleColor:DZSUIColorFromHex(0xFFFFFF) forState:UIControlStateNormal];
            registInterface.titleLabel.font = [UIFont systemFontOfSize:16];
            [registInterface addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:registInterface];
            [registInterface mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(self.loginBtn.mas_bottom).offset(64);
                make.size.mas_equalTo(CGSizeMake(100, 16));
            }];
        }
        else
        {
            [registInterface setTitle:@"直接进入" forState:UIControlStateNormal];
            [registInterface setTitleColor:DZSUIColorFromHex(0x6285F6) forState:UIControlStateNormal];
            registInterface.titleLabel.font = [UIFont systemFontOfSize:14];
            [registInterface addTarget:self action:@selector(_enterAction) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:registInterface];
            
            [registInterface mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@-85);
                make.width.equalTo(@60);
                make.centerX.equalTo(self.view);
            }];
        }
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
    
    if (self.loginType == BBSLoginTypeLogin)
    {
        [self _configThirdLogin];
    }
    
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

- (void)_configThirdLogin
{
    UILabel *title = [UILabel new];
    title.text = @"其他登录方式";
    title.font = [UIFont systemFontOfSize:12];
    title.textColor = DZSUIColorFromHex(0xACADB8);
    [title setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = DZSUIColorFromHex(0xACADB8);
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = DZSUIColorFromHex(0xACADB8);
    
    // qq、微信按钮
    UIView *elementView = [UIView new];
    
    [self.view addSubview:title];
    [self.view addSubview:line1];
    [self.view addSubview:line2];
    [self.view addSubview:elementView];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@12);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(@-100);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@0.5);
        make.centerY.equalTo(title);
        make.right.equalTo(title.mas_left).offset(-13);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(line1);
        make.left.equalTo(title.mas_right).offset(13);
    }];
    
    CGFloat elementViewW = 0;
    NSMutableArray <UIButton *>*marrButton = [NSMutableArray array];
    
    
    NSArray *arrPlatforms = [BBSSDK activePlatformsShareSDK];
    
    NSLog(@"____ %@",arrPlatforms);
    
    if ([arrPlatforms containsObject:@998]
        || [arrPlatforms containsObject:@6]
        || [arrPlatforms containsObject:@24]) // qq
    {
        //                SSDKPlatformTypeQQ
        
        elementViewW += 92;
        UIButton *qqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [qqBtn setImage:[UIImage BBSImageNamed:@"/Login&Register/QQ_login.png"] forState:UIControlStateNormal];
        [qqBtn addTarget:self action:@selector(_qqLoginAction) forControlEvents:UIControlEventTouchUpInside];
        
        [elementView addSubview:qqBtn];
        [marrButton addObject:qqBtn];
    }
    if ([arrPlatforms containsObject:@997]
        || [arrPlatforms containsObject:@22]
        || [arrPlatforms containsObject:@23]) // 微信
    {
        elementViewW += 92;
        UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [wxBtn setImage:[UIImage BBSImageNamed:@"/Login&Register/weixin_login.png"] forState:UIControlStateNormal];
        [wxBtn addTarget:self action:@selector(_wxLoginAction) forControlEvents:UIControlEventTouchUpInside];
        
        [elementView addSubview:wxBtn];
        [marrButton addObject:wxBtn];
    }
    
    
    [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(elementViewW);
        make.height.mas_equalTo(38);
        make.centerX.equalTo(self.view);
        make.top.equalTo(title.mas_bottom).offset(18);
    }];
    
    __block CGFloat buttonL = 27;
    CGFloat buttonWH = 38;
    [marrButton enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.width.height.mas_equalTo(buttonWH);
            make.left.mas_equalTo(buttonL);
        }];
        
        buttonL += 92;
    }];
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

#pragma mark - 登录
- (void)login:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *userName = nil;
    NSString *email = nil;
    
    if ([_usernameTextField.text bbs_isUserName])
    {
        userName = _usernameTextField.text;
    }
    else if ([_usernameTextField.text bbs_isEmail])
    {
        email = _usernameTextField.text;
    }
    else
    {
        [self showBottomAlertWithText:@"用户名/邮箱格式错误"];
        return ;
    }
    
    if(![_passwordTextField.text bbs_isPassword])
    {
         [self showBottomAlertWithText:@"密码格式错误"];
        return ;
    }

    BBSLocationCoordinate *coordinate = [[BBSLocationCoordinate alloc] initWithLatitude:[BBSUILBSLocationManager shareManager].latitude longitude:[BBSUILBSLocationManager shareManager].lontitue];
    
    [SVProgressHUD setStatus:@"正在登陆..."];
    [BBSSDK loginWithUserName:userName email:email password:_passwordTextField.text questionid:_questionID answer:_verifyAnswerTextField.text coordinate:coordinate result:^(BBSUser *user,id res,NSError *error) {
        
//        NSLog(@"/////////////  %@ - %@",user,error);
        
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
        else if (error.code == 9001205)
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
        else if (error.code == 9001206)
        {
            BBSUIEmailSendViewController *vc = [[BBSUIEmailSendViewController alloc] initWithEmail:email userName:userName sendType:BBSUIEmailSendTypeNeedIdentity];
            
            [self.navigationController pushViewController:vc animated:YES];
            
            return;
        }
        else if (error.code == -1009)
        {
            [self showTopAlertWithText:@"暂无网络，请检查你的网络连接"];
            return;
        }
        else if (error.code == 9001201)
        {
            //Error Domain=BBSErrorDomain Code=9001201 "(null)" UserInfo={description=用户名或密码不正确或用户状态异常, code=9001201}
            [self showTopAlertWithText:@"用户名或密码不正确或用户状态异常"];
            return;
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
            return;
        }
        
        //======
//        if (error.code == 9001205)
//        {
//            [self showTopAlertWithText:@"请选择安全问题，并正确填写"];
//            if ([res isKindOfClass:NSArray.class])
//            {
//                self.questions = res;
//
//                [self.questionPickerView reloadAllComponents];
//
//                [_loginBackGround mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.height.equalTo(@205);
//                }];
//
//                [UIView animateWithDuration:0.25 animations:^{
//                    [self.view layoutIfNeeded];
//                }];
//            }
//            return;
//        }
//
//        if (error.code == 9001206)
//        {
//            BBSUIEmailSendViewController *vc = [[BBSUIEmailSendViewController alloc] initWithEmail:email userName:userName sendType:BBSUIEmailSendTypeNeedIdentity];
//
//            [self.navigationController pushViewController:vc animated:YES];
//
//            return;
//        }
//
//        if (error.code == -1009) {
//            [self showTopAlertWithText:@"暂无网络，请检查你的网络连接"];
//            return;
//        }
//
//        [self showTopAlertWithText:error.userInfo[@"description"]];
        NSLog(@"LoginFailed:%@",error);
        
    }];
}

- (void)_qqLoginAction
{
    // type qq传1 微信传2
    [self _authLoginWithType:1];
}

- (void)_wxLoginAction
{
    [self _authLoginWithType:2];
}

- (void)_authLoginWithType:(NSInteger)type
{
    NSInteger authType = 0;
    NSString *authTypeName;
    if (type == 1)
    {
        authType = 998;
        authTypeName = @"qq";
    }
    else if (type == 2)
    {
        authType = 997;
        authTypeName = @"wechat";
    }
    [SVProgressHUD show];
    
    [BBSSDK authLoginWithAuthType:authTypeName result:^(NSInteger state,BBSShareUser *shareUser, NSError *error) {
        if (error)
        {
            NSLog(@"_________   %@", error);
            [SVProgressHUD dismiss];
            if (error.code == -1009)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"暂无网络，请检查你的网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            return;
        }
        else
        {
            NSString *openID = shareUser.uid;
            NSString *nickName = shareUser.nickname;
            NSDictionary *rawData = shareUser.rawData;
            
            if (!openID)
            {
                [SVProgressHUD dismiss];
                return;
            }
            
            BBSLocationCoordinate *coordinate = [[BBSLocationCoordinate alloc] initWithLatitude:[BBSUILBSLocationManager shareManager].latitude longitude:[BBSUILBSLocationManager shareManager].lontitue];
            NSLog(@"rawData = %@  %@",rawData, openID);
            [BBSSDK authLoginWithOpenid:openID
                                unionid:rawData[@"unionid"]
                               authType:authTypeName
                              createNew:nil
                               userName:nickName
                                  email:nil
                               password:nil
                             questionId:nil
                                 answer:nil
                             coordinate:coordinate
                                 result:^(BBSUser *user, id res, NSError *error) {
                                     
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
                                     else if (error.code == 900613)
                                     {
                                         NSDictionary *params = @{@"openID": openID,
                                                                  @"rawData": rawData,
                                                                  @"nickName": nickName,
                                                                  @"authTypeName": authTypeName
                                                                  };
                                         
                                         // 绑定
                                         BBSUILoginViewController *bindVC = [BBSUILoginViewController new];
                                         bindVC.loginType = BBSLoginTypeBindAccount;
                                         bindVC.params = params;
                                         [self.navigationController pushViewController:bindVC animated:YES];
                                     }
                                     else
                                     {
                                         [self showTopAlertWithText:error.userInfo[@"description"]];
                                     }
                                     
                                 }];
            
        }
        
    }];
}

- (void)_bindAccountAction
{
    [self.view endEditing:YES];
    
    NSString *userName = nil;
    NSString *email = nil;
    
    if ([_usernameTextField.text bbs_isUserName])
    {
        userName = _usernameTextField.text;
    }
    else if ([_usernameTextField.text bbs_isEmail])
    {
        email = _usernameTextField.text;
    }
    else
    {
        [self showBottomAlertWithText:@"用户名/邮箱格式错误"];
        return ;
    }
    
    if(![_passwordTextField.text bbs_isPassword])
    {
        [self showBottomAlertWithText:@"密码格式错误"];
        return ;
    }
    
    [SVProgressHUD show];
    BBSLocationCoordinate *coordinate = [[BBSLocationCoordinate alloc] initWithLatitude:[BBSUILBSLocationManager shareManager].latitude longitude:[BBSUILBSLocationManager shareManager].lontitue];
    [BBSSDK authLoginWithOpenid:_params[@"openID"]
                        unionid:_params[@"rawData"][@"unionid"]
                       authType:_params[@"authTypeName"]
                      createNew:@0
                       userName:userName
                          email:email
                       password:_passwordTextField.text
                     questionId:@(_questionID)
                         answer:_verifyAnswerTextField.text
                     coordinate:coordinate
                         result:^(BBSUser *user, id res, NSError *error) {
                             
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

- (void)_enterAction
{
    [SVProgressHUD show];
    BBSLocationCoordinate *coordinate = [[BBSLocationCoordinate alloc] initWithLatitude:[BBSUILBSLocationManager shareManager].latitude longitude:[BBSUILBSLocationManager shareManager].lontitue];
    [BBSSDK authLoginWithOpenid:_params[@"openID"]
                        unionid:_params[@"rawData"][@"unionid"]
                       authType:_params[@"authTypeName"]
                      createNew:@1
                       userName:nil
                          email:nil
                       password:nil
                     questionId:nil
                         answer:nil
                     coordinate:coordinate
                         result:^(BBSUser *user, id res, NSError *error) {
                             
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
