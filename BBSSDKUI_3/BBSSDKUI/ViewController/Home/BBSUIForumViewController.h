//
//  BBSUIForumViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackNavViewController.h"

@class BBSForum;

typedef NS_ENUM(NSInteger, BBSUIForumViewControllerType)
{
    BBSUIForumViewControllerTypeDefault = 0,    // 默认版块展示
    BBSUIForumViewControllerTypeSelectForum = 1 // 选择版块
};

/**
 板块 VC
 */
@interface BBSUIForumViewController : BBSUIBackNavViewController

- (instancetype)initWithSelectType:(BBSUIForumViewControllerType)forumType resultHandler:(void (^)(BBSForum *forum))resultHandler;

@property (nonatomic, assign) BBSUIForumViewControllerType forumType;


@end
