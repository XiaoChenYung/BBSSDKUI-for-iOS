//
//  BBSUIForumThreadListViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"

@class BBSForum;

/**
 板块详情VC
 */
@interface BBSUIForumThreadListViewController : BBSUIBaseViewController

- (instancetype)initWithForum:(BBSForum *)forum;

@end
