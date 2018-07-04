//
//  BBSUIForumListView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/16.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumListView.h"
#import "LBSegmentControl.h"
#import "Masonry.h"
#import "BBSUIThreadListViewController.h"
//#import "DZSThreadDetailViewController.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSForum.h>
#import "UIView+TipView.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIForumListView ()

@property (nonatomic, strong) LBSegmentControl * segmentControl;

@end

@implementation BBSUIForumListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self requestForumList];
    }
    
    return self;
}

- (void)requestForumList
{    
    __weak typeof(self) weakSelf = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        if (!error) {
            if (forumsList.count > 0) {
                
                [weakSelf layoutForumsView:forumsList];
            }else{
                [weakSelf configureTipViewWithTipMessage:@"未获取到数据" hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf requestForumList];
                }];
            }
            
        }else{
            [weakSelf configureTipViewWithTipMessage:error.userInfo[@"bbs_error_msg"] hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestForumList];
            }];
        }
    }];
}

- (void)layoutForumsView:(NSArray *)forumList
{
    NSMutableArray *forumControllerArray = [NSMutableArray array];
    NSMutableArray *titleArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [forumList enumerateObjectsUsingBlock:^(BBSForum*  _Nonnull forum, NSUInteger idx, BOOL * _Nonnull stop) {
        BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] initWithForumModel:forum];
        
        [forumControllerArray addObject:vc];
        
        if (forum.name) {
            [titleArray addObject:forum.name];
        }
    }];
    
    self.segmentControl = [[LBSegmentControl alloc] initScrollTitlesWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 45)];
    self.segmentControl.titles = titleArray;
    self.segmentControl.viewControllers = forumControllerArray;
    self.segmentControl.titleNormalColor = [UIColor blackColor];
    self.segmentControl.titleSelectColor = DZSUIColorFromHex(DZSUI_MainColor);
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(DZSUI_MainColor)];
    self.segmentControl.isTitleScale = YES;
    [weakSelf addSubview:self.segmentControl];
}

@end
