//
//  BBSUIThreadListView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListView.h"
#import "BBSUILBSegmentControl.h"
#import <MOBFoundation/MOBFViewController.h>
#import <BBSSDK/BBSSDK.h>
#import "BBSThread+BBSUI.h"
#import "MJRefresh.h"
#import "UIView+BBSUITipView.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUIThreadListTableViewController.h"

#import <BBSSDK/BBSBanner.h>
#import "Masonry.h"



@interface BBSUIThreadListView()<BBSUILBSegmentControlDelegate>

@property (nonatomic, strong) BBSUILBSegmentControl *segmentControl;

@property (nonatomic, strong) NSArray *threadListViewContrllers;

@property (nonatomic, strong) UITableView *threadListTableView;

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UIWindow *refreshWindow;



@end

@implementation BBSUIThreadListView

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentForum = forum;
        [self configureUI];
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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    
    return self;
}


- (void)configureUI
{
    [self addSortSegmentControl];
    
    self.currentSelectType = 0;
    
    [self _makeRefreshWindow];

}

- (void)addSortSegmentControl
{
    BBSUIThreadListTableViewController *vc = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                            selectType:BBSUIThreadSelectTypeLatest
                                                                                              pageType:PageTypeHomePage];
    BBSUIThreadListTableViewController *vc1 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeHeats
                                                                                               pageType:PageTypeHomePage];
    BBSUIThreadListTableViewController *vc2 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeDigest
                                                                                               pageType:PageTypeHomePage];
    BBSUIThreadListTableViewController *vc3 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeDisplayOrder
                                                                                               pageType:PageTypeHomePage];
    
    self.threadListViewContrllers = @[vc, vc1, vc2, vc3];
    
    if (self.currentForum) {
        self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 64, DZSUIScreen_width, 40) titleFontSize:16 isIntegrated:NO];
    }else{
        self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 40) titleFontSize:16 isIntegrated:NO];
    }
    self.segmentControl.titles = @[@"最新", @"热门", @"精华", @"置顶"];
    self.segmentControl.viewControllers = self.threadListViewContrllers;
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.segmentControl setTitleNormalColor:DZSUIColorFromHex(0x6A7081)];
    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0x5B7EF0)];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.segmentControl.delegate = self;
    [self addSubview:self.segmentControl];
}

- (void)_makeRefreshWindow
{
    //添加刷新按钮
    if (self.currentForum) {
        
        _refreshWindow = [[UIWindow alloc] init];
        _refreshWindow.windowLevel = [UIApplication sharedApplication].keyWindow.windowLevel + 1;
        [_refreshWindow setBackgroundColor:[UIColor clearColor]];
        [_refreshWindow makeKeyAndVisible];
        CGFloat BBSRefreshButtonWidth = 50;
        CGFloat BBSRefreshRightMargin = 20;
        CGFloat BBSRefreshBottomMargin = 100;
        [_refreshWindow setFrame:CGRectMake(DZSUIScreen_width - BBSRefreshButtonWidth - BBSRefreshRightMargin, DZSUIScreen_height - BBSRefreshBottomMargin - BBSRefreshButtonWidth, BBSRefreshButtonWidth, BBSRefreshButtonWidth)];
        
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshWindow addSubview:_refreshButton];
        [_refreshButton setImage:[UIImage BBSImageNamed:@"/Thread/refreshDetail.png"] forState:UIControlStateNormal];
        [_refreshButton setFrame:CGRectMake(0, 0, BBSRefreshButtonWidth, BBSRefreshButtonWidth)];
        [_refreshButton addTarget:self action:@selector(_refreshButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)_refreshButtonHandler:(UIButton *)button
{
    BBSUIThreadListTableViewController *vc = self.threadListViewContrllers[self.currentSelectType];
    [vc refresh];
}

- (NSInteger)currentOrderType
{
    BBSUIThreadListTableViewController *vc = self.threadListViewContrllers[self.currentSelectType];
    return vc.orderType;
}

#pragma mark - public methods
- (void)requestDataWithOrderType:(BBSUIThreadOrderType)orderType
{
    BBSUIThreadListTableViewController *vc = self.threadListViewContrllers[self.currentSelectType];
    [vc refreshData:orderType];
    
}

- (void)dismissRefreshWindow
{
    [self.refreshWindow resignKeyWindow];
    self.refreshWindow = nil;
}

#pragma mark - 
- (void)selectIndex:(NSInteger)index
{
    self.currentSelectType = index;
    
    NSLog(@"=======+++++++   %lu",index);
    
}

@end

