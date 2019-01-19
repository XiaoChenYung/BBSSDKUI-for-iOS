//
//  BBSUIForumDetailViewController.h
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/9.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import <BBSSDK/BBSForum.h>
#import "BBSUIThreadListView.h"

@interface BBSUIForumDetailViewController : BBSUIBaseViewController

@property (nonatomic, strong) BBSForum *currentForum;
// 针对门户  1-允许评论，0-不允许评论
@property (nonatomic, strong) NSNumber *allowcomment;

@property (nonatomic, assign) PageType pageType;

@property (nonatomic, assign) NSInteger orderType;

@property (nonatomic, strong) NSString *keyword;

@property (nonatomic, strong) NSString *catname;

@end
