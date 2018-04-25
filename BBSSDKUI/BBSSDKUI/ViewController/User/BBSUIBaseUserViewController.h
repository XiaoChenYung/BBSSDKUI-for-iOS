//
//  BBSUIBaseUserViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/6/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSUIHideNavBaseViewController.h"

@interface BBSUIBaseUserViewController : BBSUIHideNavBaseViewController

@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UIButton *backButton;

- (void)setTitleColor:(UIColor *)color;

@end
