//
//  BBSUICollectionView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICollectionView.h"
#import "BBSUICollectionTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import "MJRefresh.h"
#import "BBSUIContext.h"
#import "BBSUIThreadDetailViewController.h"
#import "UIView+BBSUITipView.h"
#import "BBSUILBSShowLocationViewController.h"
#define BBSUIPageSize       10

@interface BBSUICollectionView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *marrData;

@property (nonatomic, assign) BBSUICollectionViewType type;

/**
 正在进行删除操作
 */
@property (nonatomic, assign) BOOL isDeleting;

@end

@implementation BBSUICollectionView

- (instancetype)init:(BBSUICollectionViewType)type{
    if (self = [super init]) {
        [self data:type];
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(BBSUICollectionViewType)type{
    if (self = [super initWithFrame:frame]) {
        [self data:type];
        [self configureUI];
    }
    
    return self;
}

- (void)data:(BBSUICollectionViewType)type{
    _type = type;
    _currentUser = [BBSUIContext shareInstance].currentUser;
    _currentIndex = 1;
}

- (void)configureUI
{
    self.collectionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.collectionTableView];
    
    [self.collectionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.collectionTableView.dataSource = self;
    self.collectionTableView.delegate = self;
    self.collectionTableView.backgroundColor = DZSUI_BackgroundColor;
    
    self.collectionTableView.estimatedRowHeight = 200;
    self.collectionTableView.rowHeight = UITableViewAutomaticDimension;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
    tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
    
    [self.collectionTableView setTableHeaderView:tableHeaderView];
    self.collectionTableView.tableFooterView = [UIView new];
    
    __weak typeof (self) weakSelf = self;
    self.collectionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentIndex = 1;
        [weakSelf requestData];
    }];
    self.collectionTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex ++;
        [weakSelf requestData];
    }];
    
    if (_type != CollectionViewTypeThreadFavorites) // 收藏存在取消收藏事件，故收藏拉取数据放在viewWillAppear中
        [self requestData];
}

- (void)refreshData
{
    self.currentIndex = 1;
    [self requestData];
}

- (void)requestData
{
    __weak typeof (self) weakSelf = self;
    if (_type == CollectionViewTypeThreadList) {
        [BBSSDK getUserThreadListWithAuthorid:nil pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
            
            if (error) {
                return ;
            }
            
            if (weakSelf.currentIndex == 1) {
                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
            }else{
                [weakSelf.marrData addObjectsFromArray:array];
            }
            [weakSelf.collectionTableView reloadData];
            [weakSelf.collectionTableView.mj_header endRefreshing];
            [weakSelf.collectionTableView.mj_footer endRefreshing];
            
            if (weakSelf.currentIndex == 1) {
                [self bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.collectionTableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }];
    }
    
    if (_type == CollectionViewTypeThreadFavorites) {
        [BBSSDK getUserThreadFavoritesWithPageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
            if (error) {
                return ;
            }
            
            if (weakSelf.currentIndex == 1) {
                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
            }else{
                [weakSelf.marrData addObjectsFromArray:array];
            }
            [weakSelf.collectionTableView reloadData];
            [weakSelf.collectionTableView.mj_header endRefreshing];
            [weakSelf.collectionTableView.mj_footer endRefreshing];
            
            if (weakSelf.currentIndex == 1) {
                [self bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.collectionTableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }];
    }
    
    if (_type == CollectionViewTypeOtherUserThreadList && self.authorid) { // 查看他人帖子列表
        [BBSSDK getUserThreadListWithAuthorid:self.authorid pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
            if (error) {
                return ;
            }
            
            if (weakSelf.currentIndex == 1) {
                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
            }else{
                [weakSelf.marrData addObjectsFromArray:array];
            }
            [weakSelf.collectionTableView reloadData];
            [weakSelf.collectionTableView.mj_header endRefreshing];
            [weakSelf.collectionTableView.mj_footer endRefreshing];
            
            if (weakSelf.currentIndex == 1) {
                [self bbs_configureTipViewWithFrame:CGRectMake(0, 339, DZSUIScreen_width, 339) tipMessage:@"暂无内容" noDataImage:nil hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.collectionTableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }];
        
    }
}

- (void)setAuthorid:(NSNumber *)authorid {
    _authorid = authorid;
    _currentIndex = 1;
    [self requestData];
}

#pragma mark UITbleview  delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _marrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CollectionCell";
    BBSUICollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUICollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.collectionViewType = _type;
    cell.collection = _marrData[indexPath.row];
    

    
    __weak typeof(self)weakSelf = self;
    cell.addressOnClickBlock = ^(BBSThread *threadModel) {
        CLLocationCoordinate2D coordinate = {threadModel.latitude,threadModel.longitude};
        BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:threadModel.poiTitle];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
        [[MOBFViewController currentViewController].navigationController presentViewController:nav animated:YES completion:nil];
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BBSThread *thread = self.marrData[indexPath.row];
    
    BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:thread];
    
    if ([MOBFViewController currentViewController].navigationController)
    {
        [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 收藏列表可做删除操作，帖子列表不删除
    
    if (_type == CollectionViewTypeThreadFavorites) {
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isDeleting) {
        return;
    }
    _isDeleting = YES;
    
    // 删除模型
    BBSThread *thread = self.marrData[indexPath.row];
    
    __weak typeof (self) weakSelf = self;
    [BBSSDK unFavoriteThreadWithFavid:[NSString stringWithFormat:@"%zd", thread.favid] result:^(NSError *error) {
        if (! error) {
            [weakSelf.marrData removeObjectAtIndex:indexPath.row];

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            _isDeleting = NO;
        }else{
            _isDeleting = NO;
        }
    }];
}

/**
 *  修改Delete按钮文字为“删除”
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}



@end
