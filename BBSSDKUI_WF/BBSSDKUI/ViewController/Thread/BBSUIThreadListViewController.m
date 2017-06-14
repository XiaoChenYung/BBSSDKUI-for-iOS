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
#import "BBSUIFastPostViewController.h"
#import "UIImage+BBSFunction.h"
#import "Masonry.h"

@interface BBSUIThreadListViewController ()<iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) BBSUIThreadListView *threadListView;

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, assign) BBSUIThreadOrderType  currentOrderType;//0 回复时间 1：发帖时间

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, assign) BOOL isPresent;

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
    if (self.currentForum) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [super viewWillAppear:animated];
    self.isPresent = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.currentForum && !self.isPresent) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
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
        [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.view addSubview:back];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.view).with.offset(27);
            make.width.mas_equalTo(@44);
        }];
        back;
    });
    
    
    self.titleView = [[UIView alloc] init];
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(200, 44));
    }];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleView addSubview:titleButton];
    [titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView).with.offset(0);
        make.left.equalTo(self.titleView).with.offset(0);
        make.right.equalTo(self.titleView).with.offset(0);
        make.bottom.equalTo(self.titleView).with.offset(0);
    }];
    [titleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (self.currentForum) {
        [titleButton setTitle:self.currentForum.name forState:UIControlStateNormal];
    }else{
        [titleButton setTitle:@"所有" forState:UIControlStateNormal];
    }
    UIImage *arrowImage = [UIImage BBSImageNamed:@"Forum/DownArrow.png"];
    [titleButton setImage:arrowImage forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -arrowImage.size.width * 2, 0, 0)];
    CGSize titleSize = [titleButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleButton.titleLabel.font}];
    [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + arrowImage.size.width + 5, 0, -titleSize.width + arrowImage.size.width - 5)];
    [titleButton addTarget:self action:@selector(titleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];

    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self setupRightBarButton];
}

- (void)cancel:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)editThread:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        self.isPresent = YES;
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        [editVC addPostThreadObserver:self];
        
        [self.navigationController pushViewController:editVC animated:YES];
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
    PopoverAction *createdOnOrderAction = [PopoverAction actionWithSelectedImage:[UIImage BBSImageNamed:@"Forum/CommentSelected.png"] deselectedImage:[UIImage BBSImageNamed:@"Forum/CommentDeselected.png"] title:@"按回复时间排序" handler:^(PopoverAction *action) {

        theThreadListVC.currentOrderType = 0;
        [theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        
    }];
    // 加好友 action
    PopoverAction *lastPostOrderAction = [PopoverAction actionWithSelectedImage:[UIImage BBSImageNamed:@"Forum/TimeSelected.png"] deselectedImage:[UIImage BBSImageNamed:@"Forum/TimeDeselected.png"] title:@"按发帖时间排序" handler:^(PopoverAction *action) {
        
        theThreadListVC.currentOrderType = 1;
        [theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        
    }];

    return @[createdOnOrderAction, lastPostOrderAction];
}

#pragma mark - iBBSUIFastPostViewControllerDelegate

- (void)didBeginPostThread
{
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.frame = CGRectMake(0, 0, 30, 30);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertPostingThread)];
    [view addGestureRecognizer:tap];
    [view startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)alertPostingThread
{
    [SVProgressHUD showWithStatus:@"正在发帖..."];
    [SVProgressHUD dismissWithDelay:2];
}

- (void)didPostSuccess
{
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(0, 0, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"/Common/postSuccess.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postThread];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupRightBarButton];
    });
}

- (void)didPostFailWithError:(NSError *)error
{
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(0, 0, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"/Common/postFail.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postThread];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupRightBarButton];
    });
}

- (void)dealloc
{
    [[BBSUIFastPostViewController shareInstance] removePostThreadObserver:self];
}


@end
