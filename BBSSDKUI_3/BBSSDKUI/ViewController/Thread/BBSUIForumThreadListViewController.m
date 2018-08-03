//
//  BBSUIForumThreadListViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumThreadListViewController.h"
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCellDebug.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BBSUIThreadSummaryCell.h"
#import "UINavigationBar+Awesome.h"
#import <BBSSDK/BBSForum.h>
#import <BBSSDK/BBSSDK.h>
#import "NSString+ThreadOrderType.h"
#import "UIView+BBSUITipView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIOrderSegmentView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "BBSUIFastPostViewController.h"
#import "BBSUISearchViewController.h"
#import "BBSUIStatusBarTip.h"
#import "BBSUIPopoverView.h"
#import "BBSThread+BBSUI.h"
#import "BBSUIThreadDetailViewController.h"
#import "NSString+BBSUIParagraph.h"
#import "BBSUILBSShowLocationViewController.h"
#import "BBSUITribuneSegementView.h"

static NSString *BBSUIForumThreadIdentifier = @"BBSUIForumThreadIdentifier";

#define BBSUIPageSize 10
#define BBSUISectionHeader 40

#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 55)
#define kTabbar_SafeArea ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)

@interface BBSUIForumThreadListViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, BBSUIOrderSegmentDelegate, iBBSUIFastPostViewControllerDelegate, iBBSUISegmentViewDelegate>

@property (nonatomic, strong) UITableView           *forumThreadListTableView;

@property (nonatomic, assign) NSInteger             currentIndex;

@property (nonatomic, strong) NSMutableArray        *threadListArray;

@property (nonatomic, strong) BBSForum              *currentForum;

@property (nonatomic, assign) BBSUIThreadSelectType selectType;

@property (nonatomic, assign) BBSUIThreadOrderType  orderType;

@property (nonatomic, strong) UIButton              *backButton;

@property (nonatomic, strong) UIButton              *searchButton;

@property (nonatomic, strong) UIButton              *postButton;

@property (nonatomic, strong) UIView                *forumContentView;//版块摘要容器
@property (nonatomic, strong) UIButton              *forumNameButton;
@property (nonatomic, strong) UIButton              *forumArrowButton;
@property (nonatomic, strong) UILabel               *forumDesLabel;
@property (nonatomic, strong) UIImageView           *forumPicImageView;

@property (nonatomic, strong) UIView                *sectionHeaderView;

@property (nonatomic, strong) UIView                *titleView;
@property (nonatomic, strong) UILabel               *navTitleLabel;
@property (nonatomic, strong) UIImageView           *arrowImageView;

@property (nonatomic, strong) BBSUIBaseView         *navView;
@property (nonatomic, strong) BBSUITribuneSegementView *segemntView ;
@property (nonatomic, strong) BBSUITribuneSegementView *hoverView;//悬浮的segement


@end

@implementation BBSUIForumThreadListViewController

- (instancetype)initWithForum:(BBSForum *)forum
{
    self = [super init];
    if (self) {
        self.currentForum = forum;
    }
    
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupRightBarButton];
    [self _setupLeftBarButton];
    [self _configureUI];
    [self _initData];
    [self _requestData];
    [self _addSuspensionSegementView];
    [self _createNavView];//自定义navview
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    if (self.forumThreadListTableView) {
        self.forumThreadListTableView.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.forumThreadListTableView.delegate = nil;
    [self.navigationController.navigationBar lt_reset];
}

#pragma mark - initUI
#pragma mark - 悬停view
- (void)_addSuspensionSegementView
{
    //添加最新 热门 精华
    self.hoverView = [[BBSUITribuneSegementView alloc] initWithFrame:CGRectMake(0, NavigationBar_Height + 15, DZSUIScreen_width, 42)];
    [self.view addSubview:self.hoverView];
    [self.view insertSubview:self.hoverView aboveSubview:self.forumThreadListTableView];
    self.hoverView.backgroundColor = DZSUIColorFromHex(0xffffff);
    self.hoverView.delegate = self;
    self.hoverView.hidden = YES;
}

