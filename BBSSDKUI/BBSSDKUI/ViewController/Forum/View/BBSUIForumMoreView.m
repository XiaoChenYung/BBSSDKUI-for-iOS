//
//  BBSUIForumMoreView.m
//  BBSSDKUI
//
//  Created by 崔林豪 on 2018/4/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIForumMoreView.h"
#import "BBSUIForumHeaderView.h"
#import "UIView+BBSUIExt.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIForumSummaryCellTableViewCell.h"
#import "UIView+BBSUITipView.h"
#import "BBSUICacheManager.h"
#import "BBSForum+BBSUI.h"
#import <MOBFoundation/MOBFViewController.h>
#import "MJRefreshNormalHeader.h"
#import "BBSUIForumThreadListViewController.h"
#import "BBSUIContext.h"
#import "BBSUIForumHeaderFooterView.h"


#define BBSUIPageSize 10

@interface BBSUIForumMoreView ()<UITableViewDelegate, UITableViewDataSource, BBSUIForumSummaryCellDelegate, UIScrollViewDelegate, BBSUIForumHeaderFooterViewDelegate>

@property (nonatomic, strong) UITableView *forumTableView;

@property (nonatomic, strong) BBSUIForumHeaderView *forumHeaderView;

@property (nonatomic, strong) NSMutableArray *stickArray;

@property (nonatomic, strong) NSMutableArray *commonArray;

@property (nonatomic, strong) NSMutableArray *allForumArray;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL needStickAnimation;

@property (nonatomic, assign) BBSUIForumViewControllerType forumType;

@property (nonatomic, strong) BBSUIForumSummaryCellTableViewCell *lastSelectCell;

@property (nonatomic, copy) void (^selectHandler)(BBSForum *forum);

@property (nonatomic, strong) NSMutableArray *allDataArr;

@property (nonatomic, strong) BBSUIForumHeaderFooterView *headerView ;

@property (nonatomic, assign) BOOL isAll;

@end

@implementation BBSUIForumMoreView

- (instancetype)initWithFrame:(CGRect)frame forumType:(BBSUIForumViewControllerType)forumType selectHandler:(void (^)(BBSForum *))selectHandler
{
    self = [super initWithFrame:frame];
    if (self) {
        _isEditing = NO;
        _needStickAnimation = NO;
        _forumType = forumType;
        self.selectHandler = selectHandler;
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
        _needStickAnimation = NO;
        [self getStickForumData];
        [self configureUI];
        [self requestData];
    }
    return self;
}

#pragma mark - initUI
- (void)configureUI
{
    self.isAll = NO;
    //设置tableview
    self.forumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height) style:UITableViewStyleGrouped];
    [self addSubview:self.forumTableView];
    self.forumTableView.sectionHeaderHeight = 40;
    [self.forumTableView setDelegate:self];
    [self.forumTableView setDataSource:self];
    self.forumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.forumTableView.backgroundColor = DZSUIColorFromHex(0xffffff);
    
    __weak typeof(self) weakSelf = self;
    self.forumTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!self.isEditing)
        {
            _needStickAnimation = NO;
        }
        [weakSelf requestData];
    }];

    if ([MOBFDevice versionCompare:@"11.0"] >= 0)
    {
        [self.forumTableView setValue:@0 forKey:@"contentInsetAdjustmentBehavior"];
    }

    //[self.forumTableView.mj_header beginRefreshing];
    [self.forumTableView.mj_header endRefreshing];
}

- (void)configureStickForumsView
{
    [self.forumTableView reloadData];
}

#pragma mark - 加载数据
- (void)requestData
{
    [self getStickForumData];
    __weak typeof(self) weakSelf = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        if (!error) {
            [forumsList enumerateObjectsUsingBlock:^(BBSForum *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.isSticked = NO;
                obj.isExpect = YES;
            }];
            
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumsList];
            //去除全部
            if (weakSelf.forumType == BBSUIForumViewControllerTypeSelectForum) {
                weakSelf.allForumArray = [self _arrayDeleteForumAll:weakSelf.allForumArray];
            }
            //allForumArray 所有数据
            weakSelf.allForumArray = [NSMutableArray arrayWithArray:forumsList];
            [weakSelf _handelAllData:weakSelf.allForumArray];
            
            [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
                [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
                    model.hasEdited = NO;
                }];
            }];
            
            [weakSelf devideForums];
            [weakSelf.forumTableView reloadData];
            [weakSelf bbs_configureTipViewWithTipMessage:@"暂无数据" hasData:weakSelf.allForumArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestData];
            }];
        }
        else
        {
            [weakSelf bbs_configureTipViewWithTipMessage:@"网络不佳，请再次刷新" hasData:weakSelf.allForumArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf requestData];
            }];
            [self.commonArray removeAllObjects];
            [self.stickArray removeAllObjects];
            [self.allForumArray removeAllObjects];
            [self.forumTableView reloadData];
        }
        
        [self.forumTableView.mj_header endRefreshing];
    }];
}
#pragma mark -********对数据进行分组处理************
- (void)_handelAllData:(NSArray *)allData
{
    NSMutableDictionary *res = @{}.mutableCopy;
    for (BBSForum *obj in allData)
    {
        NSString *str = [NSString stringWithFormat:@"%ld", obj.fup];
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
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:res.allValues];
    NSMutableArray *zeroArr = [NSMutableArray array];
    //typeof(self) weakSelf = self;
    for (NSMutableArray *arr in dataArray) {
        for (BBSForum *forum in arr) {
            if ([forum.name isEqualToString:@"全部"]) {
                [zeroArr addObject:forum];
                [arr removeObject:forum];
                break;
            }
        }
    }
    
    [dataArray enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count <= 0) {
            [dataArray removeObjectAtIndex:idx];
        }
    }];

    [dataArray insertObject:zeroArr atIndex:0];
    
    self.allDataArr = [NSMutableArray arrayWithArray:dataArray];
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
    /*
     allForumArray 所有数据
     stickArray 置顶版块数据
     commonArray 论坛版块数据
     isSticked YES置顶 NO不置顶
     */
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

