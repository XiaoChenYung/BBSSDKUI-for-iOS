//
//  BBSUIForumHeaderView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumHeaderView.h"
#import "BBSUIForumItem.h"
#import <BBSSDK/BBSForum.h>

#define BBSUIForumCountPerRow 4
#define BBSUIForumItemHeight 90
#define BBSUIForumTitleLableHeight 40

@interface BBSUIForumHeaderView ()

@property(nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void (^selectHandler)(BBSForum *forum);

@end

@implementation BBSUIForumHeaderView

- (instancetype)initWithFrame:(CGRect)frame selectHander:(void (^)(BBSForum *))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
        _selectHandler = handler;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, BBSUIForumTitleLableHeight)];
    [self.titleLabel setText:@"置顶版块"];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.titleLabel setTextColor:DZSUIColorFromHex(0xA3A2AA)];
    [self.titleLabel setTag:999];
    [self addSubview:self.titleLabel];
}

- (void)setStickForumArray:(NSArray *)stickForumArray
{
    for (UIView *subView in self.subviews) {
        if (subView.tag == 999) {
            continue;
        }
        [subView removeFromSuperview];
    }
    
    __weak typeof(self) theForumHeaderView = self;
    [stickForumArray enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull forum, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat width = DZSUIScreen_width / BBSUIForumCountPerRow;
        CGFloat originX = (idx % BBSUIForumCountPerRow) * width;
        CGFloat height = BBSUIForumItemHeight;
        CGFloat originY = (idx / BBSUIForumCountPerRow) * height + BBSUIForumTitleLableHeight;
        BBSUIForumItem *item = [[BBSUIForumItem alloc] initWithFrame:CGRectMake(originX, originY, width, height)
                                                        selectHander:^(BBSForum *forum) {
                                                            if (theForumHeaderView.selectHandler) {
                                                                theForumHeaderView.selectHandler(forum);
                                                            }
                                                        }];
        [item setForum:forum];
        [theForumHeaderView addSubview:item];
    }];
}

@end
