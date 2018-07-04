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
#import "BBSUIUserEditViewController.h"
#import "BBSUIEmailSendViewController.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSPortalCatefories.h>
#import "BBSThread+BBSUI.h"
#import "MJRefresh.h"
#import "BBSUIThreadSummaryCell.h"
#import "UIView+BBSUITipView.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUIThreadListTableViewController.h"
#import "BBSUIBannerPreviewViewController.h"
#import "Masonry.h"
#import "BBSUIForumHeader.h"
#import "BBSUIThreadListViewController.h"
#import "BBSUIForumViewController.h"



@interface BBSUIThreadListView()<BBSUILBSegmentControlDelegate>

@property (nonatomic, strong) BBSUILBSegmentControl *segmentControl;

@property (nonatomic, strong) NSArray *threadListViewContrllers;

@property (nonatomic, strong) UITableView *threadListTableView;

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UIWindow *refreshWindow;

@property (nonatomic, assign) PageType pageType;

@property (nonatomic, strong) BBSUIForumHeader  *forumHeader;

@property (nonatomic, strong) NSMutableArray *categoriesList;

@property (nonatomic, strong) NSMutableArray *vcs ;

@property (nonatomic, strong) NSMutableArray *titles;

@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UILabel *noDataLabel;


@end

@implementation BBSUIThreadListView

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum pageType:(PageType)pageType
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageType = pageType;
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

- (UIView *)noDataView
{
    if (!_noDataView) {
        
        _noDataView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height )];
        _noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DZSUIScreen_width - 80) / 2, 150 , 80, 80)];
        [_noDataView addSubview:_noDataImageView];
        
        [_noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];

        _noDataLabel = [UILabel new];
        [_noDataLabel setFrame:CGRectMake(0, BBS_BOTTOM(_noDataImageView), DZSUIScreen_width, 40)];
        [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [_noDataLabel setTextColor:[UIColor grayColor]];
        [_noDataLabel setText:@"暂无内容"];
        [_noDataView addSubview:_noDataLabel];
    }
    
    return _noDataView;
}


#pragma mark - 添加tableView
- (void)addSortSegmentControl
{
    PageType pageType = self.pageType;
    
    self.vcs = [NSMutableArray array];
    self.titles = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    // 资讯
    if (pageType == PageTypePortal)
    {
        [self _requestData];
    }
    else
    {//论坛
        BBSUIThreadListTableViewController *vc = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                                selectType:BBSUIThreadSelectTypeLatest];
        BBSUIThreadListTableViewController *vc1 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                                 selectType:BBSUIThreadSelectTypeHeats];
        BBSUIThreadListTableViewController *vc2 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                                 selectType:BBSUIThreadSelectTypeDigest];
        BBSUIThreadListTableViewController *vc3 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                                 selectType:BBSUIThreadSelectTypeDisplayOrder];
        weakSelf.vcs = @[vc, vc1, vc2, vc3].mutableCopy;
        weakSelf.titles = @[@"最新", @"热门", @"精华", @"置顶"].mutableCopy;
        
        [self _addSortSegmentControlWithVCs:weakSelf.vcs titles:weakSelf.titles];
    }
}

- (void)_requestData
{
    __weak typeof(self) weakSelf = self;
    [BBSSDK getPortalCategories:^(NSArray *categories, NSError *error) {
        
        if (!error && categories.count)
        {
            self.categoriesList = categories.mutableCopy;
            [self.categoriesList enumerateObjectsUsingBlock:^(BBSPortalCatefories * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BBSUIThreadListTableViewController *vc = [[BBSUIThreadListTableViewController alloc] initWithCatid:obj.catid];
                vc.catname = obj.catname;
                vc.allowcomment = @(obj.allowcomment);
                
                [weakSelf.vcs addObject:vc];
                [weakSelf.titles addObject:obj.catname];
            }];
            
            [weakSelf _addSortSegmentControlWithVCs:weakSelf.vcs titles:weakSelf.titles];
        }
        else
        {
            [weakSelf addSubview:weakSelf.noDataView];
            [weakSelf.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wwl@2x.png"]];
            [weakSelf.noDataLabel setText:@"网络不佳，请再次刷新"];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapclick)];
            [weakSelf.noDataView addGestureRecognizer:tap];
        }
    }];
}

- (void)_tapclick
{
    [self _requestData];
}
#pragma mark - 添加最新 热门 精华
- (void)_addSortSegmentControlWithVCs:(NSMutableArray *)vcs titles:(NSMutableArray *)titles
{
    self.threadListViewContrllers = vcs;
    if (self.currentForum) {
        self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 64, DZSUIScreen_width, 40) titleFontSize:16 isIntegrated:NO];
    }else{
        
        CGFloat headerY = 0;
        //CGFloat headerY = 200;
        if (self.pageType == PageTypeHomePage)
        {
            headerY = 105;
            [self _requestForumHeader];
            //self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, headerY+200, DZSUIScreen_width, 40) titleFontSize:16 isIntegrated:NO];
            self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, headerY, DZSUIScreen_width, 40) titleFontSize:16 isIntegrated:NO];
            self.segmentControl.viewHeight = DZSUIScreen_height - 210;
        }
        else
        {//资讯
            self.segmentControl = [[BBSUILBSegmentControl alloc] initScrollTitlesWithFrame:CGRectMake(0, headerY, DZSUIScreen_width, 40)];
        }
    }
    self.segmentControl.titles = titles;
    self.segmentControl.viewControllers = self.threadListViewContrllers;
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.segmentControl setTitleNormalColor:DZSUIColorFromHex(0x6A7081)];
    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0x5B7EF0)];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.segmentControl.delegate = self;
//    self.segmentControl.isIntegrated = YES;
    [self addSubview:self.segmentControl];
    
}

#pragma mark - 全部财经体育
- (void)_requestForumHeader
{
    __weak typeof (self) theView = self;
    //全部 财经 体育
    _forumHeader = [[BBSUIForumHeader alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 100)];
    [_forumHeader setResultHandler:^(BBSForum *forum){
        [theView _pushForumVC:forum];
    }];
    [self addSubview:_forumHeader];
    
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        [theView.forumHeader setForumList:forumsList];
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, DZSUIScreen_width, 5)];
    line.backgroundColor = DZSUIColorFromHex(0xF9F9F9);
    [self addSubview:line];

}

- (void)_pushForumVC:(BBSForum *)forum
{
    if (!forum)
    {
        BBSUIForumViewController *vc = [[BBSUIForumViewController alloc] init];
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }
    else
    {
        BBSUIThreadListViewController *threadListViewController = [[BBSUIThreadListViewController alloc] initWithForum:forum];
        if ([MOBFViewController currentViewController].navigationController) {
            [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
        }
    }
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

#pragma mark - 切换 最新热门精华
- (void)selectIndex:(NSInteger)index
{
    self.currentSelectType = index;
    
}

- (NSMutableArray *)categoriesList
{
    if (!_categoriesList)
    {
        _categoriesList = [NSMutableArray new];
    }
    
    return _categoriesList;
}
@end

