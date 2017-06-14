//
//  BBSUIEmailSendView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIEmailSendView.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import <MOBFoundation/MOBFViewController.h>
#import "BBSUIUserEditViewController.h"
#import "BBSUIProcessHUD.h"

@interface BBSUIEmailSendView ()

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UILabel *emailAddressLabel;

@property (nonatomic, strong) UILabel *resendEmailLabel;

@property (nonatomic, strong) UIButton *controlButton;

@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BBSUIEmailSendType sendType;

@end

@implementation BBSUIEmailSendView

- (instancetype)initWithFrame:(CGRect)frame email:(NSString *)email userName:(NSString *)userName sendType:(BBSUIEmailSendType)sendType
{
    self = [super initWithFrame:frame];
    if (self) {
        _email = email;
        _sendType = sendType;
        _userName = userName;
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
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
    self.messageLabel = [UILabel new];
    [self addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(30);
        make.left.equalTo(self).with.offset(15);
        make.right.equalTo(self).with.offset(-15);
    }];
    if (self.sendType == BBSUIEmailSendTypeNeedIdentity) {
        [self.messageLabel setText:@"您的邮箱尚未验证，请查收激活邮件，进行验证激活。"];
    }else if (self.sendType == BBSUIEmailSendTypeRetrievePassword)
    {
        [self.messageLabel setText:@"系统已经向该邮箱发送了一封找回密码邮件，请查收邮件，进行验证。"];
    }else{
        [self.messageLabel setText:@"系统已经向该邮箱发送了一封激活邮件，请查收邮件，进行验证。"];
    }
    [self.messageLabel setNumberOfLines:2];
    
    self.emailAddressLabel = [UILabel new];
    [self addSubview:self.emailAddressLabel];
    [self.emailAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).with.offset(30);
        make.left.equalTo(self).with.offset(15);
        make.right.equalTo(self).with.offset(-15);
    }];
    if (self.email) {
        [self.emailAddressLabel setAttributedText:[self adressAttributedStringWithString:[NSString stringWithFormat:@"邮箱地址 %@", self.email] range:NSMakeRange(0, 4)]];
    }
    [self.emailAddressLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.resendEmailLabel = [UILabel new];
    [self addSubview:self.resendEmailLabel];
    [self.resendEmailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailAddressLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(15);
        make.right.equalTo(self).with.offset(-15);
    }];
    NSString *content = @"没有收到邮件？点击这里重发";
    NSRange contentRange = {7,[content length] - 7};
    self.resendEmailLabel.attributedText = [self resendEmailAttributedStringWithString:content range:contentRange];
    [self.resendEmailLabel setTextAlignment:NSTextAlignmentCenter];
    [self.resendEmailLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resendEmailTouched:)];
    tap.numberOfTapsRequired = 1;
    [self.resendEmailLabel addGestureRecognizer:tap];

    self.controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.controlButton];
    [self.controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resendEmailLabel.mas_bottom).with.offset(40);
        make.left.mas_equalTo(@15);
        make.right.mas_equalTo(@(-15));
        make.height.mas_equalTo(@42);
    }];
    [self.controlButton addTarget:self action:@selector(controlButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlButton setBackgroundColor:DZSUIColorFromHex(0x50A3D3)];
    [self.controlButton.layer setCornerRadius:3];
    [self.controlButton.layer masksToBounds];
    [self.controlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.controlButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    if (self.sendType == BBSUIEmailSendTypeRetrievePassword) {
        [self.controlButton setTitle:@"返回登录" forState:UIControlStateNormal];
    }else{
        [self.controlButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

- (NSMutableAttributedString *)adressAttributedStringWithString:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DZSUIColorFromHex(0xAAAAAA) range:range];
    
    return attributedString;
}

- (NSMutableAttributedString *)resendEmailAttributedStringWithString:(NSString *)string range:(NSRange)range
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DZSUIColorFromHex(0xC6C6C6) range:NSMakeRange(0, string.length - range.location + 1)];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DZSUIColorFromHex(0x30B6FC) range:range];
    
    return attributedString;
}

- (void)resendEmailTouched:(UITapGestureRecognizer *)tap
{
    if (self.sendType == BBSUIEmailSendTypeRetrievePassword) {
        [BBSSDK resetPasswordWithEmail:self.email userName:self.userName token:nil result:^(NSError *error) {
            
            if (!error) {
                [[MOBFViewController currentViewController].navigationController popToRootViewControllerAnimated:YES];
            }
            
        }];
    }else{
        [BBSSDK sendIdentyEmail:self.email userName:self.userName result:^(NSError *error) {
            
            if (error) {
                if (error.code == 9001206) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮件发送成功，请前往邮箱进行验证激活" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"激活发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }else{
                [[MOBFViewController currentViewController].navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    
    
}

- (void)controlButtonHandler:(UIButton *)button
{
    UINavigationController *currentNavVC = [MOBFViewController currentViewController].navigationController;
    if (self.sendType == BBSUIEmailSendTypeRetrievePassword) {
        if (currentNavVC) {
            [currentNavVC popToRootViewControllerAnimated:YES];
        }
    }else if(self.sendType == BBSUIEmailSendTypeRegister)
    {
        if (currentNavVC) {
//            BBSUIUserEditViewController *userEditVC = [[BBSUIUserEditViewController alloc] initWith];
//            [currentNavVC pushViewController:userEditVC animated:YES];
            [currentNavVC popToRootViewControllerAnimated:YES];
        }
    }else if (self.sendType == BBSUIEmailSendTypeNeedIdentity)
    {
        if (currentNavVC) {
            //            BBSUIUserEditViewController *userEditVC = [[BBSUIUserEditViewController alloc] initWith];
            //            [currentNavVC pushViewController:userEditVC animated:YES];
            [currentNavVC popViewControllerAnimated:YES];
        }
    }
}



@end
