//
//  BBSUIThreadListTableViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListTableViewController.h"
#import "MJRefresh.h"
#import "BBSUIThreadSummaryCell.h"
#import "BBSThread+BBSUI.h"
#import "UIView+BBSUITipView.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUIPortalDetailViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUICacheManager.h"
#import <BBSSDK/BBSBanner.h>
#import "BBSUIThreadBanner.h"
#import "BBSUIBannerPreviewViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Masonry.h"
#import "BBSUILBSShowLocationViewController.h"

#define BBSUIPageSize 10

@interface BBSUIThreadListTableViewController()<UITableViewDelegate, UITableViewDataSource, CycleViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *threadListArray;
@property (nonatomic, strong) BBSForum *currentForum;
@property (nonatomic, assign) BBSUIThreadSelectType selectType;
//@property (nonatomic, assign) BBSUIThreadOrderType orderType;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, assign) PageType pageType;

@property (nonatomic, strong) NSArray *bannerArray;

@end

static NSString *cellIdentifier = @"ThreadSummaryCell";

@implementation BBSUIThreadListTableViewController

- (instancetype)initWithForum:(BBSForum *)forum selectType:(BBSUIThreadSelectType)selectType pageType:(PageType)pageType
{
    self = [super init];
    if (self) {
        self.currentForum = forum;
        self.selectType = selectType;
        self.pageType = pageType;
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

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.fd_debugLogEnabled = YES;
    self.tableView.backgroundColor = DZSUI_BackgroundColor;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(182, 0, 0, 0);
    
    
    [self.tableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:cellIdentifier];
    
    if (_pageType == PageTypeHistory || self.currentForum)
    {
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
        tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
        
        [self.tableView setTableHeaderView:tableHeaderView];
    }
    
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - UI初始化
- (void)configureUI
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    
    if (_pageType == PageTypeHomePage) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.currentIndex = 1;
            [weakSelf requestData];
        }];
    }else{
        weakSelf.currentIndex = 1;
        if (self.pageType != PageTypeSearch) {
            [weakSelf requestData];
        }
    }
    

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex++;
        [weakSelf requestData];
    }];
    
    self.tableView.estimatedRowHeight = 135;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView.mj_header beginRefreshing];
    
    if (_pageType == PageTypeHistory)
    {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 406)];
    }
    
}

#pragma mark - 加载数据
- (void)initData
{
    self.currentIndex = 1;
    self.orderType = BBSUIThreadOrderPostTime;
}

- (NSInteger)orderType
{
    return _orderType;
}

#pragma mark - tableview datasource
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
        [self configureCell:cell atIndexPath:indexPath];
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeSearch];
    }
    else if (self.currentForum)
    {
        [self configureCell:cell atIndexPath:indexPath];
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeForums];
    }
    else if (_pageType == PageTypeHistory) {

        [self configureCell:cell atIndexPath:indexPath];
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeHistory];
    }
    else
    {
        [self configureCell:cell atIndexPath:indexPath];
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeHomepage];
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


- (void)configureCell:(BBSUIThreadSummaryCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
}


#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BBSThread *thread = _threadListArray[indexPath.row];
    
    [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
    
    thread.select = YES;
    
    BBSUIThreadSummaryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!_selectedArray)
    {
        _selectedArray = [NSMutableArray array];
    }
    
    [_selectedArray addObject:@(thread.tid)];
    
    cell.read = YES;
    
    id detailVC;
    
    if (_pageType == PageTypeSearch && [thread.type isEqualToString:@"portal"])
    {
        detailVC = [[BBSUIPortalDetailViewController alloc] initWithThreadModel:thread];
    }
    else
    {
        detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:thread];
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

#pragma mark - public methods
-(void)refreshData:(BBSUIThreadOrderType)orderType
{
    if (self.orderType == orderType) {
        return;
    }
    
    [self.tableView setScrollsToTop:YES];
    
    
    self.orderType = orderType;
    self.currentIndex = 1;
    [self.tableView.mj_header beginRefreshing];
}

- (void)refresh
{
    [self.tableView setContentOffset:CGPointMake(0,-60) animated:NO];
    
    __weak typeof(self) theTableVC = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        theTableVC.currentIndex = 1;
        [theTableVC.tableView.mj_header beginRefreshing];
    });
    
}


- (void)requestData
{
    if (self.pageType == PageTypeHomePage)  [self getHomePageData];
    if (self.pageType == PageTypeSearch)    [self getSearchData];
    if (self.pageType == PageTypeHistory)   [self getHistoryData];
    
    [self _requestBanner];
}

