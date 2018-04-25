//
//  BBSUIUserInfoViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIBackNavViewController.h"

@interface BBSUIUserInfoViewController : BBSUIBackNavViewController

- (instancetype)initWithUser:(BBSUser *)user;

@end
