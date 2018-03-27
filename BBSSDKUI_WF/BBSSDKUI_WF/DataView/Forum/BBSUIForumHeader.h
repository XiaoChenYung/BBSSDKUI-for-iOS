//
//  BBSUIForumHeader.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

@class BBSForum;
@interface BBSUIForumHeader : BBSUIBaseView

@property (nonatomic, copy) void (^resultHandler)(BBSForum *forum);

@property (nonatomic, strong) NSArray *forumList;

@end
