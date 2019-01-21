//
//  BBSUIUserInfoViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIBackViewController.h"

@interface BBSUIUserInfoViewController : BBSUIBaseViewController

- (instancetype)initWithUser:(BBSUser *)user;

@end
