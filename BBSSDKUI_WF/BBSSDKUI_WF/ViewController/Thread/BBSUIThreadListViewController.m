//
//  BBSUIThreadListViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListViewController.h"
#import "BBSUIThreadListView.h"
#import "BBSUIPopoverView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "BBSUIFastPostViewController.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUISearchViewController.h"
#import "Masonry.h"
#import "UIView+BBSUIExt.h"
#import "BBSUIStatusBarTip.h"

@interface BBSUIThreadListViewController ()<iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) BBSUIThreadListView *threadListView;

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, assign) BBSUIThreadOrderType  currentOrderType;//0 回复时间 1：发帖时间

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, assign) BOOL isPresent;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, assign) CGFloat iphoneXTopPadding;

@end

@implementation BBSUIThreadListViewController

- (instancetype)initWithForum:(BBSForum *)forum
{
    self = [super init];
    if (self) {
        self.currentForum = forum;
        self.currentOrderType = BBSUIThreadOrderCommentTime;
    }
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        _iphoneXTopPadding = 10;
    }
    
    //资讯和论坛公用的view
    _threadListView = [[BBSUIThreadListView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))
                                                           forum:self.currentForum
                                                        pageType:self.pageType];
    [self.view addSubview:_threadListView];
    //设置标题
    [self setNavigationBarTitle];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (self.currentForum) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    
    [super viewWillAppear:animated];
    self.isPresent = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.currentForum && !self.isPresent) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [self.threadListView dismissRefreshWindow];
    
    [super viewWillDisappear:animated];
}
#pragma mark - UI
#pragma mark -导航头
- (void)setNavigationBarTitle
{
    if (!self.currentForum) {
        self.title = @"所有";
        return;
    }
    
    self.backButton =
    ({
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:back];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(0);
            make.top.equalTo(self.view).with.offset(30 + _iphoneXTopPadding);
            make.width.mas_equalTo(@50);
        }];
        back;
    });
    
    
    self.titleView = [[UIView alloc] init];
    [self.view addSubview:self.titleView];
    [self.titleView setFrame:CGRectMake(50, 20 + _iphoneXTopPadding, BBS_WIDTH(self.view) - 100, 44)];
    
    UILabel *titleLabel = [UILabel new];
    [self.titleView addSubview:titleLabel];
    if (self.currentForum) {
        [titleLabel setText:self.currentForum.name];
    }else{
        [titleLabel setText:@"所有"];
    }
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    CGSize buttonSize = [titleLabel.text boundingRectWithSize:size
                                              options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:@{ NSFontAttributeName:titleLabel.font}
                                              context:nil].size;
    [titleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2, buttonSize.width, buttonSize.height)];
    [titleLabel setTextColor:[UIColor blackColor]];
    
//    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BBS_RIGHT(titleLabel) + 5, (BBS_HEIGHT(self.titleView) - 14) / 2, 14, 14)];
//    [_arrowImageView setContentMode:UIViewContentModeScaleAspectFit];
//    [_arrowImageView setImage:arrowImage];
//    [self.titleView addSubview:_arrowImageView];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    titleTap.numberOfTouchesRequired = 1;
//    [self.titleView addGestureRecognizer:titleTap];
//    [self setupRightBarButton];
    [self setupRightBarButton];
}

#pragma mark - Action
- (void)titleViewTappedHandler:(UITapGestureRecognizer *)tap
{    
    [_arrowImageView setImage:[_arrowImageView.image BBSImageRotation:UIImageOrientationDown]];

    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.threadListView.currentSelectType;
    orderPopoverView.orderIndex = self.threadListView.currentOrderType;
    [orderPopoverView showToView:self.titleView withActions:[self orderTypeActions] button:_arrowImageView];
    
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (void)cancel:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchAction:(UIButton *)sender
{
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)setupRightBarButton
{
    CGFloat postThreadButtonWidth = 30;
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(DZSUIScreen_width - postThreadButtonWidth - 10, 25 + _iphoneXTopPadding, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"Home/postThreadBlack.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postThread];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(DZSUIScreen_width - postThreadButtonWidth*2 - 20, 25, 30, 30);
    UIImage *searchScaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/SearchIcon.png"] withSize:CGSizeMake(20, 20)];
    [searchBtn setImage:searchScaleImage forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark -发帖
- (void)editThread:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        self.isPresent = YES;
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
//        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
//        [editVC addPostThreadObserver:self];
//        [self.navigationController pushViewController:editVC animated:YES];
        self.isPresent = YES;
        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        [editVC setForum:_currentForum];
        editVC.isEnterVc = YES;
        [editVC addPostThreadObserver:self];
        BBSUIMainStyleNavigationController *mainStyleNav = [[BBSUIMainStyleNavigationController alloc] initWithRootViewController:editVC];
        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)titleButtonHandler:(UIButton *)button
{
    UIImage *img = [button.currentImage BBSImageRotation:UIImageOrientationDown];
    [button setImage:img forState:UIControlStateNormal];
    
    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.threadListView.currentSelectType;
    orderPopoverView.orderIndex = self.threadListView.currentOrderType;
    [orderPopoverView showToView:button withActions:[self orderTypeActions] button:button];
}

- (NSArray<BBSUIPopoverAction *> *)orderTypeActions {
    
    __weak typeof(self) theThreadListVC = self;
    BBSUIPopoverAction *createdOnOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按回复时间排序" handler:^(BBSUIPopoverAction *action) {

        theThreadListVC.currentOrderType = 0;
        [theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        
    }];
    // 加好友 action
    BBSUIPopoverAction *lastPostOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按发帖时间排序" handler:^(BBSUIPopoverAction *action) {
        
        theThreadListVC.currentOrderType = 1;
        [theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        
    }];

    return @[createdOnOrderAction, lastPostOrderAction];
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
    }
}


- (void)dealloc
{
    [[BBSUIFastPostViewController shareInstance] removePostThreadObserver:self];
}


@end
