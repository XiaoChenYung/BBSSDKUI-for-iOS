//
//  BBSUITribuneViewController.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/4.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUITribuneViewController.h"
#import "MJRefresh.h"
#import "BBSUIThreadSummaryCell.h"
#import "BBSThread+BBSUI.h"
#import "UIView+BBSUITipView.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUICacheManager.h"
#import <BBSSDK/BBSBanner.h>
#import "BBSUIThreadBanner.h"
#import "BBSUIBannerPreviewViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Masonry.h"
#import "BBSUIForumHeader.h"
#import "BBSUIPortalDetailViewController.h"
#import "BBSUIForumViewController.h"
#import "BBSUIThreadListViewController.h"
#import "BBSUITribuneSegementView.h"
#import "MBProgressHUD.h"
#import "BBSUIForumDetailViewController.h"
#import "BBSUILBSShowLocationViewController.h"


#define BBSUIPageSize 10


@interface BBSUITribuneViewController ()<UITableViewDelegate, UITableViewDataSource, CycleViewDelegate, iBBSUISegmentViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *threadListArray;
@property (nonatomic, strong) BBSForum *currentForum;
@property (nonatomic, assign) BBSUIThreadSelectType selectType;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSArray *bannerArray;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, assign) NSInteger catid;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BBSUITribuneSegementView *hoverView ;
/**
 顶部模块View
 */
@property (nonatomic, strong) BBSUIForumHeader *forumHeader;
@property (nonatomic, strong) BBSUITribuneSegementView *segemntView;
@property (nonatomic, strong) UIView *headerView ;
@property (nonatomic) dispatch_queue_t asyncQueue;

    
/** 存储加载数据*/
@property (nonatomic, strong) NSMutableDictionary *cacheDict ;
@property (nonatomic, strong) NSMutableArray *loadDataArray;
 
@property (nonatomic, strong) NSMutableArray *pageSizeArray;
    
    
@end

static NSString *cellIdentifier = @"ThreadSummaryCell";

@implementation BBSUITribuneViewController

- (instancetype)initWithForum:(BBSForum *)forum selectType:(BBSUIThreadSelectType)selectType
{
    self = [super init];
    if (self) {
        self.currentForum = forum;
        self.selectType = selectType;
        self.pageType = PageTypeHomePage;
        [self initData];
    }
    
    return self;
}

- (instancetype)initWithPageType:(PageType)pageType
{
    self = [super init];
    if (self) {
        self.pageType = pageType;
        [self initData];
    }
    
    return self;
}

- (instancetype)initWithCatid:(NSInteger)catid
{
    self = [super init];
    if (self) {
        self.pageType = PageTypePortal;
        self.catid = catid;
        [self initData];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

#pragma mark - 懒加载 Lazy Load
- (UIView *)noDataView
{
    if (!_noDataView) {
        if (self.currentForum.fid == 0) {
            _noDataView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 183+100+42, DZSUIScreen_width, DZSUIScreen_height - 64 - 40 - 183)];
            _noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DZSUIScreen_width - 80) / 2, 80, 80, 80)];
            [_noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];
            [_noDataView addSubview:_noDataImageView];
            
            _noDataLabel = [UILabel new];
            [_noDataLabel setFrame:CGRectMake(0, BBS_BOTTOM(_noDataImageView), DZSUIScreen_width, 40)];
            [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
            [_noDataLabel setTextColor:[UIColor grayColor]];
            [_noDataLabel setText:@"暂无内容"];
            [_noDataView addSubview:_noDataLabel];
        }
    }
    return _noDataView;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cacheDict = [NSMutableDictionary dictionary];
    
    self.orderType = BBSUIThreadOrderPostTime;
    [self _createTabView];
    [self _configureUI];
    [self _configureHoverView];
    [self _createTabHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark - UI
#pragma mark -悬停View
- (void)_configureHoverView
{
    BBSUITribuneSegementView *hoverView = [[BBSUITribuneSegementView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 42) titleArray:@[@"热门",@"精华",@"置顶",@"最新"]];
    
    hoverView.delegate = self;
    
    [self.view addSubview:hoverView];
    [self.view insertSubview:hoverView aboveSubview:self.tableView];
    self.hoverView = hoverView;
    self.hoverView.hidden = YES;
    
}

- (void)_createTabView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.pageType = PageTypeHomePage;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.fd_debugLogEnabled = YES;
    self.tableView.backgroundColor = DZSUI_BackgroundColor;
    
    [self.tableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:cellIdentifier];
    
    if (_pageType == PageTypeHistory || self.currentForum)
    {
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
        tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
        [self.tableView setTableHeaderView:tableHeaderView];
    }
}

