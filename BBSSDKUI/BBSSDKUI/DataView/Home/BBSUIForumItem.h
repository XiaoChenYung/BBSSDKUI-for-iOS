//
//  BBSUIForumItem.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSForum.h>

@interface BBSUIForumItem : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame selectHander:(void (^)(BBSForum *))handler;

@property (nonatomic, strong) BBSForum *forum;

@end
