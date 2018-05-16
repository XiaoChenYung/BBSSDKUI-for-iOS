//
//  BBSUIThreadForumListSelectViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadForumListSelectViewController.h"
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

@interface BBSUIThreadForumListSelectViewController ()<UITableViewDelegate, UITableViewDataSource, BBSUIForumSummaryCellDelegate, BBSUIForumHeaderFooterViewDelegate>

//@property (nonatomic, strong) UITableView *tableView ;
@property (nonatomic, copy) void (^result)(BBSForum *) ;
//@property (nonatomic, strong) NSArray *forums;


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

@implementation BBSUIThreadForumListSelectViewController

#define kForumListCellReuseIdentifier @"BBSUIThreadForumListTableViewCellReuseIdentifier"

- (instancetype)initWithResult:(void (^)(BBSForum *))result
{
    if (self = [super init])
    {
        _result = result ;
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

#pragma mark - initUI
- (void)configureUI
{
    //设置tableview
    //self.forumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height) style:UITableViewStyleGrouped];
    CGFloat subheight = 0;
    if (IS_IPHONE_6)
    {
        subheight = 40;
    }
    else
    {
        subheight = 50;
    }
    
    self.forumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height - subheight) style:UITableViewStyleGrouped];

    [self.view addSubview:self.forumTableView];
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
    //[self.forumTableView.mj_header beginRefreshing];
    [self.forumTableView.mj_header endRefreshing];
}

#pragma mark - 数据加载
- (void)requestData
{
    __weak typeof(self) weakSelf = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        if (!error) {
            [weakSelf.view bbs_configureTipViewWithTipMessage:@"" hasData:YES];
            [forumsList enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSticked = NO;
                obj.isExpect = YES;
            }];
            //allForumArray 所有数据
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumsList];
            [weakSelf _handelAllData:weakSelf.allForumArray];
            [weakSelf devideForums];
            [weakSelf.forumTableView reloadData];
        }
        else
        {
            //[weakSelf.forumTableView setHidden:YES];
            [weakSelf.view bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.allForumArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestData];
            }];
        }
        [self.forumTableView.mj_header endRefreshing];
    }];
}

#pragma mark - ********对数据进行分组处理************
- (void)_handelAllData:(NSArray *)allData
{
    NSMutableDictionary *res = @{}.mutableCopy;
    for (BBSForum *obj in allData)
    {
        NSString *str = [NSString stringWithFormat:@"%ld", (long)obj.fup];
        if (res[str])
        {
            [res[str] addObject:obj];
        }
        else
        {
            res[str] = [NSMutableArray arrayWithObject:obj];
        }
    }
    NSLog(@"-----%@",res.allValues);
    self.allDataArr = [NSMutableArray arrayWithArray:res.allValues];
    [self.allDataArr removeLastObject];
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
}

- (void)reloadStickData
{
    [self getStickForumData];
    [self.forumTableView reloadData];
}

#pragma mark - UITableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 2;
    return self.allDataArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        return  self.stickArray.count;
    }
    else
    {
        
        NSArray *sArr = self.allDataArr[section-1];
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
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forumCellIdentifier = @"ForumCellIdentifier";
    BBSUIForumSummaryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:forumCellIdentifier];
    
    if (!cell) {
        cell = [[BBSUIForumSummaryCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:forumCellIdentifier];
    }
    
    /*
     allForumArray 所有数据
     stickArray 置顶版块数据
     commonArray 论坛版块数据
     isSticked YES置顶 NO不置顶
     */
    if (indexPath.section == 0) {
        cell.stickForumArray = self.stickArray;
        cell.forumModel = self.stickArray[indexPath.row];
        [cell.stickButton setHidden:!self.isEditing];
        [cell setStickButtonHidden:!self.isEditing];
        cell.delegate = self;
        //[cell.seperateView setHidden:((indexPath.row + 1) == self.stickArray.count)];
    }
    else
    {
        cell.stickForumArray = self.stickArray;
        
        cell.forumModel = self.allDataArr[indexPath.section - 1][indexPath.row];
        [cell.stickButton setHidden:!self.isEditing];
        [cell setStickButtonHidden:!self.isEditing];
        cell.delegate = self;
        //[cell.seperateView setHidden:((indexPath.row + 1) == self.commonArray.count)];
    }
    [cell hiddForumCountLabel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


#pragma mark - UITableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BBSUIForumHeaderFooterView *headerView = [BBSUIForumHeaderFooterView sectionHeadViewWithTableView:tableView section:section allData:self.allDataArr];
    headerView.deleagte = self;
    headerView.sectionTag = section;
    [headerView updateHeaderView:self.allDataArr isSelectForum:YES];
    
    if (section > 0) {
        NSArray *arr = self.allDataArr[section - 1];
        BBSForum *forum = arr[0];
        headerView.isclicked = forum.isExpect;
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
    if (_result)
    {
        _result(forum);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BBSUIForumSummaryCell  Delegate
//MARK: 存入到沙盒中
- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell
{
    [[BBSUICacheManager sharedInstance] setStickForums:self.stickArray uid:[BBSUIContext shareInstance].currentUser.uid];
    [self devideForums];
    [self.forumTableView reloadData];
}

- (void)selectForum:(BBSForum *)forum
{
    BBSUIForumDetailViewController *threadListViewController = [[BBSUIForumDetailViewController alloc] init];
    threadListViewController.pageType = PageTypeForumToHome;
    threadListViewController.currentForum = forum;
    
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
    }
}

#pragma mark - BBSUIForumHeaderFooterView delegate
- (void)editForumHeaderView
{
    self.isEditing = !self.isEditing;
    [self.forumTableView reloadData];
    
}

- (void)expectForumHeaderView:(NSInteger)section
{
    NSArray *expectArr = self.allDataArr[section - 1];
    [expectArr enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.isExpect = !model.isExpect;
        
    }];
    [self.forumTableView reloadData];
}


@end
