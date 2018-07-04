//
//  BBSUIThreadListView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSThread.h>
#import <BBSSDK/BBSForum.h>

@interface BBSUIThreadListView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum;

@end
