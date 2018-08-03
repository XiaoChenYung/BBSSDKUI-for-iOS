//
//  BBSUIThreadListViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2018/1/9.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIThreadListViewController.h"
#import "BBSUILBSegmentControl.h"
#import "BBSUIForumViewController.h"
#import "BBSUILoginViewController.h"
#import "BBSUISearchViewController.h"
#import "BBSUIContext.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import <MOBFoundation/MOBFoundation.h>
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUIStatusBarTip.h"
#import "BBSUIUserHomeViewController.h"
#import "BBSUIFastPostViewController.h"
#import "UINavigationBar+Awesome.h"
#import "BBSUIThreadBanner.h"
#import <BBSSDK/BBSBanner.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "BBSUIThreadSummaryCell.h"
#import "MJRefresh.h"
#import <BBSSDK/BBSSDK.h>
#import "UIView+BBSUITipView.h"
#import "NSString+ThreadOrderType.h"
#import "BBSUIForumHeader.h"
#import <BBSSDK/BBSForum.h>
#import "BBSUIForumThreadListViewController.h"
#import "BBSUIBannerPreviewViewController.h"
#import "BBSThread+BBSUI.h"
#import "UIButton+WebCache.h"
#import "BBSUIPortalDetailViewController.h"
#import "BBSUIThreadDetailViewController.h"
#import <objc/message.h>
#import "BBSUIContext.h"
#import "BBSUILBSShowLocationViewController.h"



static NSString *BBSUIHomeTableIdentifier = @"BBSUIHomeTableIdentifier";
static NSInteger    BBSUIPageSize = 10;

@interface BBSUIThreadListViewController ()<iBBSUIFastPostViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CycleViewDelegate>

@property (nonatomic, strong) UILabel           *titleLabel;

@property (nonatomic, strong) NSArray           *bannerArray;

@property (nonatomic, assign) NSInteger         currentIndex;

@property (nonatomic, strong) NSMutableArray    *threadListArray;

@property (nonatomic, strong) BBSUIForumHeader  *forumHeader;

@property (nonatomic, strong) UIImageView       *maskImage;

@property (nonatomic, strong) BBSUIThreadBanner *bannerView;

@property (nonatomic, assign) NSInteger         currentUserId;

@property (nonatomic, assign) NSInteger catid;

@property (nonatomic, assign) CGFloat iphoneXTopPadding;

@property (nonatomic, assign) NSInteger allowcomment;

@property (nonatomic, strong) UILabel *bannerLab;

@end

@implementation BBSUIThreadListViewController

#pragma mark - 懒加载 Lazy Load
- (UILabel *)bannerLab
{
    if (!_bannerLab) {
        _bannerLab = [[UILabel alloc] init];
        [self.maskImage addSubview:_bannerLab];
        [_bannerLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-70);
            make.left.mas_equalTo(20);
        }];
        _bannerLab.textColor = DZSUIColorFromHex(0xffffff);
        _bannerLab.text = @"请前往开发者后台设置Banner";
        _bannerLab.font = BBSFont(20);
    }
    return  _bannerLab;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self _configureUI];
    [self _initData];
    [self _requestData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    [self _refreshUI];
    
    if (self.homeTableView) {
        [self.homeTableView setDelegate:self];
    }
    
    //切换用户时，可能由于权限不同，可见版块需要重新刷新
    if (self.currentUserId != [[BBSUIContext shareInstance].currentUser.uid integerValue]) {
        [self _requestForumList];
        self.currentUserId = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.homeTableView.delegate = nil;
//    [self.navigationController.navigationBar lt_reset];
    
}

- (void)dealloc
{
    
}

- (instancetype)initWithCatid:(NSInteger)catid allowcomment:(NSInteger)allowcomment
{
    self = [super init];
    if (self) {
        self.catid = catid;
        self.allowcomment = allowcomment;
    }
    
    return self;
}


#pragma mark - private UI & UI handler
-(void)_configureUI
{
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        _iphoneXTopPadding = 30;
    }
    
    #pragma mark --------gai
    //_homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _iphoneXTopPadding, DZSUIScreen_width, DZSUIScreen_height-_iphoneXTopPadding) style:UITableViewStylePlain];
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height-_iphoneXTopPadding) style:UITableViewStylePlain];
    
    _homeTableView.delegate = self;
    _homeTableView.dataSource = self;
    _homeTableView.backgroundColor = [UIColor clearColor];
    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _homeTableView.fd_debugLogEnabled = YES;
    [_homeTableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:BBSUIHomeTableIdentifier];
    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _homeTableView.estimatedRowHeight = 135;
    _homeTableView.rowHeight = UITableViewAutomaticDimension;
    
    if ([MOBFDevice versionCompare:@"11.0"] >= 0) {
        
        // 为了兼容低版本xcode编译通过,这里使用kvc,(也可以使用发射方法,或者其他方法)
        [_homeTableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
//        _homeTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:_homeTableView];
    
    __weak typeof(self) theController = self;
    _homeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        theController.currentIndex = 1;
        [theController _requestData];
        
    }];
    
    _homeTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        theController.currentIndex++;
        [theController _requestData];
    }];
    
    //    [_homeTableView.mj_header beginRefreshing];
    
    //设置tableheader
    _homeTableView.tableHeaderView = [self _obtainHeaderView];
    
}

