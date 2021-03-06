//
//  BBSUIThreadListViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListViewController.h"
#import "BBSUIThreadListView.h"
#import "PopoverView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUISearchViewController.h"
#import "Masonry.h"
#import "UIViewExt.h"
#import "BBSUIStatusBarTip.h"
#import "BBSUIFastPostViewController.h"

@interface BBSUIThreadListViewController ()<iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) BBSUIThreadListView *threadListView;

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, assign) BBSUIThreadOrderType  currentOrderType;//0 回复时间 1：发帖时间

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, assign) BOOL isPresent;

@property (nonatomic, strong) UIImageView *arrowImageView;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //帖子列表视图
    _threadListView = [[BBSUIThreadListView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) forum:self.currentForum];
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
            make.top.equalTo(self.view).with.offset(27);
            make.width.mas_equalTo(@50);
        }];
        back;
    });
    
    
    self.titleView = [[UIView alloc] init];
    [self.view addSubview:self.titleView];
//    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.top.equalTo(self.view).with.offset(20);
//        make.size.mas_equalTo(CGSizeMake(200, 44));
//    }];
    [self.titleView setFrame:CGRectMake(50, 20, BBS_WIDTH(self.view) - 100, 44)];
    
    UILabel *titleLabel = [UILabel new];
    [self.titleView addSubview:titleLabel];
//    [titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.titleView).with.offset(0);
//        make.left.equalTo(self.titleView).with.offset(0);
//        make.right.equalTo(self.titleView).with.offset(0);
//        make.bottom.equalTo(self.titleView).with.offset(0);
//    }];
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
    
    UIImage *arrowImage = [UIImage BBSImageNamed:@"Forum/DownArrow.png"];
//    [titleButton setImage:arrowImage forState:UIControlStateNormal];
//    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -arrowImage.size.width * 2, 0, 0)];
//    CGSize titleSize = [titleButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleButton.titleLabel.font}];
//    [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + arrowImage.size.width + 5, 0, -titleSize.width + arrowImage.size.width - 5)];
//    [titleButton addTarget:self action:@selector(titleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BBS_RIGHT(titleLabel) + 5, (BBS_HEIGHT(self.titleView) - 14) / 2, 14, 14)];
    [_arrowImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_arrowImageView setImage:arrowImage];
    [self.titleView addSubview:_arrowImageView];

    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTappedHandler:)];
    titleTap.numberOfTouchesRequired = 1;
    [self.titleView addGestureRecognizer:titleTap];
    
    [self setupRightBarButton];
}

- (void)titleViewTappedHandler:(UITapGestureRecognizer *)tap
{
//    UIImage *img = [button.currentImage BBSImageRotation:UIImageOrientationDown];
//    [button setImage:img forState:UIControlStateNormal];
    
    [_arrowImageView setImage:[_arrowImageView.image BBSImageRotation:UIImageOrientationDown]];
    
    PopoverView *orderPopoverView = [PopoverView popoverView];
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

- (void)searchAction:(UIButton *)sender {
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)setupRightBarButton
{
    CGFloat postThreadButtonWidth = 30;
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(DZSUIScreen_width - postThreadButtonWidth - 10, 25, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"Home/postThreadBlack.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postThread];
    [self.view addSubview:postThread];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(DZSUIScreen_width - postThreadButtonWidth*2 - 20, 25, 30, 30);
    UIImage *searchScaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/SearchIcon.png"] withSize:CGSizeMake(20, 20)];
    [searchBtn setImage:searchScaleImage forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.view addSubview:searchBtn];
}

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
//        
//        [self.navigationController pushViewController:editVC animated:YES];
        self.isPresent = YES;
//        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
//        [editVC setForum:_currentForum];
//        [editVC addPostThreadObserver:self];
//        BBSUIMainStyleNavigationController *mainStyleNav = [[BBSUIMainStyleNavigationController alloc] initWithRootViewController:editVC];
//        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)titleButtonHandler:(UIButton *)button
{
    UIImage *img = [button.currentImage BBSImageRotation:UIImageOrientationDown];
    [button setImage:img forState:UIControlStateNormal];
    
    PopoverView *orderPopoverView = [PopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.threadListView.currentSelectType;
    orderPopoverView.orderIndex = self.threadListView.currentOrderType;
    [orderPopoverView showToView:button withActions:[self orderTypeActions] button:button];
}

- (NSArray<PopoverAction *> *)orderTypeActions {
    
    __weak typeof(self) theThreadListVC = self;
    PopoverAction *createdOnOrderAction = [PopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按回复时间排序" handler:^(PopoverAction *action) {

        theThreadListVC.currentOrderType = 0;
        [theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        
    }];
    // 加好友 action
    PopoverAction *lastPostOrderAction = [PopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按发帖时间排序" handler:^(PopoverAction *action) {
        
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


#pragma mark - life cycle
- (void)dealloc
{
    [[BBSUIFastPostViewController shareInstance] removePostThreadObserver:self];
}


@end
