//
//  BBSUIForumHeader.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumHeader.h"
#import "BBSUIForumHeaderItem.h"

#define BBSUIForumCount 5

@implementation BBSUIForumHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self _configureUI];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self _configureUI];
    }
    
    return self;
}

#pragma mark - private methods
- (void)_configureUI
{
    //先行移除
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BBSUIForumHeaderItem class]]) {
            [subView removeFromSuperview];
        }
    }
    
    NSInteger displayCount = 0;
    if (self.forumList.count <= 4) {
        displayCount = self.forumList.count + 1;
    }else{
        displayCount = 5;
    }
    
    for (int i = 0; i < displayCount; i++) {
        BBSUIForumHeaderItem *item = [[BBSUIForumHeaderItem alloc] initWithFrame:CGRectMake(BBS_WIDTH(self) / 5 * i, 0, BBS_WIDTH(self) / 5, BBS_HEIGHT(self))];
        
        BOOL isMore = NO;
        if (i == (displayCount - 1)) {
            isMore = YES;
        }
        
        [item setForum:isMore ? nil : _forumList[i] moreForumFlag:isMore result:self.resultHandler];
        [self addSubview:item];
    }
}

#pragma mark - public methods
- (void)setForumList:(NSArray *)forumList
{
    _forumList = forumList;
    
    [self _configureUI];
}

@end
