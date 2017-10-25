//
//  BBSUIHomeViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIHomeViewController.h"
#import "LBSegmentControl.h"
#import "BBSUIForumViewController.h"
#import "BBSUILoginViewController.h"
#import "BBSUISearchViewController.h"
#import "BBSUIContext.h"
#import <MOBFoundation/MOBFImageGetter.h>
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
#import "UIView+TipView.h"
#import "NSString+ThreadOrderType.h"
#import "BBSUIForumHeader.h"
#import "BBSUIThreadDetailViewController.h"
#import <BBSSDK/BBSForum.h>
#import "BBSUIForumThreadListViewController.h"
#import "BBSUIBannerPreviewViewController.h"
#import "BBSThread+BBSUI.h"
#import "UIButton+WebCache.h"

static NSString *BBSUIHomeTableIdentifier = @"BBSUIHomeTableIdentifier";
static NSInteger    BBSUIPageSize = 10;


@interface BBSUIHomeViewController ()<iBBSUIFastPostViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CycleViewDelegate>

@property (nonatomic, strong) UILabel           *titleLabel;

@property (nonatomic, strong) UITableView       *homeTableView;

@property (nonatomic, strong) NSArray           *bannerArray;

@property (nonatomic, assign) NSInteger         currentIndex;

@property (nonatomic, strong) NSMutableArray    *threadListArray;

@property (nonatomic, strong) BBSUIForumHeader  *forumHeader;

@property (nonatomic, strong) UIButton          *loginButton;

@property (nonatomic, strong) UIButton          *searchButton;

@property (nonatomic, strong) UIButton          *postButton;

@property (nonatomic, strong) UILabel           *navTitleLabel;

@property (nonatomic, strong) BBSUIBaseView     *navView;

@property (nonatomic, strong) UIImageView       *maskImage;

@property (nonatomic, strong) BBSUIThreadBanner *bannerView;

@property (nonatomic, assign) BOOL              stateStarted;//初始状态

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@property (nonatomic, assign) NSInteger         currentUserId;

@end

@implementation BBSUIHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self _setupRightBarButton];
    [self _configureUI];
    [self _initData];
//    [self _setCustomTitleView];
    [self _requestData];
    [self _createNavView];//自定义navview
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self _refreshUI];
    
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
    [self.navigationController.navigationBar lt_reset];
    
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}

- (void)dealloc
{
    
}

#pragma mark - private UI & UI handler
-(void)_configureUI
{
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, DZSUIScreen_width, DZSUIScreen_height + 20) style:UITableViewStylePlain];
    _homeTableView.delegate = self;
    _homeTableView.dataSource = self;
    _homeTableView.backgroundColor = [UIColor clearColor];
    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _homeTableView.fd_debugLogEnabled = YES;
    [_homeTableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:BBSUIHomeTableIdentifier];
    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _homeTableView.estimatedRowHeight = 135;
    _homeTableView.rowHeight = UITableViewAutomaticDimension;
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
    CGFloat forumViewHeight = 105;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 245 + forumViewHeight)];
    [headerView setBackgroundColor:[UIColor blackColor]];
    
    self.bannerView = [[BBSUIThreadBanner alloc]
                                 initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                          247)];
    [headerView addSubview:self.bannerView];
    __weak typeof(self) theView = self;
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
    
    return headerView;
}

- (void)setCustomNavTitleView
{
    //首页所有帖子列表视图
    
    
    
}

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

- (void)editThread:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        [editVC addPostThreadObserver:self];
        UINavigationController *mainStyleNav = [[UINavigationController alloc] initWithRootViewController:editVC];

        
        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)searchAction:(UIButton *)sender {
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)login:(id)sender
{

    if (![BBSUIContext shareInstance].currentUser)
    {
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        BBSUser *currentUser = [BBSUIContext shareInstance].currentUser;
        
        long time = [[NSDate date] timeIntervalSince1970];
        NSString *strTime = [NSString stringWithFormat:@"%lu",time];
        
        __weak typeof (self) weakSelf = self;
        [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
            
            if (!error) {
                currentUser.favorites  = user.favorites;
                currentUser.followers  = user.followers;
                currentUser.threads    = user.threads;
                currentUser.firends    = user.firends;
                currentUser.notices    = user.notices;
                
                [BBSUIContext shareInstance].currentUser = currentUser;

                BBSUIUserHomeViewController *vc = [[BBSUIUserHomeViewController alloc] initWithUser:[BBSUIContext shareInstance].currentUser];
                [weakSelf.navigationController pushViewController:vc animated:YES];
                
            }else{
                
                if (error.code == 9001200) {
                    
                    [BBSUIContext shareInstance].currentUser = nil;
                    
                    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
                    
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [weakSelf.navigationController presentViewController:nav animated:YES completion:nil];
                    //                    [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
                }
                
                return ;
            }
        }];
        
        
        
    }
}

