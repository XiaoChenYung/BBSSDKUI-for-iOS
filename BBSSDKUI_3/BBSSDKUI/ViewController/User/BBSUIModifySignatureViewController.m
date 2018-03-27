//
//  BBSUIModifySignatureViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/27.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIModifySignatureViewController.h"
#import "Masonry.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIContext.h"
#import "NSString+Paragraph.h"

@interface BBSUIModifySignatureViewController ()

@property (nonatomic, strong) UITextField *signatureTextField;

@end

@implementation BBSUIModifySignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSString *sightml = _signatureTextField.text;
//    [sightml stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.SightmlBlock) {
        self.SightmlBlock(sightml);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configUI {
    self.title = @"修改个性签名";
    self.view.backgroundColor = DZSUIColorFromHex(0xeaedf2);
    BBSUser *currentUser = [BBSUIContext shareInstance].currentUser;
    
    CGFloat iphoneXPadding = 0;
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        iphoneXPadding = 30;
    }
    
    
    
    UIView *viewBg = [UIView new];
    viewBg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewBg];
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(@(10 + NavigationBar_Height + iphoneXPadding));
        make.height.equalTo(@50);
    }];
    
    _signatureTextField =
    ({
        UITextField *signature = [UITextField new];
        [viewBg addSubview:signature];
//        signature.text = currentUser.sightml;
        signature.attributedText = [NSString stringWithString:currentUser.sightml fontSize:15 defaultColorValue:@"3C3C3C" lineSpace:0 wordSpace:0];
        
        [signature mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(viewBg);
            make.right.equalTo(@-15);
            make.height.equalTo(@40);
        }];
        
        signature;
    });
    
    [_signatureTextField becomeFirstResponder];
}


@end