- (void)_configureUI
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self _loadData];
    self.tableView.estimatedRowHeight = 135;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


#pragma mark - -------加载数据-------------
#pragma mark -开始加载数据
- (void)_loadData
{
    __weak typeof(self) weakSelf = self;
    if (_pageType == PageTypeHomePage || _pageType == PageTypePortal)
    {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.currentIndex = 1;
            [weakSelf requestData];
        }];
    }
    else
    {
        weakSelf.currentIndex = 1;
        if (self.pageType != PageTypeSearch) {
            [weakSelf requestData];
        }
    }
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex++;
        [weakSelf requestData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)initData
{
    self.currentIndex = 1;
    self.orderType = BBSUIThreadOrderPostTime;
}
    
#pragma mark - 请求数据
- (void)requestData
{
    if (self.pageType == PageTypeHomePage)  [self getHomePageData];
}

    
- (void)getHomePageData
{
    NSString *selectTypeString = [self selectTypeStringFromSelectType:self.selectType];
    NSString *orderTypeString = [self orderTypeStringFromOrderType:self.orderType];
    
    __weak typeof(self) weakSelf = self;
    [BBSSDK getThreadListWithFid:self.currentForum.fid orderType:orderTypeString selectType:selectTypeString pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
        
        if (!error) {
            
            if (_selectedArray.count)
            {
                for (BBSThread *obj in threadList)
                {
                    if ([_selectedArray containsObject:@(obj.tid)])
                    {
                        obj.select = YES;
                    }
                }
            }
            
            if (self.currentIndex == 1) {
                self.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else{
                [self.threadListArray addObjectsFromArray:threadList];
            }
            
            [self.tableView reloadData];
            [self.tableView.mj_footer setHidden:NO];
            
            if (threadList.count < BBSUIPageSize) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            //MARK:- 存储数据
            [self _cacheLoadData:self.threadListArray selectType:selectTypeString];
            
            NSLog(@"--->>>>>self.currentIndex--%lu", (unsigned long)self.currentIndex);
            
            if (self.currentIndex == 1) {
                
                if (threadList.count == 0) {
                    if (self.currentForum.fid == 0) {
                        [self.tableView addSubview:self.noDataView];
                        [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];
                        [self.noDataLabel setText:@"暂无内容"];
                    }else{
                        [self.view bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:self.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                            [self.tableView.mj_header beginRefreshing];
                            [self requestData];
                        }];
                    }
                }
            }
            
            if (threadList.count > 0) {
                if (_noDataView.superview) {
                    [_noDataView removeFromSuperview];
                }
            }
        }
        else
        {
            NSLog(@"======error=====%@",error);
            if (self.currentForum.fid == 0) {
                [self.tableView addSubview:self.noDataView];
                [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wwl@2x.png"]];
                [self.noDataLabel setText:@"网络不佳，请再次刷新"];
                [self.threadListArray removeAllObjects];
                [self.tableView reloadData];
                [weakSelf.tableView.mj_header endRefreshing];
            }else{
                [weakSelf.view bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
            
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];

}
    
    
- (void)_cacheLoadData:(NSArray *)loadDataArray selectType:(NSString *)selectType
{
    //以type为 key， list为value 存放到字典中
    [self.cacheDict setObject:loadDataArray forKey:selectType];
    
}
    

- (NSString *)selectTypeStringFromSelectType:(BBSUIThreadSelectType)selectType
{
    NSString *selectTypeString = nil;
    if (selectType == BBSUIThreadSelectTypeLatest) {
        selectTypeString = @"latest";
    }else if (selectType == BBSUIThreadSelectTypeHeats)
    {
        selectTypeString = @"heats";
    }else if (selectType == BBSUIThreadSelectTypeDigest)
    {
        selectTypeString = @"digest";
    }else if (selectType == BBSUIThreadSelectTypeDisplayOrder)
    {
        selectTypeString = @"displayOrder";
    }
    
    return selectTypeString ? : @"latest";
    
}

- (NSString *)orderTypeStringFromOrderType:(BBSUIThreadOrderType)orderType
{
    NSString *orderTypeString = nil;
    if (orderType == BBSUIThreadOrderCommentTime) {
        orderTypeString = @"lastPost";
    }else if (orderType == BBSUIThreadOrderPostTime)
    {
        orderTypeString = @"createdOn";
    }
    
    return orderTypeString ? : @"lastPost";
}

    
#pragma mark - BBSUITribuneSegementView Delegate

//MARK: ---切换最新，热门，精华置顶---
- (void)selectSegementTitle:(NSString *)selectTitle
{
    if ([selectTitle isEqualToString:@"最新"])
    {
        self.selectType = BBSUIThreadSelectTypeLatest;
    }
    else if ([selectTitle isEqualToString:@"热门"])
    {
        self.selectType = BBSUIThreadSelectTypeHeats;
    }
    else if ([selectTitle isEqualToString:@"精华"])
    {
        self.selectType = BBSUIThreadSelectTypeDigest;
    }
    else if ([selectTitle isEqualToString:@"置顶"])
    {
        self.selectType = BBSUIThreadSelectTypeDisplayOrder;
    }
    
    
    [self.tableView.mj_header endRefreshing];
    self.tableView.mj_offsetY = 0;
    
    
    [self _setHoverSelectTitle:selectTitle];
    
    [self _showCacheData];
    
    //self.currentIndex = 1;
    //[self requestData];
    
    //self.currentIndex = 1;
    //[self _loadData];
    
    
    
    
}

- (void)_showCacheData
{
    //处理缓存的数据，如果缓存有数据则，加载缓存，没有直接去请求
    NSString *selectTypeString = [self selectTypeStringFromSelectType:self.selectType];
    NSArray *dataArray = [self.cacheDict objectForKey:selectTypeString];
    
    if (dataArray.count > 0)
    {//有缓存数据
        
        NSLog(@">>>>>---有缓存数据-----");
        NSLog(@"--->>>>>dataArray--%lu", (unsigned long)dataArray.count);
        
        self.currentIndex = dataArray.count / BBSUIPageSize ;
        
        if (_selectedArray.count)
        {
            for (BBSThread *obj in dataArray)
            {
                if ([_selectedArray containsObject:@(obj.tid)])
                {
                    obj.select = YES;
                }
            }
        }
        
        self.threadListArray = [NSMutableArray arrayWithArray:dataArray];
        [self.tableView reloadData];
        [self.tableView.mj_footer setHidden:NO];
        
        if (dataArray.count > 0) {
            if (_noDataView.superview) {
                [_noDataView removeFromSuperview];
            }
        }
    }
    else
    {//没有缓存数据

        //self.currentIndex = 1;
        //[self requestData];
        
        self.currentIndex = 1;
        [self _loadData];
        
        NSLog(@"----mmmm--有环迅数据----");
    }
}

#pragma mark -设置悬浮框
- (void)_setHoverSelectTitle:(NSString *)selTitle
{
    [self.hoverView.buttonsArr enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([selTitle isEqualToString:obj.titleLabel.text]) {
            
            [self.hoverView hoverViewClick:obj];
        }
        
    }];
    
    [self.segemntView.buttonsArr enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([selTitle isEqualToString:obj.titleLabel.text]) {
            
            [self.segemntView hoverViewClick:obj];
        }
    }];
}

//时间排序
- (void)selectSortByType:(NSInteger)sortIndex
{
    if (sortIndex == BBSUISegmentViewMenuSendSort)
    {//发帖时间排序
        self.orderType = BBSUIThreadOrderPostTime;
    }
    else if (sortIndex == BBSUISegmentViewMenuReplySort)
    {//回复时间排序
        self.orderType = BBSUIThreadOrderCommentTime;
    }
    
    self.currentIndex = 1;
    [self requestData];
    
}
    
- (void)_showSortCacheData
{
    //处理缓存的数据，如果缓存有数据则，加载缓存，没有直接去请求
    NSString *orderTypeString = [self orderTypeStringFromOrderType:self.orderType];
    NSArray *dataArray = [self.cacheDict objectForKey:orderTypeString];
    
    if (dataArray.count > 0)
    {//有缓存数据
        
        NSLog(@">>>>>---有缓存数据-----");
        self.currentIndex = dataArray.count / BBSUIPageSize ;
        
        if (_selectedArray.count)
        {
            for (BBSThread *obj in dataArray)
            {
                if ([_selectedArray containsObject:@(obj.tid)])
                {
                    obj.select = YES;
                }
            }
        }
        
        self.threadListArray = [NSMutableArray arrayWithArray:dataArray];
        [self.tableView reloadData];
        [self.tableView.mj_footer setHidden:NO];
        
        if (dataArray.count > 0) {
            if (_noDataView.superview) {
                [_noDataView removeFromSuperview];
            }
        }
    }
    else
    {//没有缓存数据
        self.currentIndex = 1;
        [self requestData];
    }
}

#pragma mark - 表格头部
- (void)_createTabHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 183+100+42)];
    self.headerView = headerView;
    __weak typeof (self) theView = self;
    
    [self _addForumView];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, DZSUIScreen_width, 5)];
    line.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
    [headerView addSubview:line];
    
    //并行队列异步执行
    dispatch_queue_t secondQueue = dispatch_queue_create("secondQueue", DISPATCH_QUEUE_CONCURRENT);
    //2.把执行的任务放到队列中（子线程中执行）
    dispatch_async(secondQueue, ^{
        [SVProgressHUD showWithStatus:@""];
        //加载广告条
        [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
            theView.bannerArray = bannnerList;
            CGFloat bannerH = 183;
            
            BBSUIThreadBanner *myView = [[BBSUIThreadBanner alloc]
                                         initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width,
                                                                  bannerH)];
            [theView.headerView addSubview:myView];
            myView.automaticScrollDelay = 4;
            myView.cycleViewStyle = CycleViewStyleBoth;
            myView.pageControlTintColor = [UIColor blackColor];
            myView.pageControlCurrentColor = [UIColor whiteColor];
            myView.titleLabelTextColor = [UIColor whiteColor];
            myView.delegate = theView;
            
            if (bannnerList.count > 0)
            {
                NSMutableArray *titleArray = [NSMutableArray array];
                NSMutableArray *pictureArray = [NSMutableArray array];
                [bannnerList enumerateObjectsUsingBlock:^(BBSBanner *  _Nonnull banner, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [pictureArray addObject:banner.picture ? banner.picture : @""];
                    [titleArray addObject:banner.title ? banner.title : @""];
                }];
                
                myView.picDataArray = [pictureArray copy];
                myView.titleDataArray = [titleArray copy];
                
                if (pictureArray.count > 1) {
                    myView.isAutomaticScroll = YES;
                }
            }
            else
            {
                myView.picDataArray = @[@""];
                myView.isAutomaticScroll = NO;
                myView.scrollEnabled = NO;
                myView.titleDataArray = @[@"请前往开发者后台设置Banner"];
            }
            [SVProgressHUD dismiss];
        }];
    });
    
    //添加最新 热门 精华
    BBSUITribuneSegementView *segemntView = [[BBSUITribuneSegementView alloc] initWithFrame:CGRectMake(0, 183 + 100, DZSUIScreen_width, 42) titleArray:@[@"热门",@"精华",@"置顶",@"最新"]];
    self.segemntView = segemntView;
    [headerView addSubview:segemntView];
    segemntView.delegate = self;
    
    [self.tableView setTableHeaderView:headerView];
}

