//
//  BBSUIFansView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIFansView.h"
#import "BBSUIFansTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSFans.h>
#import <BBSSDK/BBSSDK.h>
#import "MJRefresh.h"
#import "BBSUIUserOtherInfoViewController.h"
#import "UIView+BBSUITipView.h"
#import "BBSUIContext.h"

#define BBSUIFansCellHeight 65
#define BBSUIPageSize       10

@interface BBSUIFansView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *marrData;

@property (nonatomic, assign) BBSUIFansType type;

@property (nonatomic, strong) BBSUser *currentUser;

@end

@implementation BBSUIFansView

- (instancetype)init:(BBSUIFansType)type currentUser:(BBSUser *)currentUser
{
    self = [super init];
    if (self) {
        [self data:type :currentUser];
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tpye:(BBSUIFansType)type currentUser:(BBSUser *)currentUser
{
    self = [super initWithFrame:frame];
    if (self) {
        [self data:type :currentUser];
        [self configureUI];
    }
    
    return self;
}

- (void)data:(BBSUIFansType)type :(BBSUser *)currentUser{
    _type = type;
    if (!currentUser) {
        _currentUser = [BBSUIContext shareInstance].currentUser;
    }else{
        _currentUser = currentUser;
    }
    _currentIndex = 1;
}

- (void)configureUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.backgroundColor = DZSUI_BackgroundColor;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
    tableHeaderView.backgroundColor = DZSUI_BackgroundColor;

    [self.tableView setTableHeaderView:tableHeaderView];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    __weak typeof (self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentIndex = 1;
        [weakSelf requestData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentIndex ++;
        [weakSelf requestData];
    }];
    
}

- (void)refreshData {
    self.currentIndex = 1;
    [self requestData];
}

- (void)requestData {
    __weak typeof (self) weakSelf = self;
    
    NSNumber *uid = nil;
    if (_type == BBSUIFansTypeFirendsOther || _type == BBSUIFansTypeFollowersOther) {
        uid = _currentUser.uid;
    }
    
    if (_type == BBSUIFansTypeFirendsMe || _type == BBSUIFansTypeFirendsOther) {
        [BBSSDK getFirendsWithAuthorid:uid pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSFans *> *array, NSError *error) {
            if (weakSelf.currentIndex == 1) {
                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
            }else{
                [weakSelf.marrData addObjectsFromArray:array];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            
            if (weakSelf.currentIndex == 1) {
                [weakSelf bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }];
    }
    else{
        [BBSSDK getFollowersWithAuthorid:uid pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSFans *> *array, NSError *error) {
            if (weakSelf.currentIndex == 1) {
                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
            }else{
                [weakSelf.marrData addObjectsFromArray:array];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            
            if (weakSelf.currentIndex == 1) {
                [weakSelf bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                    [weakSelf requestData];
                }];
            }
        }];
    }
    
}

#pragma mark - uitableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _marrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FansCell";
    BBSUIFansTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUIFansTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BBSFans *fans = _marrData[indexPath.row];
    [cell setFans:fans];
    if (_type == BBSUIFansTypeFirendsMe) {// 我的关注
        [cell.attentionButton setImage:[UIImage BBSImageNamed:@"/User/CancelAttention.png"] forState:UIControlStateNormal];
        
    }else{
        if (fans.isFollow.integerValue == 1) {
            [cell.attentionButton setImage:[UIImage BBSImageNamed:@"/User/CancelAttention.png"] forState:UIControlStateNormal];
        }else{
            [cell.attentionButton setImage:[UIImage BBSImageNamed:@"/User/Attention.png"] forState:UIControlStateNormal];
        }
    }
    
    [cell.attentionButton addTarget:self action:@selector(attentionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.attentionButton.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BBSUIFansCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BBSFans *fans = _marrData[indexPath.row];
    BBSUIUserOtherInfoViewController *vc = [[BBSUIUserOtherInfoViewController alloc] initWithAuthorid:fans.uid];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}


#pragma mark Action

- (void)attentionButtonClick:(UIButton *)button {
    // BBSUIFansTableViewCell *viewCell = (BBSUIFansTableViewCell *)button.superview.superview;
    // NSIndexPath *indexPath = [self.tableView indexPathForCell:viewCell];
    
    BBSFans *fans = _marrData[button.tag];
    
    __weak typeof (self) weakSelf = self;
    
    if (self.type == BBSUIFansTypeFirendsMe) {
        [BBSSDK unfollowWithFollowuid:fans.uid result:^(NSError *error) {
            if (! error) {
                NSLog(@"取消关注成功");
                [_marrData removeObjectAtIndex:button.tag];
                [weakSelf.tableView reloadData];
            }
        }];
    }else{
        if (fans.isFollow.integerValue == 1) {
            [BBSSDK unfollowWithFollowuid:fans.uid result:^(NSError *error) {
                if (! error) {
                    NSLog(@"取消关注成功");
                    [fans setValue:@(0) forKey:@"isFollow"];
                    [weakSelf.tableView reloadData];
                }
            }];
        }else{
            [BBSSDK followWithFollowuid:fans.uid result:^(NSError *error) {
                if (! error) {
                    NSLog(@"关注成功");
                    [fans setValue:@(1) forKey:@"isFollow"];
                    [weakSelf.tableView reloadData];
                }
            }];
        }
    }
    
    
    
    
    //...
}


@end