- (UIView *)_obtainHeaderView
{
    //计算版块点击高度
    //    CGFloat forumViewHeight = DZSUIScreen_height / 7;
    
    CGFloat forumViewHeight;
    if (self.viewType == BBSUIThreadListViewTypeThread)
    {
        forumViewHeight = 105;
    }else
    {
        forumViewHeight = 45;
    }
     
    //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 245 + forumViewHeight)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 245 + forumViewHeight)];
    
    if (self.viewType == BBSUIThreadListViewTypeThread)
    {
        [headerView setBackgroundColor:[UIColor blackColor]];
        
        self.bannerView = [[BBSUIThreadBanner alloc]
                           initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                    247)];
        [headerView addSubview:self.bannerView];
        
        //加载广告条
        self.maskImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BBS_WIDTH(self.bannerView), BBS_HEIGHT(self.bannerView))];
    
        __weak typeof(self) theController = self;
        _forumHeader = [[BBSUIForumHeader alloc] initWithFrame:CGRectMake(0, BBS_BOTTOM(self.bannerView), DZSUIScreen_width, forumViewHeight)];
        [_forumHeader setResultHandler:^(BBSForum *forum){
            [theController _pushForumVC:forum];
        }];
        [headerView addSubview:_forumHeader];
        
        [self.maskImage setImage:[UIImage BBSImageNamed:@"/Home/BannerMask.png"]];
        [headerView addSubview:self.maskImage];
    }
    else
    {
        headerView.backgroundColor = [UIColor whiteColor];
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 245 + forumViewHeight, DZSUIScreen_width, 5)];
        viewLine.backgroundColor = DZSUIColorFromHex(0xEDEFF3);
        [headerView addSubview:viewLine];
    }
    
    return headerView;
}

- (void)setCustomNavTitleView
{
    //首页所有帖子列表视图
    
}

#pragma mark -全部财经体育跳转
- (void)_pushForumVC:(BBSForum *)forum
{
    if (forum) {
        
        BBSUIForumThreadListViewController *threadListVC = [[BBSUIForumThreadListViewController alloc] initWithForum:forum];
        [self.navigationController pushViewController:threadListVC animated:YES];
        
    }else{
        BBSUIForumViewController *form = [[BBSUIForumViewController alloc] init];
        [self.navigationController pushViewController:form animated:YES];
    }
}

#pragma mark - private data
- (void)_initData
{
    self.currentIndex = 1;
    self.currentUserId = [[BBSUIContext shareInstance].currentUser.uid integerValue];
//    self.stateStarted = YES;
}