- (void)_addForumView
{
    __weak typeof (self) theView = self;
    
    if (_forumHeader) {
        [_forumHeader removeFromSuperview];
        _forumHeader = nil;
    }
    _forumHeader = [[BBSUIForumHeader alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 100)];
    [_forumHeader setResultHandler:^(BBSForum *forum){
        [theView _pushForumVC:forum];
    }];
    [theView.headerView addSubview:_forumHeader];
    
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        [theView.forumHeader setForumList:forumsList];
    }];
}
#pragma mark -版块跳转
- (void)_pushForumVC:(BBSForum *)forum
{
    [SVProgressHUD dismiss];
    if (!forum)
    {
        BBSUIForumViewController *vc = [[BBSUIForumViewController alloc] init];
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }
    else
    {
        BBSUIForumDetailViewController *threadListViewController = [[BBSUIForumDetailViewController alloc] init];
        threadListViewController.currentForum = forum;
        if ([MOBFViewController currentViewController].navigationController) {
            [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
        }
        
    }
}


#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.threadListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUIThreadSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.keyword) {
        cell.cellType = BBSUIThreadSummaryCellTypeSearch;
        [self configureCell:cell atIndexPath:indexPath];
    }
    else if (self.currentForum)
    {
        [self configureCell:cell atIndexPath:indexPath];
        
        cell.cellType = BBSUIThreadSummaryCellTypeForums;
    }
    else if (_pageType == PageTypeHistory) {
        cell.cellType = BBSUIThreadSummaryCellTypeHistory;   // 历史用的是板块的界面
        [self configureCell:cell atIndexPath:indexPath];
    }
    else if (_pageType == PageTypePortal) {
        cell.cellType = BBSUIThreadSummaryCellTypePortal;
        [self configureCell:cell atIndexPath:indexPath];
    }
    else
    {
        [self configureCell:cell atIndexPath:indexPath];
        cell.cellType = BBSUIThreadSummaryCellTypeHomepage;
    }
    
    __weak typeof(self)weakSelf = self;
    cell.addressOnClickBlock = ^(BBSThread *threadModel) {
        CLLocationCoordinate2D coordinate = {threadModel.latitude,threadModel.longitude};
        BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:threadModel.poiTitle];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
    
    return cell;
}


