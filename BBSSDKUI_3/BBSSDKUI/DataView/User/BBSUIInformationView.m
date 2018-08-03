//
//  BBSUIInformationView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIInformationView.h"
#import "BBSUIInformationTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import "MJRefresh.h"
#import "BBSUIContext.h"
#import "BBSUISystemInformationViewController.h"
#import "BBSUIUserOtherInfoViewController.h"
#import "BBSUIThreadDetailViewController.h"
#import "UIView+BBSUITipView.h"

#define BBSUIInformationCellHeight 65
#define BBSUIPageSize       10

@interface BBSUIInformationView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *marrData;

@end

@implementation BBSUIInformationView

- (instancetype)init{
    if (self = [super init]) {
        [self data];
        [self configUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self data];
        [self configUI];
    }
    
    return self;
}

- (void)data {
    _currentUser = [BBSUIContext shareInstance].currentUser;
    _currentIndex = 1;
    _marrData = [NSMutableArray new];
}

- (void)configUI{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
    tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
    _tableView.tableHeaderView = tableHeaderView;
    
    _tableView.rowHeight = BBSUIInformationCellHeight;
    [self addSubview: _tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    __weak typeof (self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentIndex = 1;
        [weakSelf requestData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex ++;
        [weakSelf requestData];
    }];
    
    [self requestData];
}

- (void)requestData {
    __weak typeof (self) weakSelf = self;
    
    [BBSSDK getNotificationsWithPageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSInformation *> *array, NSError *error) {
        if (weakSelf.currentIndex == 1) {
            weakSelf.marrData = [NSMutableArray arrayWithArray:array];
        }else{
            [weakSelf.marrData addObjectsFromArray:array];
        }
        [weakSelf.tableView reloadData];
        
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        
        if (weakSelf.currentIndex == 1) {
            [weakSelf bbs_configureTipViewWithFrame:self.bounds tipMessage:@"暂无消息" noDataImage:[UIImage BBSImageNamed:@"/Common/noInformation@2x.png"] hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf.tableView.mj_header beginRefreshing];
                [weakSelf requestData];
            }];
        }
    }];
}

#pragma mark UITbleview  delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _marrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"InformationCell";
    BBSUIInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUIInformationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BBSInformation *information = _marrData[indexPath.row];
    cell.information = information;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __block BBSInformation *info = _marrData[indexPath.row];
    BBSUIInformationTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (info.isnew.integerValue == 1) {
        [BBSSDK readNotificationWithNoid:info.noid result:^(NSError *error) {
            if (!error) {
                // 设置消息已读成功
                NSLog(@"%@",@"设置消息已读成功");
                cell.redView.hidden = YES;
                [info setValue:@(0) forKey:@"isnew"];
            }
        }];
    }
    
    
    if ([info.type isEqualToString:@"mob_notice"] ||
        [info.type isEqualToString:@"system"]) {
        BBSUISystemInformationViewController *vc = [BBSUISystemInformationViewController new];
        vc.context = info.note;
        vc.infoTitle = info.title;
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }
    else if ([info.type isEqualToString:@"mob_follow"]) {
        BBSUIUserOtherInfoViewController *vc = [[BBSUIUserOtherInfoViewController alloc] initWithAuthorid:info.authorid];
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }
    
    /**
     喜欢：点击进入对应帖子
     评论您的帖子、回复了你的评论：进入对应的帖子并自动滚动到评论区域
     */
    else if ([info.type isEqualToString:@"mob_like"] ||
             [info.type isEqualToString:@"post"]){
        BBSUIThreadDetailViewController *vc = [[BBSUIThreadDetailViewController alloc] initWithFid:info.fid tid:info.tid];
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除模型
    BBSInformation *information = _marrData[indexPath.row];
    [BBSSDK deleteNotificationWithNoid:information.noid result:^(NSError *error) {
        if (! error) {
            // 刷新
            [_marrData removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