- (void)_requestBanner
{
    // 搜索和历史记录界面不显示banner
    if (_pageType == PageTypeHistory || _pageType == PageTypeSearch) {
        return;
    }
    
    //如果是首页，则显示banner
    if (!self.currentForum) {
        
        __weak typeof(self) theView = self;
        //加载广告条
        [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
            
            BBSUIThreadBanner *myView = [[BBSUIThreadBanner alloc]
                                         initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                                  183)];
            if (bannnerList.count > 0) {
                
                theView.bannerArray = bannnerList;
                
                NSMutableArray *pictureArray = [NSMutableArray array];
                [bannnerList enumerateObjectsUsingBlock:^(BBSBanner *  _Nonnull banner, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [pictureArray addObject:banner.picture ? banner.picture : @""];
                    
                }];
                
                myView.picDataArray = [pictureArray copy];
                
                if (pictureArray.count > 1) {
                    myView.isAutomaticScroll = YES;
                }
                
                myView.automaticScrollDelay = 4;
                
                myView.cycleViewStyle = CycleViewStyleBoth;
                
                myView.pageControlTintColor = [UIColor blackColor];
                
                myView.pageControlCurrentColor = [UIColor whiteColor];
                
                myView.delegate = theView;
                [theView.tableView setTableHeaderView:myView];
            }
            else
            {
                myView.picDataArray = @[@""];
                myView.isAutomaticScroll = NO;
                myView.scrollEnabled = NO;
                myView.titleDataArray = @[@"请前往开发者后台设置Banner"];
            }
            
        }];
        
    }
}

- (void)getHomePageData {
    // TODO: 帖子列表数据
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
            
            if (weakSelf.currentIndex == 1) {
                weakSelf.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else{
                [weakSelf.threadListArray addObjectsFromArray:threadList];
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_footer setHidden:NO];
            
            if (threadList.count < BBSUIPageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (weakSelf.currentIndex == 1) {
                
                [weakSelf.view bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }
        else
        {
            NSLog(@"%@",error);
            [weakSelf.view bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf.tableView.mj_header beginRefreshing];
                [weakSelf requestData];
            }];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        
    }];
}

- (void)getSearchData {
    __weak typeof(self) weakSelf = self;
    [BBSSDK searchWithType:@"all" wd:_keyword pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error)
    {
        if (!error) {

            for (BBSThread *obj in threadList)
            {
                if ([_selectedArray containsObject:@(obj.tid)])
                {
                    obj.select = YES;
                }
            }


            if (weakSelf.currentIndex == 1) {
                weakSelf.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else{
                [weakSelf.threadListArray addObjectsFromArray:threadList];
            }

            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_footer setHidden:NO];

            if (threadList.count < BBSUIPageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            if (weakSelf.currentIndex == 1) {

                [weakSelf.view bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                    
                    if (weakSelf.threadListArray.count)
                    {
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                    
                }];
            }
        }
        else
        {
            NSLog(@"%@",error);
            [weakSelf.view bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf.tableView.mj_header beginRefreshing];
                [weakSelf requestData];
            }];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];

}

- (void)getHistoryData {
    NSArray *array;
    __weak typeof(self) weakSelf = self;
    if (self.currentIndex == 1 || self.threadListArray.count == 0) {
        array = [[BBSUICoreDataManage shareManager] queryHistoryWithId:-1 limit:10];
        self.threadListArray = [NSMutableArray arrayWithArray:array];
    }
    else{
        //??????
        BBSThread *thread = self.threadListArray.lastObject;
        array = [[BBSUICoreDataManage shareManager] queryHistoryWithId:thread.tid limit:10];
        [self.threadListArray addObjectsFromArray:array];
    }
    [self.tableView reloadData];
    [self.tableView.mj_footer setHidden:NO];
    
    if (array.count < BBSUIPageSize) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    if (self.currentIndex == 1) {
        
        [self.view bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:self.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
            [weakSelf.tableView.mj_header beginRefreshing];
            [weakSelf requestData];
            
            if (self.threadListArray.count)
            {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
        }];
    }
    
    NSLog(@"%@______________",array.firstObject);
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

//- (void) setTableView:(UITableView *)tableView {
//    
//    [self.tableView removeFromSuperview];
//    
//    [self.view addSubview:tableView];
//    
//}
//
//- (UITableView *) tableView {
//    
//    for (UIView *v in self.view.subviews) {
//        
//        if ([v isKindOfClass:[UITableView class]]) {
//            
//            return (UITableView *)v;
//            
//        }
//    }
//    
//    return nil;
//}

- (void)setKeyword:(NSString *)keyword
{
    _keyword = keyword;
    self.currentIndex = 1;
    [self getSearchData];
}

#pragma mark - cycleviewdelegate
- (void)bannerClick:(NSInteger)index
{
    BBSBanner *banner = self.bannerArray[index];
    NSLog(@"link = %@, banner.title = %@, banner.picture = %@", banner.link, banner.title, banner.picture);
    NSLog(@"bannner.btype = %@", banner.btype);
    if ([banner.btype isEqualToString:@"link"]) {
        BBSUIBannerPreviewViewController *previewVC = [[BBSUIBannerPreviewViewController alloc] initWithTitle:banner.title];
//        [previewVC setUrlString:banner.link];
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


@end