- (void)_configureUI
{
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        _forumThreadListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -15, DZSUIScreen_width, DZSUIScreen_height + 50) style:UITableViewStylePlain];
    }
    else
    {
        _forumThreadListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, DZSUIScreen_width, DZSUIScreen_height + 20) style:UITableViewStylePlain];
    }
    
    _forumThreadListTableView.delegate = self;
    _forumThreadListTableView.dataSource = self;
    _forumThreadListTableView.backgroundColor = [UIColor clearColor];
    _forumThreadListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _forumThreadListTableView.fd_debugLogEnabled = YES;
    [_forumThreadListTableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:BBSUIForumThreadIdentifier];
    _forumThreadListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _forumThreadListTableView.estimatedRowHeight = 135;
    _forumThreadListTableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:_forumThreadListTableView];
    
    __weak typeof(self) theController = self;
    _forumThreadListTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        theController.currentIndex = 1;
        [theController _requestData];
    }];
    
    _forumThreadListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        theController.currentIndex++;
        [theController _requestData];
    }];
    
    //设置tableheader
    _forumThreadListTableView.tableHeaderView = [self _obtainHeaderView];
}

#pragma mark -头部
- (UIView *)_obtainHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -BBSStatusBar_Height, DZSUIScreen_width, 195)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -BBSStatusBar_Height, BBS_WIDTH(headerView), 195+BBSStatusBar_Height)];
    [headerView addSubview:backgroundImageView];
    
    NSString *picURL = self.currentForum.forumBigPic;
    if (!picURL)
    {
        picURL = self.currentForum.forumPic;
    }
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                 forHTTPHeaderField:@"Accept"];
    
    [backgroundImageView sd_setImageWithURL:[NSURL URLWithString:picURL] placeholderImage:[UIImage BBSImageNamed:@"/Thread/Group.png"]];
    
    _forumContentView = [[UIView alloc] initWithFrame:CGRectMake(DZSUIScreen_width, 117, DZSUIScreen_width, 43)];
    [headerView addSubview:_forumContentView];
    
    
    CGFloat leftMargin = 20;
    CGFloat forumButtonHeight = 24;
    CGFloat forumDesRightMargin = 80;
    CGFloat forumDesLabelHeight = 12;
    _forumNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forumNameButton setFrame:CGRectMake(0, 0, DZSUIScreen_width - leftMargin, forumButtonHeight)];
    [_forumNameButton setTitle:self.currentForum.name forState:UIControlStateNormal];
    _forumNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_forumNameButton.titleLabel setFont:[UIFont fontWithName:@".PingFangSC-Medium" size:24]];
    [_forumContentView addSubview:_forumNameButton];
    
    CGSize size = CGSizeMake(MAXFLOAT, forumButtonHeight);
    CGSize buttonSize = [self.currentForum.name boundingRectWithSize:size
                                                              options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                           attributes:@{ NSFontAttributeName:_forumNameButton.titleLabel.font}
                                                              context:nil].size;
    _forumArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forumArrowButton setFrame:CGRectMake(buttonSize.width,
                                           _forumNameButton.frame.origin.y + _forumNameButton.frame.size.height / 2 - 10,
                                           20,
                                           20)];
    [_forumArrowButton setImage:[UIImage BBSImageNamed:@"/Forum/ForumArrowDown.png"] forState:UIControlStateNormal];
    [_forumArrowButton addTarget:self
                          action:@selector(_forumArrowButtonHandler:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.forumContentView addSubview:_forumArrowButton];
    _forumArrowButton.hidden = YES;
    
    _forumDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               BBS_BOTTOM(_forumNameButton) + 7, 
                                                               DZSUIScreen_width - leftMargin - forumDesRightMargin,
                                                               forumDesLabelHeight + 1)];
    
    NSString *des = (self.currentForum.forumDescription && self.currentForum.forumDescription.length > 0) ? self.currentForum.forumDescription : @"该版主很懒，什么也没说";
//    [_forumDesLabel setAttributedText:[NSString stringWithString:des fontSize:12 defaultColorValue:@"ffffff" lineSpace:0 wordSpace:0]];
    _forumDesLabel.text = des;
    [_forumDesLabel setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:12]];
    [_forumDesLabel setTextColor:[UIColor whiteColor]];
    [_forumContentView addSubview:_forumDesLabel];
    
    CGFloat forumPicWidth = 50;
    _forumPicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DZSUIScreen_width - leftMargin * 2 - forumPicWidth,
                                                                       BBS_TOP(_forumNameButton),
                                                                       forumPicWidth,
                                                                       forumPicWidth)];
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                 forHTTPHeaderField:@"Accept"];
    [_forumPicImageView sd_setImageWithURL:[NSURL URLWithString:self.currentForum.forumPic]
                          placeholderImage:[UIImage BBSImageNamed:@"/Forum/forumList3.png"]];
    [_forumPicImageView.layer setCornerRadius:forumPicWidth / 2];
    [_forumPicImageView.layer setMasksToBounds:YES];
    [_forumContentView addSubview:_forumPicImageView];
    
    __weak typeof(self) theController = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect originFrame = theController.forumContentView.frame;
        originFrame.origin.x = 20;
        theController.forumContentView.frame = originFrame;
    } completion:^(BOOL finished) {
        
    }];
    
    headerView.backgroundColor = [UIColor orangeColor];
    
    
    return headerView;
}