//按钮初始状态
- (void)_btnStartState
{
    self.stateStarted = YES;
    
    if (![BBSUIContext shareInstance].currentUser) {
        [self.loginButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/noUserWhite.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    }
    
    [self.searchButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    [self.postButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
}

//按钮下拉切换图片状态
- (void)_btnSwitchState
{
    self.stateStarted = NO;
    
    if (![BBSUIContext shareInstance].currentUser) {
        [self.loginButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/noUserBlack.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    }
    
    [self.searchButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/searchBlack.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    [self.postButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/postThreadBlack.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
}

- (void)_createNavView
{
    self.navView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, NavigationBar_Height)];
    [self.view addSubview:self.navView];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:15];
//    [self.loginButton setImage:[UIImage BBSImageNamed:@"/Home/noUserWhite.png"] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setFrame:CGRectMake(7, 27, 30, 30)];
    [self.view addSubview:self.loginButton];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] forState:UIControlStateNormal];
    [self.postButton setFrame:CGRectMake(DZSUIScreen_width - 7 - 30, 27, 30, 30)];
    [self.postButton addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(BBS_LEFT(self.postButton) - 10 - 30, 27, 30, 30)];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchButton];
    
    self.navTitleLabel = [UILabel new];
    [self.navTitleLabel setFrame:CGRectMake(0, 20, DZSUIScreen_width, 44)];
    [self.navTitleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:16]];
    [self.navTitleLabel setTextColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0]];
    [self.navTitleLabel setText:@"首页"];
    [self.navTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navView addSubview:self.navTitleLabel];
}

- (void)_refreshUI
{
    if ([BBSUIContext shareInstance].currentUser) {
        
        
        if ([BBSUIContext shareInstance].currentUser.avatar) {
            MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
            [getter removeImageObserver:self.verifyImgObserver];
            [self.loginButton setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault3.png"] forState:UIControlStateNormal];
            NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", [BBSUIContext shareInstance].currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
            self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error){
                
                if (image) {
                    [self.loginButton setImage:image forState:UIControlStateNormal];
                    
                    UIImageView *img = [UIImageView new];
                    [img setImage:image];
                    [img setFrame:CGRectMake(0, 100, 100, 100)];
//                    [self.view addSubview:img];
                }
                
            }];

        }else{
            [self.loginButton setImage:[UIImage BBSImageNamed:@"/Home/AvatarDefault3.png"] forState:UIControlStateNormal];
        }
    }else{
        
        if (self.stateStarted) {
            [self.loginButton setImage:[UIImage BBSImageNamed:@"/Home/noUserWhite.png"] forState:UIControlStateNormal];
        }else{
            [self.loginButton setImage:[UIImage BBSImageNamed:@"/Home/noUserBlack.png"] forState:UIControlStateNormal];
        }
    }

}

#pragma mark - private data
- (void)_initData
{
    self.currentIndex = 1;
    self.currentUserId = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    self.stateStarted = YES;
}

- (void)_requestData
{
    [self _requestThreadList];
    [self _requestBannerList];
    [self _requestForumList];
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
                
                [theController.homeTableView configureTipViewWithFrame:tipFrame tipMessage:@"暂无内容" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    
                    [theController.homeTableView.mj_header beginRefreshing];
                    [theController _requestData];
                    
                }];
        
            }
        }
        else
        {
            NSLog(@"%@",error);
            CGRect tipFrame = (CGRect){0,350,DZSUIScreen_width,DZSUIScreen_height - 350};
            
            [theController.homeTableView configureTipViewWithFrame:tipFrame tipMessage:@"网络不佳，请再次刷新" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                
                [theController.homeTableView.mj_header beginRefreshing];
                [theController _requestData];
                
            }];
        }
        
        [theController.homeTableView.mj_header endRefreshing];
        [theController.homeTableView.mj_footer endRefreshing];
        
    }];
}

