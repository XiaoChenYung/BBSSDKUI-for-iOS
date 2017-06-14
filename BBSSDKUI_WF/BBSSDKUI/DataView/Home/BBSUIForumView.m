//
//  BBSUIForumView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumView.h"
#import "BBSUIForumHeaderView.h"
#import "UIViewExt.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIForumSummaryCellTableViewCell.h"
#import "UIView+TipView.h"
#import "BBSUICacheManager.h"
#import "BBSForum+BBSUI.h"
#import "BBSUIThreadListViewController.h"
#import <MOBFoundation/MOBFViewController.h>
#import "MJRefreshNormalHeader.h"

#define BBSUIPageSize 10

@interface BBSUIForumView ()<UITableViewDelegate, UITableViewDataSource, BBSUIForumSummaryCellDelegate>

@property (nonatomic, strong) UITableView *forumTableView;

@property (nonatomic, strong) BBSUIForumHeaderView *forumHeaderView;

@property (nonatomic, strong) NSMutableArray *stickArray;

@property (nonatomic, strong) NSMutableArray *allForumArray;

@property (nonatomic, assign) BOOL isEditing;

@end

@implementation BBSUIForumView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isEditing = NO;
        [self getStickForumData];
        [self configureUI];
        [self requestData];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isEditing = NO;
        [self getStickForumData];
        [self configureUI];
        [self requestData];
    }
    
    return self;
}

- (void)configureUI
{
    //设置tableview
    self.forumTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    [self addSubview:self.forumTableView];
    [self.forumTableView setDelegate:self];
    [self.forumTableView setDataSource:self];
    
    //设置置顶版块header
    [self configureStickForumsView];
    
    __weak typeof(self) weakSelf = self;
    self.forumTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestData];
    }];
    [self.forumTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.forumTableView.mj_header beginRefreshing];
}

- (void)configureStickForumsView
{
    if (!self.stickArray.count) {

        self.forumTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.001f)];
        [self.forumTableView reloadData];

    }else{
        
        __weak typeof(self) theStickForumView = self;
        if (!self.forumHeaderView) {
            self.forumHeaderView = [[BBSUIForumHeaderView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 0) selectHander:^(BBSForum *forum) {
                [theStickForumView selectForum:forum];
            }];
        }
        if (self.stickArray.count <= 4) {
            self.forumHeaderView.height = 130;
        }else{
            self.forumHeaderView.height = 220;
        }
        
        [self.forumHeaderView setStickForumArray:self.stickArray];
        [self.forumTableView setTableHeaderView:self.forumHeaderView];
        [self.forumTableView.tableHeaderView setUserInteractionEnabled:YES];
        
    }
}

- (void)getStickForumData
{
    self.stickArray = [BBSUICacheManager sharedInstance].stickForums;
    if (!self.stickArray) {
        self.stickArray = [[NSMutableArray alloc] init];
    }
}

- (void)deleteStickForum
{
    NSMutableArray *tmpStickArray = [NSMutableArray array];
    for (BBSForum *stickForum in self.stickArray) {
        BOOL isIn = NO;
        for (BBSForum *tmpForum in self.allForumArray) {
            if (tmpForum.fid == stickForum.fid && [tmpForum.name isEqualToString:stickForum.name]) {
                isIn = YES;
                break;
            }
        }
        
        if (isIn) {
            [tmpStickArray addObject:stickForum];
        }
    }
    
    self.stickArray = tmpStickArray;
    [self configureStickForumsView];
}

#pragma mark - uitableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allForumArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forumCellIdentifier = @"ForumCellIdentifier";
    BBSUIForumSummaryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forumCellIdentifier];
    
    if (!cell) {
        cell = [[BBSUIForumSummaryCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:forumCellIdentifier];
    }
    
    cell.stickForumArray = self.stickArray;
    cell.forumModel = self.allForumArray[indexPath.row];
    [cell.stickButton setHidden:!self.isEditing];
    cell.delegate = self;
    [cell.seperateView setHidden:((indexPath.row + 1) == self.allForumArray.count)];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - uitableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 40)];//创建一个视图
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 30)];
    [titleLabel setText:@"论坛列表"];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [titleLabel setTextColor:DZSUIColorFromHex(0xA3A2AA)];
    [headerView addSubview:titleLabel];
    
    CGFloat editButtonWidth = 80;
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame) - 8 - editButtonWidth, 0, editButtonWidth, 30)];
    [editButton setTitleColor:DZSUIColorFromHex(0x50A3D3) forState:UIControlStateNormal];
    if (self.isEditing) {
        [editButton setTitle:@"完成编辑" forState:UIControlStateNormal];
    }else{
        [editButton setTitle:@"编辑置顶" forState:UIControlStateNormal];
    }
    [editButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [editButton addTarget:self action:@selector(editButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BBSForum *forum = self.allForumArray[indexPath.row];
    [self selectForum:forum];
}

#pragma mark - BBSUIForumSummaryCellDelegate
- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell
{
    [self configureStickForumsView];
    [BBSUICacheManager sharedInstance].stickForums = self.stickArray;
}

- (void)selectForum:(BBSForum *)forum
{
    BBSUIThreadListViewController *threadListViewController = [[BBSUIThreadListViewController alloc] initWithForum:forum];
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
    }
}

#pragma mark - ui handler
- (void)editButtonHandler:(UIButton *)button
{
    self.isEditing = !self.isEditing;
    [self.forumTableView reloadData];
}

#pragma mark - request
- (void)requestData
{
    __weak typeof(self) weakSelf = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        
        if (!error) {
//            [weakSelf.forumTableView setHidden:NO];
            
            [forumsList enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSticked = NO;
            }];
            
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumsList];
            
            //删除置顶版块中不属于当前应用的版块
            [weakSelf deleteStickForum];
           
            [weakSelf.forumTableView reloadData];
            
            
        }else
        {
//            [weakSelf.forumTableView setHidden:YES];
            [weakSelf configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.allForumArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestData];
            }];
        }
        
        [self.forumTableView.mj_header endRefreshing];
        
    }];
}



@end
