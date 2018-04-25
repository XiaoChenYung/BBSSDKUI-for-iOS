//
//  BBSUIForumHeaderItem.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

@class BBSForum;
@interface BBSUIForumHeaderItem : BBSUIBaseView

- (void)setForum:(BBSForum *)forum moreForumFlag:(BOOL)moreForumFlag result:(void (^)(BBSForum *forum))handler;

@end
