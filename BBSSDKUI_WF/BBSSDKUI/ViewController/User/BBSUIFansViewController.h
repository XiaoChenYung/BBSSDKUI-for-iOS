//
//  BBSUIFansViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import "BBSUIFansView.h"

/**
 我的粉丝、我的关注
 */
@interface BBSUIFansViewController : BBSUIBackViewController

@property (nonatomic, assign) BBSUIFansType fansViewType;

@property (nonatomic, strong) BBSUser *currentUser;

@end
