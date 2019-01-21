//
//  BBSUIUserMeInfoViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/27.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import <BBSSDK/BBSUser.h>

/**
 个人信息
 */
@interface BBSUIUserMeInfoViewController : BBSUIBaseViewController

- (instancetype)initWithUser:(BBSUser *)user;

@end