#pragma mark - 数据加载
- (void)_requestData
{
    __weak typeof(self) theController = self;
    [BBSSDK getThreadListWithFid:self.currentForum.fid orderType:[NSString orderTypeStringFromOrderType:self.orderType] selectType:[NSString selectTypeStringFromSelectType:self.selectType] pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray *threadList, NSError *error) {
        
        if (!error) {
            if (theController.currentIndex == 1) {
                theController.threadListArray = [NSMutableArray arrayWithArray:threadList];
            }else {
                [theController.threadListArray addObjectsFromArray:threadList];
            }
            
            [theController.forumThreadListTableView reloadData];
            [theController.forumThreadListTableView.mj_footer setHidden:NO];
            
            if (threadList.count < BBSUIPageSize) {
                [theController.forumThreadListTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (theController.currentIndex == 1) {
                
                CGRect tipFrame = (CGRect){0,
                    NavigationBar_Height + _forumThreadListTableView.tableHeaderView.frame.size.height + BBSUISectionHeader,
                    DZSUIScreen_width,
                    DZSUIScreen_height - (NavigationBar_Height + _forumThreadListTableView.tableHeaderView.frame.size.height + BBSUISectionHeader)};
                [theController.forumThreadListTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"暂无内容" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                    
                    [theController.forumThreadListTableView.mj_header beginRefreshing];
                    [theController _requestData];
                    
                }];
            }
        }
        else
        {
            NSLog(@"%@",error);
            CGRect tipFrame = (CGRect){0,
                NavigationBar_Height + _forumThreadListTableView.tableHeaderView.frame.size.height + BBSUISectionHeader,
                DZSUIScreen_width,
                DZSUIScreen_height - (NavigationBar_Height + _forumThreadListTableView.tableHeaderView.frame.size.height + BBSUISectionHeader)};
            
            [theController.forumThreadListTableView bbs_configureTipViewWithFrame:tipFrame tipMessage:@"网络不佳，请再次刷新" noDataImage:nil hasData:theController.threadListArray.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
                
                [theController.forumThreadListTableView.mj_header beginRefreshing];
                [theController _requestData];
                
            }];
        }
        
        [theController.forumThreadListTableView.mj_header endRefreshing];
        [theController.forumThreadListTableView.mj_footer endRefreshing];
        
    }];
}

- (void)_initData
{
    self.currentIndex = 1;
    self.selectType = BBSUIThreadSelectTypeLatest;
    self.orderType = BBSUIThreadOrderPostTime;
}


#pragma mark - 设置Bar
- (void)_setupLeftBarButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    
    [backButton.layer setMasksToBounds:YES];
    [backButton.layer setCornerRadius:15];
    UIImage *scaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/backWhite.png"] withSize:CGSizeMake(60, 60)];
    [backButton setImage:scaleImage forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.backButton = backButton;
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
    self.titleView = [[UIView alloc] init];
    [self.titleView setFrame:CGRectMake(50, 20, BBS_WIDTH(self.view) - 100, 44)];
    
    self.navTitleLabel = [UILabel new];
    [self.titleView addSubview:self.navTitleLabel];
    if (self.currentForum) {
        [self.navTitleLabel setText:self.currentForum.name];
    }else{
        [self.navTitleLabel setText:@"所有"];
    }
    [self.navTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    CGSize buttonSize = [self.navTitleLabel.text boundingRectWithSize:size
                                                      options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{ NSFontAttributeName:self.navTitleLabel.font}
                                                      context:nil].size;
    [self.navTitleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2, buttonSize.width, buttonSize.height)];
    [self.navTitleLabel setTextColor:[UIColor blackColor]];
    
    CGFloat arrowImageWidth = 30;
    UIImage *arrowImage = [UIImage BBSImageNamed:@"Forum/ArrowDown.png"];
    self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BBS_RIGHT(self.navTitleLabel),
                                                                        (BBS_HEIGHT(self.titleView) - arrowImageWidth) / 2, 
                                                                        arrowImageWidth,
                                                                        arrowImageWidth)];
    [self.arrowImageView setContentMode:UIViewContentModeScaleToFill];
    [self.arrowImageView setImage:arrowImage];
    [self.titleView addSubview:self.arrowImageView];
    
    UITapGestureRecognizer *titleViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_titleViewTapHandler:)];
    titleViewTap.numberOfTouchesRequired = 1;
    [self.titleView addGestureRecognizer:titleViewTap];
    
    [self.navigationItem setTitleView:self.titleView];
}

