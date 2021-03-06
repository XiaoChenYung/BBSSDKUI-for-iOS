//
//  BBSUIBaseUserViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/6/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseUserViewController.h"
#import "Masonry.h"

@interface BBSUIBaseUserViewController ()

@end

@implementation BBSUIBaseUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel =
    ({
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"标题";
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(32);
        }];
        titleLabel;
    });

    self.backButton =
    ({
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage BBSImageNamed:@"/Common/BackButton@2x.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.view addSubview:back];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(_titleLabel);
            make.width.mas_equalTo(44);
        }];
        back;
    });

}

- (void)setTitleColor:(UIColor *)color
{
    [self.titleLabel setTextColor:color];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
