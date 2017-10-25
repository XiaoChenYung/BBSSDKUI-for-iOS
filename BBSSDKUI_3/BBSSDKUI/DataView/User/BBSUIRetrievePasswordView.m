//
//  BBSUIRetrievePasswordView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/5/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIRetrievePasswordView.h"
#import "Masonry.h"
#import "BBSUIEmailSendViewController.h"
#import <MOBFoundation/MOBFViewController.h>
#import <BBSSDK/BBSSDK.h>
#import "NSString+BBSUIRegular.h"
#import "BBSUIButton.h"

@interface BBSUIRetrievePasswordView ()

@property (nonatomic, strong) UITextField *userNameTextField;

@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, strong) UIView *horizontalView;

@property (nonatomic, strong) BBSUIButton *commitButton;

@property (nonatomic, strong) UIView *contentView;

@end

@implementation BBSUIRetrievePasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self configureUI];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI
{
    self.userNameTextField = [UITextField new];
    self.userNameTextField.delegate = self;
    
//    self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
//    self.userNameTextField.leftView =
//    ({
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:@"/Common/LoginUser@2x.png"]];
//        [view addSubview:imageView];
//        view;
//    });
//    
//    self.userNameTextField.placeholder = @"用户名";
//    [self addSubview:self.userNameTextField];
//    [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(36);
//        make.left.equalTo(self).offset(15);
//        make.right.equalTo(self).offset(-15);
//        make.height.equalTo(@49);
//    }];
//    
//    self.horizontalView = [[UIView alloc] init];
//    self.horizontalView.backgroundColor = [UIColor darkGrayColor];
//    self.horizontalView.alpha = 0.25;
//    [self addSubview:self.horizontalView];
//    [self.horizontalView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.userNameTextField.mas_bottom);
//        make.left.equalTo(self).offset(15);
//        make.right.equalTo(self).offset(-15);
//        make.height.equalTo(@1);
//    }];
//    
//    self.emailTextField = [[UITextField alloc] init];
//    [self addSubview:self.emailTextField];
//    self.emailTextField.delegate = self;
//    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
//    self.emailTextField.leftView =
//    ({
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:@"/Common/RegistEmail@2x.png"]];
//        [view addSubview:imageView];
//        view;
//    });
//    self.emailTextField.placeholder = @"请输入注册邮箱";
//    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.horizontalView.mas_bottom);
//        make.left.equalTo(self).offset(15);
//        make.right.equalTo(self).offset(-15);
//        make.height.equalTo(@49);
//    }];
//    
//    
//    UIView *horizontalView2 = [UIView new];
//    [self addSubview:horizontalView2];
//    horizontalView2.backgroundColor = [UIColor darkGrayColor];
//    horizontalView2.alpha = 0.25;
//    [self addSubview:horizontalView2];
//    [horizontalView2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.emailTextField.mas_bottom);
//        make.left.equalTo(self).offset(15);
//        make.right.equalTo(self).offset(-15);
//        make.height.equalTo(@1);
//    }];
    
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(50);
        make.right.equalTo(self).offset(-50);
        make.top.equalTo(self).offset(31);
        make.height.equalTo(@102);
    }];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 7;
    self.contentView.clipsToBounds = YES;
    
    self.userNameTextField =
    ({
        UITextField *usernameTextField = [[UITextField alloc] init];
        [usernameTextField setFont:[UIFont systemFontOfSize:14]];
        usernameTextField.placeholder = @"用户名";
        [self.contentView addSubview:usernameTextField];
        
        [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(0);
            make.right.equalTo(self.contentView).offset(0);
            make.height.equalTo(@50);
        }];
        usernameTextField ;
    });
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [self.contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameTextField.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
    
    self.emailTextField =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.placeholder = @"请输入注册邮箱";
        [passwordTextField setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:passwordTextField];
        
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line1.mas_bottom);
            make.left.equalTo(self.contentView).offset(0);
            make.right.equalTo(self.contentView).offset(0);
            make.height.equalTo(@50);
        }];
        
        passwordTextField ;
    });

    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = DZSUIColorFromHex(0xD8D8D8);
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
    
//    self.commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.commitButton setTitle:@"提交" forState:UIControlStateNormal];
//    [self.commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.commitButton.backgroundColor = DZSUIColorFromHex(0x50A3D3);
//    self.commitButton.layer.cornerRadius = 3.0;
//    [self.commitButton addTarget:self action:@selector(commitButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.commitButton];
//    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(15);
//        make.right.equalTo(self).offset(-15);
//        make.top.equalTo(horizontalView2.mas_bottom).offset(28);
//        make.height.equalTo(@42);
//    }];
    
    self.commitButton =
    ({
        NSArray *colroArray = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
        BBSUIButton *commitButton = [[BBSUIButton alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width - 100, 50) FromColorArray:colroArray ByGradientType:leftToRight];
        [commitButton setTitle:@"提交" forState:UIControlStateNormal];
        [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        commitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        commitButton.backgroundColor = [UIColor whiteColor];
        commitButton.layer.cornerRadius = 5.0;
        [commitButton addTarget:self action:@selector(commitButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:commitButton];
        [commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView.mas_bottom).offset(60);
            make.height.equalTo(@45);
        }];
        commitButton ;
    });
}

- (void)commitButtonHandler:(UIButton *)button
{
    if (![self.userNameTextField.text isUserName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不符合格式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (![self.emailTextField.text isEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱不符合格式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [BBSSDK resetPasswordWithEmail:self.emailTextField.text userName:self.userNameTextField.text result:^(NSError *error) {
        if (!error) {
            
            BBSUIEmailSendViewController *emailSendVC = [[BBSUIEmailSendViewController alloc] initWithEmail:self.emailTextField.text userName:self.userNameTextField.text sendType:BBSUIEmailSendTypeRetrievePassword];
            if ([MOBFViewController currentViewController].navigationController) {
                [[MOBFViewController currentViewController].navigationController pushViewController:emailSendVC animated:YES];
            }
        }else{
            
            NSLog(@"error = %@", error);
            
            //重新认证
            if (error.code == 9001207) {
                
                [BBSSDK sendIdentyEmail:self.emailTextField.text userName:self.userNameTextField.text result:^(NSError *error) {
                    
                    if (!error) {
                        BBSUIEmailSendViewController *emailSendVC = [[BBSUIEmailSendViewController alloc] initWithEmail:self.emailTextField.text userName:self.userNameTextField.text sendType:BBSUIEmailSendTypeNeedIdentity];
                        if ([MOBFViewController currentViewController].navigationController) {
                            [[MOBFViewController currentViewController].navigationController pushViewController:emailSendVC animated:YES];
                        }
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.userInfo[@"description"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.userInfo[@"description"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                
            }
        }
    }];
    
    
//    [BBSSDK sendIdentyEmail:self.emailTextField.text userName:self.userNameTextField.text result:^(NSError *error) {
//        
//        if (!error) {
//            BBSUIEmailSendViewController *emailSendVC = [[BBSUIEmailSendViewController alloc] initWithEmail:self.emailTextField.text userName:self.userNameTextField.text sendType:BBSUIEmailSendTypeRetrievePassword];
//            if ([MOBFViewController currentViewController].navigationController) {
//                [[MOBFViewController currentViewController].navigationController pushViewController:emailSendVC animated:YES];
//            }
//        }else{
//            NSLog(@"error = %@", error);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.userInfo[@"description"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }];
}

@end