#pragma mark -顶部View
- (void)_createNavView
{
    CGFloat iphoneXTopPadding = 0;
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        iphoneXTopPadding = 10;
    }
    
    CGFloat controlY = 27 + iphoneXTopPadding;
    CGFloat topHeight = 15;
    self.navView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, -topHeight, DZSUIScreen_width, NavigationBar_Height + 30)];
    
    [self.view addSubview:self.navView];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(7, controlY, 30, 30)];
    [self.backButton setImage:[UIImage BBSImageNamed:@"/Common/backWhite.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];

    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] forState:UIControlStateNormal];
    [self.postButton setFrame:CGRectMake(DZSUIScreen_width - 7 - 30, controlY, 30, 30)];
    [self.postButton addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(BBS_LEFT(self.postButton) - 10 - 30, controlY, 30, 30)];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchButton];

    self.titleView = [[UIView alloc] init];
    [self.titleView setFrame:CGRectMake(50, 20, BBS_WIDTH(self.view) - 100, 44)];
    
    self.navTitleLabel = [UILabel new];
    [self.titleView addSubview:self.navTitleLabel];
    if (self.currentForum) {
        [self.navTitleLabel setText:self.currentForum.name];
    }else{
        [self.navTitleLabel setText:@"所有"];
    }
    [self.navTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    CGSize buttonSize = [self.navTitleLabel.text boundingRectWithSize:size
                                                              options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                           attributes:@{ NSFontAttributeName:self.navTitleLabel.font}
                                                              context:nil].size;
     if ([BBSUIContext shareInstance].isIphoneX)
     {
          [self.navTitleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2 + 30, buttonSize.width, buttonSize.height)];
     }
     else
     {
         [self.navTitleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2+15, buttonSize.width, buttonSize.height)];
     }
    [self.navTitleLabel setTextColor:[UIColor blackColor]];
    
    CGFloat arrowImageWidth = 30;
    UIImage *arrowImage = [UIImage BBSImageNamed:@"Forum/ArrowDown.png"];
    self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BBS_RIGHT(self.navTitleLabel),
                                                                        (BBS_HEIGHT(self.titleView) - arrowImageWidth) / 2,
                                                                        arrowImageWidth,
                                                                        arrowImageWidth)];
    [self.arrowImageView setContentMode:UIViewContentModeScaleToFill];
    [self.arrowImageView setImage:arrowImage];
    [self.titleView addSubview:self.arrowImageView];
    self.arrowImageView.hidden = YES;
    
    [self.navView addSubview:self.titleView];
    
}

#pragma mark - Action事件
- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)_forumArrowButtonHandler:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [button setImage:[button.imageView.image BBSImageRotation:UIImageOrientationDown] forState:UIControlStateNormal];
    }];
    
    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.selectType;
    orderPopoverView.orderIndex = self.orderType;
    [orderPopoverView showToView:button withActions:[self orderTypeActions] button:button];
}

#pragma mark -发帖时间排序弹框
- (void)_titleViewTapHandler:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.3 animations:^{
        [_arrowImageView setImage:[_arrowImageView.image BBSImageRotation:UIImageOrientationDown]];
    }];
    
    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.selectType;
    orderPopoverView.orderIndex = self.orderType;
    [orderPopoverView showToView:self.navTitleLabel withActions:[self orderTypeActions] button:_arrowImageView];
}

- (NSArray<BBSUIPopoverAction *> *)orderTypeActions {
    
    __weak typeof(self) theController = self;
    BBSUIPopoverAction *createdOnOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按回复时间排序" selectedTitleColor:[UIColor colorWithRed:255/255.0 green:170/255.0 blue:66/255.0 alpha:1/1.0] handler:^(BBSUIPopoverAction *action) {
        
        theController.orderType = 0;
        [theController _requestData];
        
    }];
    // 加好友 action
    BBSUIPopoverAction *lastPostOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按发帖时间排序" selectedTitleColor:[UIColor colorWithRed:255/255.0 green:170/255.0 blue:66/255.0 alpha:1/1.0] handler:^(BBSUIPopoverAction *action) {
        
        theController.orderType = 1;
        [theController _requestData];
        
    }];
    
    return @[createdOnOrderAction, lastPostOrderAction];
}