#pragma mark -数据加载
- (void)_requestData
{
    if (self.viewType == BBSUIThreadListViewTypePortal)
    {
        [self _requestPortalList];
        [self _requestPortalBanner];
    }
    else
    {
        [self _requestThreadList];
        [self _requestBannerList];
        [self _requestForumList];
    }
    
}

- (void)_requestThreadList
{
    __weak typeof(self) theController = self;
    [BBSSDK getThreadListWithFid:0 orderType:[NSString orderTypeStringFromOrderType:BBSUIThreadOrderPostTime] selectType:[NSString selectTypeStringFromSelectType:BBSUIThreadSelectTypeLatest] pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
        
        if (!error) {
            if (theController.currentIndex == 1) {
                theController.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else{
                [theController.threadListArray addObjectsFromArray:threadList];
            }
            
            [theController.homeTableView reloadData];
            [theController.homeTableView.mj_footer setHidden:NO];
            
            if (threadList.count < BBSUIPageSize) {
                [theController.homeTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (theController.currentIndex == 1) {
                
                CGRect tipFrame = (CGRect){0,350,DZSUIScreen_width,DZSUIScreen_height - 350};
                
                [theController.homeTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"暂无内容" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    
                    [theController.homeTableView.mj_header beginRefreshing];
                    [theController _requestData];
                }];
                
            }
        }
        else
        {
            NSLog(@"%@",error);
            CGRect tipFrame = (CGRect){0,350,DZSUIScreen_width,DZSUIScreen_height - 350};
            
            [theController.homeTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"网络不佳，请再次刷新" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                
                [theController.homeTableView.mj_header beginRefreshing];
                [theController _requestData];
                
            }];
        }
        
        [theController.homeTableView.mj_header endRefreshing];
        [theController.homeTableView.mj_footer endRefreshing];
        
    }];
}

- (void)_requestPortalBanner
{
    __weak typeof(self) theView = self;
    //加载广告条
    [BBSSDK getPortalBannerList:^(NSArray *bannnerList, NSError *error) {
        
        NSLog(@" barnerlist = %@",bannnerList);
        
        theView.bannerArray = bannnerList;
        
        if (self.refreshBannerBlock)
        {
            self.refreshBannerBlock(_bannerArray, error);
        }
    }];
}

- (void)_requestPortalList
{
    __weak typeof(self) theController = self;
    
    [BBSSDK getPortalListWithCatid:self.catid pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
        
        if (!error) {
            
            if (theController.currentIndex == 1) {
                theController.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else{
                [theController.threadListArray addObjectsFromArray:threadList];
            }
            
            [theController.homeTableView reloadData];
            [theController.homeTableView.mj_footer setHidden:NO];
            
            if (threadList.count < BBSUIPageSize) {
                [theController.homeTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (theController.currentIndex == 1) {
                
                CGRect tipFrame = (CGRect){0,350,DZSUIScreen_width,DZSUIScreen_height - 350};
                
                [theController.homeTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"暂无内容" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    
                    [theController.homeTableView.mj_header beginRefreshing];
                    [theController _requestData];
                    
                }];
                theController.homeTableView.tableFooterView = nil;
            }
        
            else if (threadList.count == 0)
            {
                UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 50)];
                footLabel.textColor = [UIColor lightGrayColor];
                footLabel.text = @"以上已为全部内容";
                footLabel.textAlignment = NSTextAlignmentCenter;
                footLabel.font = [UIFont systemFontOfSize:13];
                theController.homeTableView.tableFooterView = footLabel;
            }
        }
        else
        {
            NSLog(@"%@",error);
            CGRect tipFrame = (CGRect){0,350,DZSUIScreen_width,DZSUIScreen_height - 350};
            
            [theController.homeTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"网络不佳，请再次刷新" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                
                [theController.homeTableView.mj_header beginRefreshing];
                [theController _requestData];
                
            }];
        }
        
        [theController.homeTableView.mj_header endRefreshing];
        [theController.homeTableView.mj_footer endRefreshing];
        
    }];
}

