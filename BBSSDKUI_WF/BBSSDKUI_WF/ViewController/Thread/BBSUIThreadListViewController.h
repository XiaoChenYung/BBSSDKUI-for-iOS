//
//  BBSUIThreadListViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import <BBSSDK/BBSForum.h>
#import "BBSUIEnum.h"

/**
 帖子 VC
 */
@interface BBSUIThreadListViewController : BBSUIBaseViewController

// pageType,区分门户,论坛
@property (nonatomic, assign) PageType pageType;
- (instancetype)initWithForum:(BBSForum *)forum;

@end
