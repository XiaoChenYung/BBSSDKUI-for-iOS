//
//  BBSUIForumHeaderView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
@class BBSForum;

@interface BBSUIForumHeaderView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame selectHander:(void (^)(BBSForum *forum))handler;

@property(nonatomic, strong) NSArray *stickForumArray;

@end