- (void)_requestBannerList
{
    __weak typeof(self) theHomeVC = self;
    [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
        
        if (bannnerList.count > 0) {
            
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
            
        }else{
            [theHomeVC.maskImage setImage:[UIImage BBSImageNamed:@"/Home/bannerDefault@2x.png"]];
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

- (void)setupLeftBarButton
{
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0, 0, 30, 30);
    
    [loginButton.layer setMasksToBounds:YES];
    [loginButton.layer setCornerRadius:15];
    if ([BBSUIContext shareInstance].currentUser) {
        
        
        if ([BBSUIContext shareInstance].currentUser.avatar) {
            NSString *avatarURLBig = [BBSUIContext shareInstance].currentUser.avatar;
            NSString *avatarURLSmall = [avatarURLBig stringByReplacingOccurrencesOfString:@"big" withString:@"small"];
            
            //        NSString *avatarURL = [avatarURLSmall stringByAppendingFormat:@"&timestamp=%f", [NSDate date].timeIntervalSince1970];
            //
            //        UIImage *scaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/NoUser.png"] withSize:CGSizeMake(60, 60)];
            //        [login setImage:scaleImage forState:UIControlStateNormal];
            //        login.contentMode = UIViewContentModeScaleAspectFill;
            //        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:avatarURL] result:^(UIImage *image, NSError *error) {
            //
            //            UIImage *avatarImage = nil;
            //            if (error) {
            //                avatarImage = [UIImage BBSImageNamed:@"/Home/NoUser.png"];
            //            }else{
            //                avatarImage = image;
            //            }
            //            UIImage *scaleImage = [MOBFImage scaleImage:avatarImage withSize:CGSizeMake(60, 60)];
            //            [login setImage:scaleImage forState:UIControlStateNormal];
            //
            //        }];
            
            [loginButton sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarURLSmall]
                                             forState:UIControlStateNormal
                                     placeholderImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/NoUser.png"] withSize:CGSizeMake(60, 60)]
                                              options:SDWebImageCacheMemoryOnly | SDWebImageRefreshCached];//不使用缓存
        }else{
            [loginButton setImage:[UIImage BBSImageNamed:@"/Home/AvatarDefault3.png"] forState:UIControlStateNormal];
        }
        
        
    }
    self.loginButton = loginButton;
    
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loginButton];
}

- (void)_setupRightBarButton
{
    UIButton *postThreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    postThreadButton.frame = CGRectMake(0, 0, 30, 30);
    UIImage *editScaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] withSize:CGSizeMake(60, 60)];
    [postThreadButton setImage:editScaleImage forState:UIControlStateNormal];
    [postThreadButton addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postThreadBarButton = [[UIBarButtonItem alloc] initWithCustomView:postThreadButton];
    
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 15;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 30);
    UIImage *searchScaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] withSize:CGSizeMake(60, 60)];
    [searchBtn setImage:searchScaleImage forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    self.navigationItem.rightBarButtonItems = @[postThreadBarButton, spaceItem, searchBarButton];
    
    self.searchButton = searchBtn;
    self.postButton = postThreadButton;
}

- (void)_setCustomTitleView
{
    _navTitleLabel = [UILabel new];
    [_navTitleLabel setFrame:CGRectMake(0, 0, 60, 44)];
    [_navTitleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:16]];
    [_navTitleLabel setTextColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0]];
    [_navTitleLabel setText:@"首页"];
    [_navTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navigationItem setTitleView:_navTitleLabel];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor * color = [UIColor whiteColor];
    CGFloat offsetY = scrollView.contentOffset.y;
//    CGFloat distance = offsetY + 64.0;
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
                [self _btnStartState];
            }else{
                btnAlpha =  (offsetY-(offsetYL + oldY) - 32.0)/32.0;
                [self _btnSwitchState];
            }
        }else{
            alpha = 1.0;
            btnAlpha = 1.0;
            [self _btnSwitchState];
        }
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
        self.loginButton.alpha = btnAlpha;
        self.searchButton.alpha = btnAlpha;
        self.postButton.alpha = btnAlpha;
        self.navTitleLabel.alpha = alpha;
        self.navView.alpha = alpha;
        
    }else{
        
//        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
        self.navView.alpha = 0;
        [self _btnStartState];
        self.loginButton.alpha = 1.0;
        self.searchButton.alpha = 1.0;
        self.postButton.alpha = 1.0;
        self.navTitleLabel.alpha = 0;
        
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

    [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeHomepage];
    
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
    
    BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:threadModel];
    [self.navigationController pushViewController:detailVC animated:YES];
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
        if ([MOBFViewController currentViewController].navigationController) {
            [[MOBFViewController currentViewController].navigationController pushViewController:previewVC animated:YES];
        }
    }else if ([banner.btype isEqualToString:@"thread"])
    {
        BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithFid:banner.fid tid:banner.tid];
        
        if ([MOBFViewController currentViewController].navigationController)
        {
            [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
        }
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

@end