- (void)configureCell:(BBSUIThreadSummaryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    cell.threadModel = self.threadListArray[indexPath.row];
}

#pragma mark - UITableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD dismiss];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BBSThread *thread = _threadListArray[indexPath.row];
    
    thread.select = YES;
    
    BBSUIThreadSummaryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!_selectedArray)
    {
        _selectedArray = [NSMutableArray array];
    }
    //[_selectedArray addObject:@(thread.tid)];
    
    cell.read = YES;
    
    id detailVC = nil;
    if (_pageType == PageTypePortal
        || (_pageType == PageTypeSearch
            && [thread.type isEqualToString:@"portal"]))
    {
        detailVC = [[BBSUIPortalDetailViewController alloc] initWithThreadModel:thread];
        ((BBSUIPortalDetailViewController *)detailVC).catname = self.catname;
        ((BBSUIPortalDetailViewController *)detailVC).allowcomment = self.allowcomment;
        [_selectedArray addObject:@(thread.aid)];
    }
    else if (_pageType == PageTypeHistory
             && [thread.type isEqualToString:@"portal"])
    {
        detailVC = [[BBSUIPortalDetailViewController alloc] initWithThreadModel:thread];
        ((BBSUIPortalDetailViewController *)detailVC).catname = self.catname;
        ((BBSUIPortalDetailViewController *)detailVC).allowcomment = self.allowcomment;
        ((BBSUIPortalDetailViewController *)detailVC).hasContent = YES;
        [_selectedArray addObject:@(thread.aid)];
    }
    else
    {
        detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:thread];
        [_selectedArray addObject:@(thread.tid)];
    }
    
    if ([MOBFViewController currentViewController].navigationController)
    {
        [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
    }else if (self.navigationController){
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
// 收藏列表可做删除操作，帖子列表不删除

if (self.pageType == PageTypeHistory) {
    return UITableViewCellEditingStyleDelete;
}else{
    return UITableViewCellEditingStyleNone;
}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSThread *thread = self.threadListArray[indexPath.row];
    
    if ([thread.type isEqualToString:@"portal"])
    {
        [[BBSUICoreDataManage shareManager] deleteHistoryWithAid:thread.aid];
    }
    else
    {
        [[BBSUICoreDataManage shareManager] deleteHistoryWithTid:thread.tid];
    }
    
    [self.threadListArray removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}



- (void)setKeyword:(NSString *)keyword
{
    _keyword = keyword;
    self.currentIndex = 1;
    //[self getSearchData];
}


#pragma mark - UIScrolleView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 289)
    {
        self.hoverView.hidden = NO;
    }
    else
    {
        self.hoverView.hidden = YES;
    }
    
    if (_forumHeader.forumList.count <= 0) {
        [self _addForumView];
    }
    
}

#pragma mark - BBSBanner delegate
- (void)bannerClick:(NSInteger)index
{
    if (!self.bannerArray.count) {
        return;
    }
    
    BBSBanner *banner = self.bannerArray[index];
    NSLog(@"link = %@, banner.title = %@, banner.picture = %@", banner.link, banner.title, banner.picture);
    NSLog(@"bannner.btype = %@", banner.btype);
    if ([banner.btype isEqualToString:@"link"]) {
        BBSUIBannerPreviewViewController *previewVC = [[BBSUIBannerPreviewViewController alloc] initWithTitle:banner.title];
        [previewVC setUrlString:banner.link];
        if ([MOBFViewController currentViewController].navigationController) {
            [[MOBFViewController currentViewController].navigationController pushViewController:previewVC animated:YES];
        }
    }else if ([banner.btype isEqualToString:@"thread"])
    {
        BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithFid:banner.fid tid:banner.tid];
        
        if ([MOBFViewController currentViewController].navigationController)
        {
            [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
        }
    }
}
    
- (NSInteger)orderType
{
    return _orderType;
}

    
@end
