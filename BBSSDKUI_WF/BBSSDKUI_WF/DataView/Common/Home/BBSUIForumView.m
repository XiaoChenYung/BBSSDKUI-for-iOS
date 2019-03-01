//
//  BBSUIForumView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumView.h"
#import "UIView+BBSUIExt.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIForumSummaryCellTableViewCell.h"
#import "UIView+BBSUITipView.h"
#import "BBSUICacheManager.h"
#import "BBSForum+BBSUI.h"
#import "BBSUIThreadListViewController.h"
#import <MOBFoundation/MOBFViewController.h>
#import "MJRefreshNormalHeader.h"
#import "BBSUIContext.h"
#import "BBSUIForumDetailViewController.h"
#import "BBSUIForumHeaderFooterView.h"


#define BBSUIPageSize 10

@interface BBSUIForumView ()<UITableViewDelegate, UITableViewDataSource, BBSUIForumSummaryCellDelegate, BBSUIForumHeaderFooterViewDelegate>

@property (nonatomic, strong) UITableView *forumTableView;

/**
 置顶版块的数据
 */
@property (nonatomic, strong) NSMutableArray *stickArray;

/**
 论坛列表的数组
 */
@property (nonatomic, strong) NSMutableArray *commonArray;

/**
 所有的数组
 */
@property (nonatomic, strong) NSMutableArray *allForumArray;

@property (nonatomic, strong) NSMutableArray *allDataArr;


@property (nonatomic, assign) BOOL isEditing;

@end

@implementation BBSUIForumView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _isEditing = NO;
//
//        [self getStickForumData];
//        [self configureUI];
//        [self requestData];
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

#pragma mark - initUI
- (void)configureUI
{
    //设置tableview
    //self.forumTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
//    CGFloat subheight = 0;
//    if (IS_IPHONE_6)
//    {
//        subheight = 40;
//    }
//    else
//    {
//        subheight = 50;
//    }
    
    self.forumTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self addSubview:self.forumTableView];
    [self.forumTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.forumTableView.contentInset = UIEdgeInsetsMake(0, 0, [[UIDevice currentDevice] inner_isIphoneXOrLater] ? 34 : 0, 0);
    self.forumTableView.sectionHeaderHeight = 0.01;
    self.forumTableView.sectionFooterHeight = 0.01;
    self.forumTableView.estimatedRowHeight = 60.0;
    self.forumTableView.rowHeight = UITableViewAutomaticDimension;
    [self.forumTableView setDelegate:self];
    [self.forumTableView setDataSource:self];
    
    //设置置顶版块header
    [self configureStickForumsView];
    
    __weak typeof(self) weakSelf = self;
    self.forumTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestData];
    }];
    
//    if ([MOBFDevice versionCompare:@"11.0"] >= 0)
//    {
//        [self.forumTableView setValue:@0 forKey:@"contentInsetAdjustmentBehavior"];
//    }
    
    [self.forumTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.forumTableView.mj_header beginRefreshing];
    [self.forumTableView.mj_header endRefreshing];
}

#pragma mark - 数据加载
- (void)requestData
{
    __weak typeof(self) weakSelf = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        if (!error) {
            [weakSelf bbs_configureTipViewWithTipMessage:@"" hasData:YES];
            NSMutableArray *forumArray = [NSMutableArray arrayWithArray:forumsList];
            [self _deleteAllforumNameModel:forumArray];
            [self _handelAllData:forumArray];
            //allForumArray 所有数据
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumArray];

            [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
                [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
                    model.hasEdited = NO;
                }];
            }];
            
            [weakSelf _handelAllData:weakSelf.allForumArray];
            [weakSelf devideForums];
            
            [weakSelf.forumTableView reloadData];
            [self.forumTableView.mj_header endRefreshing];
        }
        else
        {
            //[weakSelf.forumTableView setHidden:YES];
            [weakSelf bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.allForumArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestData];
            }];
        }
        [self.forumTableView.mj_header endRefreshing];
    }];
}

