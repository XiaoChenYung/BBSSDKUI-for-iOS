//
//  BBSUIThreadListView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListView.h"
#import "LBSegmentControl.h"
#import <MOBFoundation/MOBFViewController.h>
#import "BBSUIUserEditViewController.h"
#import "BBSUIEmailSendViewController.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSThread+BBSUI.h"
#import "MJRefresh.h"
#import "BBSUIThreadSummaryCell.h"
#import "UIView+TipView.h"
#import "BBSUIThreadDetailViewController.h"


#define BBSUIPageSize 10

@interface BBSUIThreadListView()<LBSegmentControlDelegate>

@property (nonatomic, strong) LBSegmentControl *segmentControl;

@property (nonatomic, strong) NSArray *threadListViewContrllers;

@property (nonatomic, strong) UITableView *threadListTableView;

@property (nonatomic, strong) BBSForum *currentForum;

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
}

- (void)addSortSegmentControl
{
    BBSUIThreadListTableViewController *vc = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                            selectType:BBSUIThreadSelectTypeLatest];
    BBSUIThreadListTableViewController *vc1 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeHeats];
    BBSUIThreadListTableViewController *vc2 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeDigest];
    BBSUIThreadListTableViewController *vc3 = [[BBSUIThreadListTableViewController alloc] initWithForum:self.currentForum
                                                                                             selectType:BBSUIThreadSelectTypeDisplayOrder];
    
    self.threadListViewContrllers = @[vc, vc1, vc2, vc3];
    
    if (self.currentForum) {
        self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 64, DZSUIScreen_width, 40) titleFontSize:16];
    }else{
        self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 40) titleFontSize:16];
    }
    self.segmentControl.titles = @[@"最新", @"热门", @"精华", @"置顶"];
    self.segmentControl.viewControllers = self.threadListViewContrllers;
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(0x50A3D3)];
    [self.segmentControl setTitleNormalColor:[UIColor blackColor]];
    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0x50A3D3)];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.segmentControl.delegate = self;
    [self addSubview:self.segmentControl];
}



- (void)requestDataWithOrderType:(BBSUIThreadOrderType)orderType
{
    BBSUIThreadListTableViewController *vc = self.threadListViewContrllers[self.currentSelectType];
    [vc refreshData:orderType];
    
}

- (NSInteger)currentOrderType
{
    BBSUIThreadListTableViewController *vc = self.threadListViewContrllers[self.currentSelectType];
    return vc.orderType;
}

#pragma mark - 
- (void)selectIndex:(NSInteger)index
{
    self.currentSelectType = index;
}

@end

#pragma mark - Class BBSUIThreadListTableViewController

@interface BBSUIThreadListTableViewController()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *threadListArray;
@property (nonatomic, strong) BBSForum *currentForum;
@property (nonatomic, assign) BBSUIThreadSelectType selectType;
//@property (nonatomic, assign) BBSUIThreadOrderType orderType;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation BBSUIThreadListTableViewController

- (instancetype)initWithForum:(BBSForum *)forum selectType:(BBSUIThreadSelectType)selectType
{
    self = [super init];
    if (self) {
        self.currentForum = forum;
        self.selectType = selectType;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self configureUI];
}

- (void)configureUI
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentIndex = 1;
        [weakSelf requestData];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex++;
        [weakSelf requestData];
    }];
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView.mj_header beginRefreshing];
}


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
    static NSString *cellIdentifier = @"ThreadSummaryCell";
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[BBSUIThreadSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.threadModel = self.threadListArray[indexPath.row];

    if (self.currentForum)
    {
        cell.cellType = BBSUIThreadSummaryCellTypeForums;
    }
    else
    {
        cell.cellType = BBSUIThreadSummaryCellTypeHomepage;
    }
    return cell;
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BBSThread *thread = _threadListArray[indexPath.row];
    
    thread.select = YES;
    
    BBSUIThreadSummaryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!_selectedArray)
    {
        _selectedArray = [NSMutableArray array];
    }
    
    [_selectedArray addObject:@(thread.tid)];
    
    cell.read = YES;
    
    BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:thread];
    
    if ([MOBFViewController currentViewController].navigationController)
    {
        [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
    }
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

#pragma mark - private methods
- (void)requestData
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
                
                [weakSelf.view configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }
        else
        {
            NSLog(@"%@",error);
            [weakSelf.view configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf.tableView.mj_header beginRefreshing];
                [weakSelf requestData];
            }];
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

@end
