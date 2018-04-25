//
//  BBSUIForumDetailViewController.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/9.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIForumDetailViewController.h"
#import "BBSUIPopoverView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "BBSUIFastPostViewController.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUISearchViewController.h"
#import "Masonry.h"
#import "UIView+BBSUIExt.h"
#import "BBSUIStatusBarTip.h"
#import "BBSUITribuneSegementView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BBSUIThreadSummaryCell.h"
#import "BBSThread+BBSUI.h"
#import "UIView+BBSUITipView.h"
#import "MJRefresh.h"

#import "BBSUIForumHeader.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUIPortalDetailViewController.h"

#define BBSUIPageSize 10

@interface BBSUIForumDetailViewController ()<iBBSUIFastPostViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, iBBSUISegmentViewDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, assign) BOOL isPresent;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, assign) CGFloat iphoneXTopPadding;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *threadListArray;
@property (nonatomic, assign) BBSUIThreadSelectType selectType;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) BBSUITribuneSegementView *segmentView ;
@property (nonatomic, strong) UIView *lineView;

@end

static NSString *cellIdentifier = @"ThreadSummaryCell";


@implementation BBSUIForumDetailViewController

#pragma mark - 懒加载 Lazy Load
- (UIView *)noDataView
{
    if (!_noDataView) {
            _noDataView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height - 110)];
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
    return _noDataView;
}


#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initUI];
    [self _createTabView];
    self.selectType = BBSUIThreadSelectTypeLatest;
    self.orderType = BBSUIThreadOrderCommentTime;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (self.currentForum) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [super viewWillAppear:animated];
    self.isPresent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.currentForum && !self.isPresent) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [super viewWillDisappear:animated];
}


#pragma mark - initUI

- (void)_initUI
{
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        _iphoneXTopPadding = 10;
    }
    [self setNavigationBarTitle];
    
    //最新 最热
     BBSUITribuneSegementView *segmentView = [[BBSUITribuneSegementView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:segmentView];
    segmentView.delegate = self;
    self.segmentView = segmentView;
    segmentView.backgroundColor = [UIColor clearColor];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(77);
        make.left.right.mas_equalTo(0);
        make.size.height.mas_equalTo(42);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(segmentView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.size.height.mas_equalTo(5);
    }];
    self.lineView = lineView;
    lineView.backgroundColor = DZSUIColorFromHex(0xEAEDF2);
}


- (void) _loadData
{
    
    __weak typeof(self) weakSelf = self;
    if (_pageType == PageTypeHomePage || _pageType == PageTypePortal) {
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
    [self.tableView.mj_header beginRefreshing];
}

- (void)_createTabView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 135;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.pageType = PageTypeHomePage;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.fd_debugLogEnabled = YES;
    self.tableView.backgroundColor = DZSUI_BackgroundColor;
    
    [self.tableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:cellIdentifier];
    
//    if (_pageType == PageTypeHistory || self.currentForum)
//    {
//        UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
//        tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
//        [self.tableView setTableHeaderView:tableHeaderView];
//    }
     [self _loadData];
}

#pragma mark - 导航头
- (void)setNavigationBarTitle
{
    if (!self.currentForum) {
        self.title = @"所有";
        return;
    }
    
    self.backButton =
    ({
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:back];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(0);
            make.top.equalTo(self.view).with.offset(30 + _iphoneXTopPadding);
            make.width.mas_equalTo(@50);
        }];
        back;
    });
    
    
    self.titleView = [[UIView alloc] init];
    [self.view addSubview:self.titleView];
    [self.titleView setFrame:CGRectMake(50, 20 + _iphoneXTopPadding, BBS_WIDTH(self.view) - 100, 44)];
    
    UILabel *titleLabel = [UILabel new];
    [self.titleView addSubview:titleLabel];
    if (self.currentForum) {
        [titleLabel setText:self.currentForum.name];
    }else{
        [titleLabel setText:@"所有"];
    }
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    CGSize buttonSize = [titleLabel.text boundingRectWithSize:size
                                                      options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{ NSFontAttributeName:titleLabel.font}
                                                      context:nil].size;
    [titleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2, buttonSize.width, buttonSize.height)];
    [titleLabel setTextColor:[UIColor blackColor]];
    
    //    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BBS_RIGHT(titleLabel) + 5, (BBS_HEIGHT(self.titleView) - 14) / 2, 14, 14)];
    //    [_arrowImageView setContentMode:UIViewContentModeScaleAspectFit];
    //    [_arrowImageView setImage:arrowImage];
    //    [self.titleView addSubview:_arrowImageView];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    //    titleTap.numberOfTouchesRequired = 1;
    //    [self.titleView addGestureRecognizer:titleTap];
    //    [self setupRightBarButton];
    [self setupRightBarButton];
}

