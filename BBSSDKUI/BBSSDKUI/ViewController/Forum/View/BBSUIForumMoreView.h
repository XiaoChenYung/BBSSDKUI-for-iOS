//
//  BBSUIForumMoreView.h
//  BBSSDKUI
//
//  Created by 崔林豪 on 2018/4/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import "BBSUIForumViewController.h"

@interface BBSUIForumMoreView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame forumType:(BBSUIForumViewControllerType)forumType selectHandler:(void (^)(BBSForum *forum))selectHandler;

@end