#pragma mark - ********对数据进行分组处理************
- (void)_deleteAllforumNameModel:(NSMutableArray *)forumArray
{
    [forumArray enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"全部"]) {
            [forumArray removeObject:obj];
        }
    }];
    
    [forumArray enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSticked = NO;
        obj.isExpect = YES;
        
    }];
}

- (void)_handelAllData:(NSArray *)allData
{
    NSMutableDictionary *res = @{}.mutableCopy;
    for (BBSForum *obj in allData)
    {
        NSString *string = [NSString stringWithFormat:@"%ld", (long)obj.fup];
//        NSLog(@"----sss---%@", string);
        if (res[string])
        {
            [res[string] addObject:obj];
        }
        else
        {
            res[string] = [NSMutableArray arrayWithObject:obj];
        }
    }
    
//    NSLog(@"-----%@",res.allValues);
    self.allDataArr = [NSMutableArray arrayWithArray:res.allValues];
    
//    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:res.allValues];
//    NSMutableArray *zeroArr = [NSMutableArray array];
//
//    for (NSMutableArray *arr in dataArray) {
//        for (BBSForum *forum in arr) {
//            if ([forum.name isEqualToString:@"全部"]) {
//                [zeroArr addObject:forum];
//                [arr removeObject:forum];
//                break;
//            }
//        }
//    }
//
//    [dataArray enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.count <= 0) {
//            [dataArray removeObjectAtIndex:idx];
//        }
//    }];
//    [dataArray insertObject:zeroArr atIndex:0];
//
//    self.allDataArr = [NSMutableArray arrayWithArray:dataArray];
}

- (void)devideForums
{
    if (!self.commonArray) {
        self.commonArray = [NSMutableArray new];
    }else{
        [self.commonArray removeAllObjects];
    }
    
    //====有新的section 论坛列表标题
    //每一个数组中都有被置顶的，然后每个数组都处理一下
    
    BOOL isIn = NO;
    BBSForum *tmpForum = nil;
    /*
     allForumArray 所有数据
     stickArray 置顶版块数据
     commonArray 论坛版块数据
     isSticked YES置顶 NO不置顶
     */
    for (int i = 0; i < self.allForumArray.count; i++) {
        tmpForum = self.allForumArray[i];
        for (int j = 0; j < self.stickArray.count; j++) {
            //==
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
        
        [self.allDataArr enumerateObjectsUsingBlock:^(NSMutableArray *objArr, NSUInteger idx, BOOL * _Nonnull stop) {
            [objArr enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
                if (model.isSticked) {
                    [objArr removeObject:model];
                }
            }];
        }];
        isIn = NO;
    }
    [self _handelAllData:self.commonArray];
    
}

#pragma mark - 设置置顶版块header
- (void)configureStickForumsView
{
    [self.forumTableView reloadData];
}

#pragma mark - 沙盒中取出来
- (void)getStickForumData
{
    //stickArray 置顶版块的数组  从沙盒里面取出来
    self.stickArray = (NSMutableArray *)[[BBSUICacheManager sharedInstance] getStickForumsWithUid:[BBSUIContext shareInstance].currentUser.uid];
    if (!self.stickArray) {
        self.stickArray = [[NSMutableArray alloc] init];
    }
    
    [self.stickArray enumerateObjectsUsingBlock:^(BBSForum *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"====333==%@=%ld",obj.name, (long)obj.todayposts);
    }];
    
}

- (void)reloadStickData
{
    [self getStickForumData];
    [self.forumTableView reloadData];
}

#pragma mark - UITableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
//    if (section == 0)
//    {
//        return  self.stickArray.count;
//    }
//    else
//    {
    
        NSArray *sArr = self.allDataArr[section];
        for (BBSForum *model in sArr) {
            if (model.isExpect)
            {
                return sArr.count;
            }
            else
            {
                return 0;
            }
        }