- (void)setupRightBarButton
{
    CGFloat postThreadButtonWidth = 30;
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(DZSUIScreen_width - postThreadButtonWidth - 10, 25 + _iphoneXTopPadding, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"Home/postThreadBlack.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:postThread];

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
    
    [self configureCell:cell atIndexPath:indexPath];
    cell.cellType = BBSUIThreadSummaryCellTypeForums;
    
    return cell;
}


- (void)configureCell:(BBSUIThreadSummaryCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    cell.threadModel = self.threadListArray[indexPath.row];
}

#pragma mark - UITableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark - 加载数据
- (void)requestData
{
     [self getHomePageData];
}

- (void)getHomePageData {
    
    NSString *selectTypeString = [self selectTypeStringFromSelectType:self.selectType];
    NSString *orderTypeString = [self orderTypeStringFromOrderType:self.orderType];
    
    __weak typeof(self) weakSelf = self;
    //[BBSSDK getThreadListWithFid:self.currentForum.fid orderType:orderTypeString selectType:selectTypeString pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
    
    [BBSSDK getThreadListWithFid:self.currentForum.fid  orderType:orderTypeString selectType:selectTypeString pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
        
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
                
                if (threadList.count == 0) {
                    if (self.currentForum.fid == 0) {
                        [self.tableView addSubview:self.noDataView];
                        [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];
                        [self.noDataLabel setText:@"暂无内容"];
                    }else{
                        [weakSelf.view bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                            [weakSelf.tableView.mj_header beginRefreshing];
                            [weakSelf requestData];
                        }];
                    }
                }
            }
            
            if (threadList.count > 0) {
                [weakSelf.view bbs_configureTipViewWithTipMessage:@"" hasData:YES];
                if (_noDataView.superview) {
                    [_noDataView removeFromSuperview];
                }
            }
        }
        else
        {
            NSLog(@"======error=====%@",error);
            [self.tableView addSubview:self.noDataView];
            [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wwl@2x.png"]];
            [self.noDataLabel setText:@"网络不佳，请再次刷新"];
            [self.threadListArray removeAllObjects];
            [self.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
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

- (void)setKeyword:(NSString *)keyword
{
    _keyword = keyword;
    self.currentIndex = 1;
}

#pragma mark - BBSUITribuneSegementView Delegate
//最新 最热
- (void)selectSegementType:(NSInteger)index
{
    if (index == BBSUISegmentViewMenuTypeNew)
    {
        self.selectType = BBSUIThreadSelectTypeLatest;
    }
    else if (index == BBSUISegmentViewMenuTypeHot)
    {
        self.selectType = BBSUIThreadSelectTypeHeats;
    }
    else if (index == BBSUISegmentViewMenuTypeCream)
    {
        self.selectType = BBSUIThreadSelectTypeDigest;
    }
    else if (index == BBSUISegmentViewMenuTypeTop)
    {
        self.selectType = BBSUIThreadSelectTypeDisplayOrder;
    }
    
    self.currentIndex = 1;
    [self _loadData];
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
    [self _loadData];
    
}

#pragma mark - 发帖
- (void)editThread:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        self.isPresent = YES;
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        //        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        //        [editVC addPostThreadObserver:self];
        //        [self.navigationController pushViewController:editVC animated:YES];
        self.isPresent = YES;
        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        [editVC setForum:_currentForum];
        
        [editVC addPostThreadObserver:self];
        BBSUIMainStyleNavigationController *mainStyleNav = [[BBSUIMainStyleNavigationController alloc] initWithRootViewController:editVC];
        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)cancel:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - iBBSUIFastPostViewControllerDelegate
- (void)didBeginPostThread
{
    [[BBSUIStatusBarTip shareStatusBar] postBegin];
}

- (void)didPostSuccess
{
    [[BBSUIStatusBarTip shareStatusBar] postSuccess];
}

- (void)didPostFailWithError:(NSError *)error
{
    [[BBSUIStatusBarTip shareStatusBar] postFailed:[error userInfo][@"description"]];
    
    if (error.code == 9001200) {
        [BBSUIContext shareInstance].currentUser = nil;
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}


- (void)dealloc
{
    [[BBSUIFastPostViewController shareInstance] removePostThreadObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
