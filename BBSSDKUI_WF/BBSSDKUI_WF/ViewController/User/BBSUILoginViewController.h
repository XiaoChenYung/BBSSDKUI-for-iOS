//
//  BBSUILoginViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseUserViewController.h"
typedef NS_ENUM(NSInteger, BBSLoginType)
{
    BBSLoginTypeLogin = 0,
    BBSLoginTypeBindAccount = 2
};

@interface BBSUILoginViewController : BBSUIBaseUserViewController

@property (nonatomic, copy) void (^cancelLoginBlock)();
@property (nonatomic, assign) BBSLoginType loginType;

/**
 应用于loginType == BBSLoginTypeBindAccount场景
 传入三方登录得到的参数
 */
@property (nonatomic, strong) NSDictionary *params;

@end