//    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forumCellIdentifier = @"ForumCellIdentifier";
    BBSUIForumSummaryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forumCellIdentifier];
    
    if (!cell) {
        cell = [[BBSUIForumSummaryCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:forumCellIdentifier];
    }
    cell.isCube = indexPath.section == 1;
    
    /*
     allForumArray 所有数据
     stickArray 置顶版块数据
     commonArray 论坛版块数据
     isSticked YES置顶 NO不置顶
     */
//    if (indexPath.section == 0) {
//        cell.stickForumArray = self.stickArray;
//        cell.forumModel = self.stickArray[indexPath.row];
//        [cell.stickButton setHidden:!self.isEditing];
//        [cell setStickButtonHidden:!self.isEditing];
//        cell.delegate = self;
//        //[cell.seperateView setHidden:((indexPath.row + 1) == self.stickArray.count)];
//    }
//    else
//    {
        cell.stickForumArray = self.stickArray;
        cell.forumModel = self.allDataArr[indexPath.section][indexPath.row];
        [cell.stickButton setHidden:!self.isEditing];
        [cell setStickButtonHidden:!self.isEditing];
        cell.delegate = self;
        //[cell.seperateView setHidden:((indexPath.row + 1) == self.commonArray.count)];
//    }

    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60.0f;
//}


#pragma mark - UITableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BBSUIForumHeaderFooterView *headerView = [BBSUIForumHeaderFooterView sectionHeadViewWithTableView:tableView section:section allData:self.allDataArr];
    headerView.deleagte = self;
    headerView.sectionTag = section;
    [headerView updateHeaderView:self.allDataArr isSelectForum:NO];
    
//    if (section > 0) {
        NSArray *arr = self.allDataArr[section];
        if (arr.count > 0) {
            BBSForum *forum = arr[0];
            headerView.isclicked = forum.isExpect;
        }
//    }
    
//    if (self.stickArray.count > 0) {
//        BBSForum *stickForum = self.stickArray[0];
//        headerView.isEdited = stickForum.hasEdited;
//    }
    [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
        [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
            headerView.isEdited = model.hasEdited;
        }];
    }];

    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 32;
//    }else{
        return 40;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BBSUIForumSummaryCellTableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    BBSForum *forum = selectCell.forumModel;
    [self selectForum:forum];
}

#pragma mark - BBSUIForumSummaryCell  Delegate
//MARK: 存入到沙盒中 ??stickArray 增加数据
- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell
{
    [self.stickArray enumerateObjectsUsingBlock:^(BBSForum *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"====55555==%@=%ld",obj.name, (long)obj.todayposts);
    }];
    [[BBSUICacheManager sharedInstance] setStickForums:self.stickArray uid:[BBSUIContext shareInstance].currentUser.uid];
    
    [self devideForums];
    [self.forumTableView reloadData];
}

- (void)selectForum:(BBSForum *)forum
{
    BBSUIForumDetailViewController *threadListViewController = [[BBSUIForumDetailViewController alloc] init];
    threadListViewController.pageType = PageTypeForumToHome;
    threadListViewController.currentForum = forum;
    threadListViewController.hidesBottomBarWhenPushed = true;
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
    }
}

#pragma mark - BBSUIForumHeaderFooterView delegate
- (void)editForumHeaderView
{
     self.isEditing = !self.isEditing;
//    [self.stickArray enumerateObjectsUsingBlock:^(BBSForum *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.hasEdited = !obj.hasEdited ;
//    }];
    [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
        [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
            model.hasEdited = !model.hasEdited;
        }];
    }];
    
    [self.forumTableView reloadData];
    
}

- (void)expectForumHeaderView:(NSInteger)section
{
    NSArray *expectArr = self.allDataArr[section];
    [expectArr enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.isExpect = !model.isExpect;

    }];
    [self.forumTableView reloadData];
}

@end
