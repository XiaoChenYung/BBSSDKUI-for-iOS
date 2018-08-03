//
//  BBSUIForumView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import "BBSUIForumViewController.h"

@interface BBSUIForumView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame forumType:(BBSUIForumViewControllerType)forumType selectHandler:(void (^)(BBSForum *forum))selectHandler;

@end
