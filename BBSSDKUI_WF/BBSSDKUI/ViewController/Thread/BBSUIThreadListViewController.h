//
//  BBSUIThreadListViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import <BBSSDK/BBSForum.h>
//#import "BBSUICustomNavViewController.h"

@interface BBSUIThreadListViewController : BBSUIBaseViewController

- (instancetype)initWithForum:(BBSForum *)forum;

@end