//按钮初始状态
- (void)_btnStartState{
    
    [self.backButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/backWhite.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
    [self.searchButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    [self.postButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
}

//按钮下拉切换图片状态
- (void)_btnSwitchState{
    
    [self.backButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/backBlack@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
    [self.searchButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/searchBlack.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    [self.postButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/postThreadBlack.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
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
        editVC.forum = self.currentForum;
        
        [editVC addPostThreadObserver:self];
        UINavigationController *mainStyleNav = [[UINavigationController alloc] initWithRootViewController:editVC];
        
        
        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)searchAction:(UIButton *)button
{
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark -最新热门精华置顶
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.sectionHeaderView) {
        self.sectionHeaderView = [[UIView alloc] init];
        self.sectionHeaderView.frame = CGRectMake(0, 195, DZSUIScreen_width, 40);
        
        //添加最新 热门 精华
        BBSUITribuneSegementView *segemntView = [[BBSUITribuneSegementView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 42)];
        self.segemntView = segemntView;
        [self.sectionHeaderView addSubview:segemntView];
        segemntView.delegate = self;
        
    }
    
    return self.sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.threadListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:BBSUIForumThreadIdentifier];
    
    if (!cell) {
        cell = [[BBSUIThreadSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BBSUIForumThreadIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    [cell setThreadModel:self.threadListArray[indexPath.row] cellType:BBSUIThreadSummaryCellTypeForums];
    
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
    
    BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:threadModel];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor * color = [UIColor whiteColor];
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat distance = offsetY + 64.0;
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
        
        self.backButton.alpha = btnAlpha;
        self.searchButton.alpha = btnAlpha;
        self.postButton.alpha = btnAlpha;
        
        self.titleView.alpha = alpha;
        self.navTitleLabel.alpha = alpha;
        self.arrowImageView.alpha = alpha;
        self.navView.alpha = alpha;
        
    }else{

        self.navView.alpha = 0;
        [self _btnStartState];
        
        self.backButton.alpha = 1.0;
        self.searchButton.alpha = 1.0;
        self.postButton.alpha = 1.0;
        
        self.titleView.alpha = 0;
        self.navTitleLabel.alpha = 0;
        self.arrowImageView.alpha = 0;
    }
    if (scrollView.contentOffset.y > 95)
    {
        self.hoverView.hidden = NO;
    }
    else
    {
        self.hoverView.hidden = YES;
    }
    
    NSLog(@"----yyy-----%f",scrollView.contentOffset.y );
    
}

#pragma mark - BBSUITribuneSegementView Delegate
//最新 最热
- (void)selectSegementType:(NSInteger)index
{
    if (index == BBSUISegmentViewMenuTypeNew)
    {
        self.selectType = BBSUIThreadSelectTypeLatest;
    }
    else if (index == BBSUISegmentViewMenuTypeHot)
    {
        self.selectType = BBSUIThreadSelectTypeHeats;
    }
    else if (index == BBSUISegmentViewMenuTypeCream)
    {
        self.selectType = BBSUIThreadSelectTypeDigest;
    }
    else if (index == BBSUISegmentViewMenuTypeTop)
    {
        self.selectType = BBSUIThreadSelectTypeDisplayOrder;
    }
    
     self.currentIndex = 1;
     [self _requestData];
     [self _setHoverSelectType:index];
}

#pragma mark -设置悬浮框
- (void)_setHoverSelectType:(NSInteger)index
{
    [self.hoverView.buttonsArr enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (index == obj.tag - 20) {
            [self.hoverView hoverViewClick:obj];
        }
    }];
    
    [self.segemntView.buttonsArr enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index == obj.tag - 20) {
            [self.segemntView hoverViewClick:obj];
        }
    }];
}

//时间排序
- (void)selectSortByType:(NSInteger)sortIndex
{
//    if (sortIndex == BBSUISegmentViewMenuSendSort)
//    {//发帖时间排序
//        self.orderType = BBSUIThreadOrderCommentTime;
//    }
//    else if (sortIndex == BBSUISegmentViewMenuReplySort)
//    {//回复时间排序
//        self.orderType = BBSUIThreadOrderPostTime;
//    }
    
    if (sortIndex == BBSUISegmentViewMenuSendSort)
    {//发帖时间排序
        //self.orderType = BBSUIThreadOrderCommentTime;
        self.orderType = BBSUIThreadOrderPostTime;
    }
    else if (sortIndex == BBSUISegmentViewMenuReplySort)
    {//回复时间排序
        //self.orderType = BBSUIThreadOrderPostTime;
        
         self.orderType = BBSUIThreadOrderCommentTime;
    }
    
    self.currentIndex = 1;
     [self _requestData];
}


#pragma mark - iBBSUIFastPostViewControllerDelegate
- (void)didBeginPostThread
{
    [[BBSUIStatusBarTip shareStatusBar] postBegin];
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

- (void)dealloc
{
    self.forumThreadListTableView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
