//
//  BBSUIForumView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumView.h"
//#import "BBSUIForumHeaderView.h"
#import "UIViewExt.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIForumSummaryCellTableViewCell.h"
#import "UIView+TipView.h"
#import "BBSUICacheManager.h"
#import "BBSForum+BBSUI.h"
#import "BBSUIThreadListViewController.h"
#import <MOBFoundation/MOBFViewController.h>
#import "MJRefreshNormalHeader.h"
#import "BBSUIContext.h"

#define BBSUIPageSize 10

@interface BBSUIForumView ()<UITableViewDelegate, UITableViewDataSource, BBSUIForumSummaryCellDelegate>

@property (nonatomic, strong) UITableView *forumTableView;

//@property (nonatomic, strong) BBSUIForumHeaderView *forumHeaderView;

@property (nonatomic, strong) NSMutableArray *stickArray;

@property (nonatomic, strong) NSMutableArray *commonArray;

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
    self.forumTableView.sectionHeaderHeight = 40;
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
//    if (!self.stickArray.count) {

//        self.forumTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.001f)];
        [self.forumTableView reloadData];

//    }
//    else{
//        
//        __weak typeof(self) theStickForumView = self;
//        if (!self.forumHeaderView) {
//            self.forumHeaderView = [[BBSUIForumHeaderView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 0) selectHander:^(BBSForum *forum) {
//                [theStickForumView selectForum:forum];
//            }];
//        }
//        if (self.stickArray.count <= 4) {
//            self.forumHeaderView.height = 130;
//        }else{
//            self.forumHeaderView.height = 220;
//        }
//        
//        [self.forumHeaderView setStickForumArray:self.stickArray];
//        [self.forumTableView setTableHeaderView:self.forumHeaderView];
//        [self.forumTableView.tableHeaderView setUserInteractionEnabled:YES];
//        
//    }
}

- (void)getStickForumData
{
    self.stickArray = (NSMutableArray *)[[BBSUICacheManager sharedInstance] getStickForumsWithUid:[BBSUIContext shareInstance].currentUser.uid];
    if (!self.stickArray) {
        self.stickArray = [[NSMutableArray alloc] init];
    }
}

- (void)reloadStickData
{
    [self getStickForumData];
    [self.forumTableView reloadData];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.stickArray.count;
    }else{
        return [self.commonArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forumCellIdentifier = @"ForumCellIdentifier";
    BBSUIForumSummaryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forumCellIdentifier];
    
    if (!cell) {
        cell = [[BBSUIForumSummaryCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:forumCellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.stickForumArray = self.stickArray;
        cell.forumModel = self.stickArray[indexPath.row];
        [cell.stickButton setHidden:!self.isEditing];
        [cell setStickButtonHidden:!self.isEditing];
        cell.delegate = self;
        [cell.seperateView setHidden:((indexPath.row + 1) == self.stickArray.count)];

    }else{
        cell.stickForumArray = self.stickArray;
        cell.forumModel = self.commonArray[indexPath.row];
        [cell.stickButton setHidden:!self.isEditing];
        [cell setStickButtonHidden:!self.isEditing];
        cell.delegate = self;
        [cell.seperateView setHidden:((indexPath.row + 1) == self.commonArray.count)];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - uitableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 32)];
    UILabel *titleLabel = [[UILabel alloc] init];
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [titleLabel setTextColor:DZSUIColorFromHex(0x6A7081)];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    if (section == 0) {
        [titleLabel setFrame:CGRectMake(15, 0, DZSUIScreen_width, 32)];
        [titleLabel setText:@"置顶版块"];
        
        CGFloat editButtonWidth = 30;
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame) - 15 - editButtonWidth, 0, editButtonWidth, 32)];
        [editButton setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
        if (self.isEditing) {
            [editButton setTitle:@"完成" forState:UIControlStateNormal];
        }else{
            [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        }
        [editButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [editButton addTarget:self action:@selector(editButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:editButton];
    }else{
        [titleLabel setFrame:CGRectMake(15, -17, DZSUIScreen_width, 32)];
        [titleLabel setText:@"论坛列表"];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 32;
    }else{
        return 15;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BBSUIForumSummaryCellTableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    BBSForum *forum = selectCell.forumModel;
//    BBSForum *forum = self.allForumArray[indexPath.row];
    [self selectForum:forum];
}

#pragma mark - BBSUIForumSummaryCellDelegate
- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell
{
//    [self configureStickForumsView];
//    [BBSUICacheManager sharedInstance].stickForums = self.stickArray;
    [[BBSUICacheManager sharedInstance] setStickForums:self.stickArray uid:[BBSUIContext shareInstance].currentUser.uid];
    [self devideForums];
    [self.forumTableView reloadData];
}

- (void)selectForum:(BBSForum *)forum
{
    BBSUIThreadListViewController *threadListViewController = [[BBSUIThreadListViewController alloc] initWithForum:forum];
    threadListViewController.pageType = PageTypeForumToHome;
    
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
            
            
//            for (int i = 0; i < forumsList.count; i++) {
//                BBSForum *originForum = forumsList[i];
//                for (int j = 0; j < weakSelf.stickArray.count; j++) {
//                    BBSForum *stickForum = weakSelf.stickArray[j];
//                    if (originForum.fid == stickForum.fid) {
//                        stickForum.isSticked = YES;
//                    }
//                }
//            }
            
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumsList];
            
            //删除置顶版块中不属于当前应用的版块
//            [weakSelf deleteStickForum];
            [weakSelf devideForums];
           
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

- (void)devideForums
{
    if (!self.commonArray) {
        self.commonArray = [NSMutableArray new];
    }else{
        [self.commonArray removeAllObjects];
    }
    
    BOOL isIn = NO;
    BBSForum *tmpForum = nil;
    for (int i = 0; i < self.allForumArray.count; i++) {
        tmpForum = self.allForumArray[i];
        for (int j = 0; j < self.stickArray.count; j++) {
            BBSForum *stickForum = self.stickArray[j];
            if (tmpForum.fid == stickForum.fid) {
                stickForum.isSticked = YES;
                isIn = YES;
            }
        }
        if (isIn) {
            tmpForum.isSticked = YES;
        }else{
            tmpForum.isSticked = NO;
            [self.commonArray addObject:tmpForum];
        }
        
        isIn = NO;
    }
}


@end