#pragma mark - 加载Banner
- (void)_requestBannerList
{
    __weak typeof(self) theHomeVC = self;
    [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
        
        if (_viewType == BBSUIThreadListViewTypePortal)
        {
            if (self.refreshBannerBlock)
            {
                self.refreshBannerBlock(bannnerList, error);
            }
            
            return;
        }
        
        if (bannnerList.count > 0) {
            
            theHomeVC.maskImage.hidden = YES;
            theHomeVC.bannerLab.hidden = YES;
            theHomeVC.bannerArray = bannnerList;
            
            NSMutableArray *titleArray = [NSMutableArray array];
            NSMutableArray *pictureArray = [NSMutableArray array];
            [bannnerList enumerateObjectsUsingBlock:^(BBSBanner *  _Nonnull banner, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [pictureArray addObject:banner.picture ? banner.picture : @""];
                [titleArray addObject:banner.title ? banner.title : @""];
            }];
            
            theHomeVC.bannerView.picDataArray = [pictureArray copy];
            theHomeVC.bannerView.titleDataArray = [titleArray copy];
            
            if (pictureArray.count > 1) {
                theHomeVC.bannerView.isAutomaticScroll = YES;
            }else{
                theHomeVC.bannerView.isAutomaticScroll = NO;
                theHomeVC.bannerView.scrollEnabled = NO;
            }
            
            theHomeVC.bannerView.automaticScrollDelay = 5;
            theHomeVC.bannerView.cycleViewStyle = CycleViewStyleBoth;
            theHomeVC.bannerView.pageControlTintColor = [UIColor blackColor];
            theHomeVC.bannerView.pageControlCurrentColor = [UIColor whiteColor];
            theHomeVC.bannerView.delegate = theHomeVC;
            theHomeVC.bannerView.titleLabelTextColor = [UIColor whiteColor];
            
        }
        else
        {
            
            theHomeVC.maskImage.hidden = NO;
            [theHomeVC.maskImage setImage:[UIImage BBSImageNamed:@"/Home/bannerDefault@2x.png"]];
            theHomeVC.bannerLab.hidden = NO;
        }
        
    }];
    
}

- (void)_requestForumList
{
    __weak typeof(self) theController = self;
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        
        [theController.forumHeader setForumList:forumsList];
        
    }];
}

