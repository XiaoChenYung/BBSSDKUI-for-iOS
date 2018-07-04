//
//  BBSUIThreadListView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListView.h"
#import "Masonry.h"
#import "BBSUIThreadSummaryCell.h"
#import <BBSSDK/BBSThread.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImage+BBSFunction.h"
#import <BBSSDK/BBSSDK.h>
//#import "TableViewCell.h"
#import "MJRefresh.h"
#import "BBSUIThreadDetailWebViewController.h"
#import "UIView+ViewController.h"
#import "UIView+TipView.h"
#import "UIImage+BBSFunction.h"

static NSString *ThreadAbstractCellId = @"ThreadSummaryCellId";

static NSInteger PageSize = 10;

@interface BBSUIThreadListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger currentPageIndex;

@property (nonatomic, strong) BBSForum *forum;

@property (nonatomic, strong) UITableView *threadListTableView;

@property (nonatomic, strong) NSMutableArray *threadData;

@end

@implementation BBSUIThreadListView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum
{
    self = [super initWithFrame:frame];
    if (self) {
        self.forum = forum;
        [self initData];
        [self configureUI];
    }
    
    return self;
}

- (void)initData
{
    self.currentPageIndex = 1;
}

//- (NSMutableArray *)threadData
//{
//    if (!_threadData) {
//        _threadData = [NSMutableArray array];
//    }
//    return _threadData;
//}

- (void)configureUI
{
    self.threadListTableView = [[UITableView alloc] init];
    [self addSubview:self.threadListTableView];
//    [self.threadListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
    [self.threadListTableView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 64 - 45)];
    [self.threadListTableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:ThreadAbstractCellId];
    self.threadListTableView.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
    self.threadListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.threadListTableView setDelegate:self];
    [self.threadListTableView setDataSource:self];
    
    self.threadListTableView.estimatedRowHeight = 200 ;
    self.threadListTableView.rowHeight = UITableViewAutomaticDimension ;
    [self.threadListTableView.mj_footer setHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    self.threadListTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentPageIndex = 1;
        [weakSelf requestThreadList];
    }];
    
    self.threadListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentPageIndex++;
        [weakSelf requestThreadList];
    }];
    
    [self.threadListTableView.mj_header beginRefreshing];
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.threadData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreadAbstractCellId];
    
    BBSThread * thread = self.threadData[indexPath.row] ;
    
    NSLog(@"\n %@ \n %@ \n %@",thread.author,thread.subject,thread.summary);
    cell.threadModel = thread ;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BBSThread *threadModel = self.threadData[indexPath.row];
    BBSUIThreadDetailWebViewController *threadDetailVC = [[BBSUIThreadDetailWebViewController alloc] initWithThreadModel:threadModel];
    [self.viewController.navigationController pushViewController:threadDetailVC animated:YES];
}


#pragma mark - request
- (void)requestThreadList
{
    __weak typeof(self) weakSelf = self;
    [BBSSDK getThreadListWithFid:self.forum.fid pageIndex:self.currentPageIndex pageSize:PageSize result:^(NSArray *threadList, NSError *error) {
        
        if (!error)
        {
            if (weakSelf.currentPageIndex == 1) {
                weakSelf.threadData = [NSMutableArray arrayWithArray:threadList];
            }else{
                [weakSelf.threadData addObjectsFromArray:threadList];
            }
            
            NSLog(@"%@",weakSelf.threadData);
            [weakSelf.threadListTableView reloadData];
            [weakSelf.threadListTableView.mj_footer setHidden:NO];
            
            if (threadList.count < PageSize) {
                [weakSelf.threadListTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (weakSelf.currentPageIndex == 1) {
                
                [weakSelf configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.threadData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf requestThreadList];
                }];
            }
            
        }else
        {
            [weakSelf configureTipViewWithTipMessage:@"网络不加，请再次刷新" hasData:weakSelf.threadData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestThreadList];
            }];
        }
        
        [weakSelf.threadListTableView.mj_header endRefreshing];
        [weakSelf.threadListTableView.mj_footer endRefreshing];
        
    }];
}

@end