#pragma mark -沙盒获取数据
- (void)getStickForumData
{
    self.stickArray = (NSMutableArray *)[[BBSUICacheManager sharedInstance] getStickForumsWithUid:[BBSUIContext shareInstance].currentUser.uid];
    //去除”全部“模块
    if (self.forumType == BBSUIForumViewControllerTypeSelectForum) {
        self.stickArray = [self _arrayDeleteForumAll:self.stickArray];
    }
    if (!self.stickArray) {
        self.stickArray = [[NSMutableArray alloc] init];
    }
}

/**
 删除置顶与“全部”版块
 */
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
        //删除”全部“版块
        if (self.forumType == BBSUIForumViewControllerTypeSelectForum) {
            if (stickForum.fid == 0) {
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


/**
 去除“全部”版块
 
 @return 处理结果
 */
- (NSMutableArray *)_arrayDeleteForumAll:(NSMutableArray *)array
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:array];
    
    for (BBSForum *forum in array) {
        if (forum.fid == 0) {
            [tmpArray removeObject:forum];
            break;
        }
    }
    
    return tmpArray;
}

#pragma mark - UITableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    
    if (indexPath.section == 0) {
        cell.stickForumArray = self.stickArray;
        cell.forumModel = self.stickArray[indexPath.row];
        cell.delegate = self;
        //[cell.seperateView setHidden:((indexPath.row + 1) == self.stickArray.count)];
        
    }else{
        cell.stickForumArray = self.stickArray;
        //cell.forumModel = self.commonArray[indexPath.row];
        cell.forumModel = self.allDataArr[indexPath.section - 1][indexPath.row];
        cell.delegate = self;
        //[cell.seperateView setHidden:((indexPath.row + 1) == self.commonArray.count)];
    }
    
    if (_forumType == BBSUIForumViewControllerTypeSelectForum)
    {
        // 选择版块
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (self.isEditing)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BBSUIForumSummaryCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_needStickAnimation)
    {
        cell.stickButton.alpha = self.isEditing;
        return;
    }
    
    //1. 配置CATransform3D的内容
    CATransform3D transform;
    transform = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    transform.m34 = 1.0/ -600;
    
    //2. 定义cell的初始状态
    cell.stickButton.alpha = !self.isEditing;
    
    //3. 定义cell的最终状态，并提交动画
    [UIView beginAnimations:@"transform" context:NULL];
    [UIView setAnimationDuration:0.5];
    cell.stickButton.layer.transform = CATransform3DIdentity;
    cell.stickButton.alpha = self.isEditing;
    [UIView commitAnimations];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

#pragma mark - UITableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BBSUIForumHeaderFooterView *headerView = [BBSUIForumHeaderFooterView sectionHeadViewWithTableView:tableView section:section allData:self.allDataArr];
    headerView.deleagte = self;
    headerView.sectionTag = section;
    [headerView updateHeaderView:self.allDataArr isSelectForum:NO];
    self.headerView = headerView;
    
    if (section > 0) {
        NSArray *arr = self.allDataArr[section - 1];
        if (arr.count > 0) {
            BBSForum *forum = arr[0];
            headerView.isclicked = forum.isExpect;
        }
    }

    [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
        [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
            headerView.isEdited = model.hasEdited;
        }];
    }];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_lastSelectCell)
    {
        _lastSelectCell.selectImageView.hidden = YES;
    }
    
    BBSUIForumSummaryCellTableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    
    _lastSelectCell = selectCell;
    
    BBSForum *forum = selectCell.forumModel;
    
    if (_forumType == BBSUIForumViewControllerTypeSelectForum) // 选择版块
    {
        selectCell.selectImageView.hidden = NO;
        
        if ([MOBFViewController currentViewController].navigationController) {
            [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
        }
        if (self.selectHandler) {
            self.selectHandler(forum);
        }
    }
    else
    {
        [self selectForum:forum];
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _needStickAnimation = NO;
}

#pragma mark - BBSUIForumSummaryCellDelegate
- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell
{
    //[self configureStickForumsView];
    [[BBSUICacheManager sharedInstance] setStickForums:self.stickArray uid:[BBSUIContext shareInstance].currentUser.uid];
    [self devideForums];
    [self.forumTableView reloadData];
}

- (void)selectForum:(BBSForum *)forum
{
    BBSUIForumThreadListViewController *threadListViewController = [[BBSUIForumThreadListViewController alloc] initWithForum:forum];
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController pushViewController:threadListViewController animated:YES];
    }
}

#pragma mark - BBSUIForumHeaderFooterView delegate
- (void)editForumHeaderView:(NSInteger)section
{
    self.isEditing = !self.isEditing;

    [self.allDataArr enumerateObjectsUsingBlock:^(NSArray *objArray, NSUInteger idx, BOOL * _Nonnull stop) {
        [objArray enumerateObjectsUsingBlock:^(BBSForum *model, NSUInteger idx, BOOL * _Nonnull stop) {
            model.hasEdited = !model.hasEdited;
        }];
    }];
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