- (void)_setCustomTitleView
{
//    _navTitleLabel = [UILabel new];
//    [_navTitleLabel setFrame:CGRectMake(0, 0, 60, 44)];
//    [_navTitleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:16]];
//    [_navTitleLabel setTextColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0]];
//    [_navTitleLabel setText:@"首页"];
//    [_navTitleLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.navigationItem setTitleView:_navTitleLabel];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor * color = [UIColor whiteColor];
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (self.offSetBlock)
    {
        self.offSetBlock(offsetY);
    }
    
    //CGFloat distance = offsetY + 64.0;
    CGFloat screenW = DZSUIScreen_width;
    CGFloat avatarW = screenW*250.0/1080.0;
    
    CGFloat oldY = - 20.0- (screenW*40.0/1080.0-44.0) ;
    CGFloat offsetYL = avatarW - 64.0 - 44.0;
    
    if (offsetY > offsetYL + oldY) {
        
        //64的距离，alpha从0到1。
        CGFloat alpha;
        CGFloat btnAlpha;
        if (offsetY-(offsetYL + oldY) < 64.0) {
            alpha = (offsetY-(offsetYL + oldY))/64.0;
            if (offsetY-(offsetYL + oldY) < 32.0) {
                btnAlpha = 1 - (offsetY-(offsetYL + oldY))/32.0;
//                [self _btnStartState];
            }else{
                btnAlpha =  (offsetY-(offsetYL + oldY) - 32.0)/32.0;
//                [self _btnSwitchState];
            }
        }else{
            alpha = 1.0;
            btnAlpha = 1.0;
//            [self _btnSwitchState];
        }
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//        self.loginButton.alpha = btnAlpha;
//        self.searchButton.alpha = btnAlpha;
//        self.postButton.alpha = btnAlpha;
//        self.navTitleLabel.alpha = alpha;
//        self.navView.alpha = alpha;
        
    }else{
        
        //        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
//        self.navView.alpha = 0;
//        [self _btnStartState];
//        self.loginButton.alpha = 1.0;
//        self.searchButton.alpha = 1.0;
//        self.postButton.alpha = 1.0;
//        self.navTitleLabel.alpha = 0;
        
    }
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.threadListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:BBSUIHomeTableIdentifier];
    
    if (!cell) {
        cell = [[BBSUIThreadSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BBSUIHomeTableIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if (_viewType == BBSUIThreadListViewTypePortal)
    {
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypePortal];
    }
    else
    {
        [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeHomepage];
    }
    
    __weak typeof(self)weakSelf = self;
    cell.addressOnClickBlock = ^(BBSThread *threadModel) {
        CLLocationCoordinate2D coordinate = {threadModel.latitude,threadModel.longitude};
        BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:threadModel.poiTitle];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
    
    return cell;
}

- (void)configureCell:(BBSUIThreadSummaryCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BBSThread *threadModel = self.threadListArray[indexPath.row];
    threadModel.select = YES;
    
    BBSUIThreadSummaryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.read = YES;
    
    if (_viewType == BBSUIThreadListViewTypePortal)
    {
        BBSUIPortalDetailViewController *detailVC = [[BBSUIPortalDetailViewController alloc] initWithThreadModel:threadModel];
        detailVC.allowcomment = @(self.allowcomment);
        [self.navigationController pushViewController:detailVC animated:YES];
    }else
    {
        BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:threadModel];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}


#pragma mark - iBBSUIFastPostViewControllerDelegate
- (void)didBeginPostThread
{
    [[BBSUIStatusBarTip shareStatusBar] postBegin];
}

- (void)alertPostingThread
{
    //    [SVProgressHUD showWithStatus:@"正在发帖..."];
    //    [SVProgressHUD dismissWithDelay:2];
}

- (void)didPostSuccess
{
    [[BBSUIStatusBarTip shareStatusBar] postSuccess];
}

- (void)didPostFailWithError:(NSError *)error
{
    [[BBSUIStatusBarTip shareStatusBar] postFailed:[error userInfo][@"description"]];
    
    if (error.code == 9001200) {
        [BBSUIContext shareInstance].currentUser = nil;
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
        
        UIImage *scaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/NoUser.png"] withSize:CGSizeMake(60, 60)];
        [((UIButton *)self.navigationItem.leftBarButtonItem.customView) setImage:scaleImage forState:UIControlStateNormal];
    }
}

#pragma mark - cycleview delegate  广告条
-(void)bannerClick:(NSInteger)index
{
    BBSBanner *banner = self.bannerArray[index];
    NSLog(@"link = %@, banner.title = %@, banner.picture = %@", banner.link, banner.title, banner.picture);
    NSLog(@"bannner.btype = %@", banner.btype);
    if ([banner.btype isEqualToString:@"link"]) {
        BBSUIBannerPreviewViewController *previewVC = [[BBSUIBannerPreviewViewController alloc] initWithTitle:banner.title];
        [previewVC setUrlString:banner.link];
        
        id controller;
        if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
        {
            controller = ((UITabBarController *)controller).selectedViewController;
        }
        else if ([MOBFViewController currentViewController].navigationController)
        {
            controller = [MOBFViewController currentViewController];
        }
        else
        {
            return;
        }
        
        [((UIViewController *)controller).navigationController pushViewController:previewVC animated:YES];
        
    }else if ([banner.btype isEqualToString:@"thread"])
    {
        BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithFid:banner.fid tid:banner.tid];
        
        id controller;
        if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
        {
            controller = ((UITabBarController *)controller).selectedViewController;
        }
        else if ([MOBFViewController currentViewController].navigationController)
        {
            controller = [MOBFViewController currentViewController];
        }
        else
        {
            return;
        }
        
        [((UIViewController *)controller).navigationController pushViewController:detailVC animated:YES];
    }
}

@end
