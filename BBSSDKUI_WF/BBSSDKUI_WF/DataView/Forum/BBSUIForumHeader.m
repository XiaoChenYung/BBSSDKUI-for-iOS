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
        if ([subView isKindOfClass:[BBSUIForumHeaderItem class]] || [subView isKindOfClass:[UIScrollView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BBS_WIDTH(self) / 5 * 4, BBS_HEIGHT(self))];
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    NSInteger displayCount = self.forumList.count + 1;
    
    for (int i = 0; i < displayCount; i++) {
        
        BOOL isMore = NO;
        BBSUIForumHeaderItem *item;
        
        if (i == (displayCount - 1))
        {
            isMore = YES;
            item = [[BBSUIForumHeaderItem alloc] initWithFrame:CGRectMake(BBS_WIDTH(self) / 5 * 4, 0, BBS_WIDTH(self) / 5, BBS_HEIGHT(self))];
            [item setForum:isMore ? nil : _forumList[i] moreForumFlag:isMore result:self.resultHandler];
            [self addSubview:item];
        }
        else
        {
            item = [[BBSUIForumHeaderItem alloc] initWithFrame:CGRectMake(BBS_WIDTH(self) / 5 * i, 0, BBS_WIDTH(self) / 5, BBS_HEIGHT(self))];
            [item setForum:isMore ? nil : _forumList[i] moreForumFlag:isMore result:self.resultHandler];
            [scrollView addSubview:item];
        }
        if (i == (displayCount - 2))
        {
            scrollView.contentSize = CGSizeMake(CGRectGetMaxX(item.frame), BBS_HEIGHT(self));
        }
        
    }
}

#pragma mark - public methods
- (void)setForumList:(NSArray *)forumList
{
    _forumList = forumList;
    
    [self _configureUI];
}

@end
