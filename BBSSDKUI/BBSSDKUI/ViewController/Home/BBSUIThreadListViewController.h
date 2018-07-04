//
//  BBSUIThreadListViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import <BBSSDK/BBSForum.h>

@interface BBSUIThreadListViewController : BBSUIBaseViewController

- (instancetype)initWithForumModel:(BBSForum *)forumModel;

@end
