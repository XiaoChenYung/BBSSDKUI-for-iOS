//
//  BBSUIHomeViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIHomeViewController.h"
#import "BBSUILBSegmentControl.h"
#import "BBSUIThreadListViewController.h"
#import "BBSUIBaseView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "BBSUIUserHomeViewController.h"
#import "BBSUIFastPostViewController.h"
#import "BBSUISearchViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "UINavigationBar+Awesome.h"
#import "BBSUIPortalViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUILaunchConfig.h"
#import "BBSUIStatusBarTip.h"
#import "BBSUIAlertView.h"

static NSString *BBSUIHomeTableIdentifier = @"BBSUIHomeTableIdentifier";
static NSInteger    BBSUIPageSize = 10;


@interface BBSUIHomeViewController ()<BBSUILBSegmentControlDelegate,iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) BBSUILBSegmentControl * segmentControl;
@property (nonatomic, strong) BBSUIBaseView     *navView;
@property (nonatomic, strong) UIButton          *loginButton;
@property (nonatomic, strong) UIButton          *postButton;
@property (nonatomic, strong) UIButton          *searchButton;
@property (nonatomic, strong) UILabel           *navTitleLabel;
@property (nonatomic, assign) BOOL              stateStarted;//初始状态
/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;
@property (nonatomic, strong) NSArray *segments;

@property (nonatomic, assign) CGFloat lastTableViewOffsetY;

// 加锁操作
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;

@property (nonatomic, assign) CGFloat iphoneXTopPadding;

@end

@implementation BBSUIHomeViewController

- (instancetype)init
{
    if (self = [super init])
    {
        [self _launchConfig];
    }
    
    return self;
}

/**
 开屏策略
 */
- (void)_launchConfig
{
    self.semaphore = dispatch_semaphore_create(0);
    self.queue = dispatch_queue_create("HomeViewControllerQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(_queue, ^{
        //阻塞线程，直到获取配置信息完成之后
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
    });
    
    [BBSSDK getGlobalSettings:^(NSDictionary *settings, NSError *error) {
        if (!error && settings)
        {
            NSString *currentAppkey = settings[@"target"][@"appkey"];
            NSDictionary *lastSettings = [BBSUIContext shareInstance].settings;
            
            [BBSUIContext shareInstance].settings = settings;
            
            if ((!lastSettings || !lastSettings[@"target"]) && currentAppkey)
            {
                /**
                 进行key更新处理
                 */
                [self _updateKey];
            }
            
            else if (lastSettings && lastSettings[@"target"])
            {
                NSDictionary *lastTarget = lastSettings[@"target"];
                NSString *lastAppkey = lastTarget[@"appkey"];
                
                if (![lastAppkey isEqualToString:currentAppkey])
                {
                    /**
                     进行key更新处理
                     */
                    [self _updateKey];
                }
            }
            
            NSString *plugins_version = settings[@"bbssdk_version"];
            NSString *bbssdk_version = [BBSSDK sdkVersion];
            NSArray<NSString *> *pluginsArr = [plugins_version componentsSeparatedByString:@"."];
            NSArray<NSString *> *bbssdkArr = [bbssdk_version componentsSeparatedByString:@"."];
            if ([pluginsArr count] > 2) {
                plugins_version = [NSString stringWithFormat:@"%@.%@",pluginsArr[0],pluginsArr[1]];
            }
            if ([bbssdkArr count] > 2) {
                bbssdk_version = [NSString stringWithFormat:@"%@.%@",bbssdkArr[0],bbssdkArr[1]];
            }
            
            dispatch_semaphore_signal(self.semaphore);
            
            if ([bbssdk_version compare:plugins_version options:NSNumericSearch] == NSOrderedDescending) {
                BBSUIAlertView *alertView = [[BBSUIAlertView alloc] initWithMessage:@"请更新插件版本" cancelButtonTitle:@"知道了" cancelBlock: nil];
                [alertView show];
            }
        }
    }];
    
    //        //阻塞线程，直到获取配置信息完成之后
    //        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)_updateKey
{
    NSLog(@"更新key相关操作");
    [[BBSUILaunchConfig shareInstance] cleaerUserConfig];
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [self _configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [self _refreshUI];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar lt_reset];
    
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}

- (void)dealloc
{
    
}

#pragma mark - private UI & UI handler
-(void)_configureUI
{
    self.automaticallyAdjustsScrollViewInsets = false;
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(self.queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setupVC];
            dispatch_semaphore_signal(self.semaphore);
        });
    });
    
}

- (void)setupVC
{
    NSLog(@"oooooooooooo  --2%@",[NSThread currentThread]);
    NSDictionary *settings = [BBSUIContext shareInstance].settings;
    BOOL hidden = NO;
    
    if (settings[@"portal"] && [settings[@"portal"] integerValue] == 1)
    {
        [self setupSegmentControlWithPortal];
        hidden = YES;
    }
    else
    {
        [self setupSegmentControlWithNoPortal];
        hidden = NO;
    }
    
    [self _createNavView:hidden];
    
    [self _refreshUI];
}

- (void)setupSegmentControlWithNoPortal
{
    BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] init];
    vc.viewType = BBSUIThreadListViewTypeThread;
    vc.offSetBlock = ^(CGFloat offset) {
        [self setContentOffSet:offset];
    };

    self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake((DZSUIScreen_width-80)/2, 15, 80, 42) titleFontSize:16 isIntegrated:YES];
    //    self.segmentControl.tableViewY = - 20;
    self.segmentControl.notScroll = YES;
    
    self.segments = [self.segmentControl settingTitles:@[@"论坛"] ];
    self.segmentControl.viewControllers = @[vc];
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(0xFFAA42)];
    [self.segmentControl setTitleNormalColor:[UIColor whiteColor]];
    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0xFFAA42)];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.isIntegrated = YES;
    self.segmentControl.delegate = self;
    self.segmentControl.bottomViewIsAlignment = YES;
    
    self.segmentControl.changeControllerBlock = ^(NSUInteger index) {
    };
}

- (void)setupSegmentControlWithPortal
{
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        self.iphoneXTopPadding = 30;
    }
    
    BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] init];
    vc.viewType = BBSUIThreadListViewTypeThread;
    vc.offSetBlock = ^(CGFloat offset) {
        [self setContentOffSet:offset];
    };
    
    BBSUIPortalViewController *vc2 = [[BBSUIPortalViewController alloc] init];
    vc2.offSetBlock = ^(CGFloat offset) {
        [self setContentOffSet:offset];
    };
    
    self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake((DZSUIScreen_width-160)/2, 15+_iphoneXTopPadding, 160, 42) titleFontSize:16 isIntegrated:YES];
    //self.segmentControl.tableViewY = - 20;
    self.segmentControl.notScroll = YES;
    
    self.segments = [self.segmentControl settingTitles:@[@"资讯", @"论坛"] ];
    self.segmentControl.viewControllers = @[vc2, vc];
    NSLog(@"=====%@", self.segmentControl.viewControllers);
    
    [self.segmentControl setBottomViewColor:DZSUIColorFromHex(0xFFAA42)];
    [self.segmentControl setTitleNormalColor:[UIColor whiteColor]];
    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0xFFAA42)];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.isIntegrated = YES;
    self.segmentControl.delegate = self;
    self.segmentControl.bottomViewIsAlignment = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.navView)
    {
        [self.view bringSubviewToFront:self.navView];
    }
}

#pragma mark - 配置导航搜索发帖 头部
- (void)_createNavView:(BOOL)hidden
{
    self.navView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, NavigationBar_Height + _iphoneXTopPadding)];
    
    [self.view addSubview:self.navView];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:15];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setFrame:CGRectMake(7, 27+_iphoneXTopPadding, 30, 30)];
    [self.navView addSubview:self.loginButton];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] forState:UIControlStateNormal];
    [self.postButton setFrame:CGRectMake(DZSUIScreen_width - 7 - 30, 27+_iphoneXTopPadding, 30, 30)];
    [self.postButton addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.postButton];
    self.postButton.hidden = hidden;
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(BBS_LEFT(self.postButton) - 10 - 30, 27+_iphoneXTopPadding, 30, 30)];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.searchButton];
    
    self.searchButton.hidden = hidden;
    
    self.navTitleLabel = [UILabel new];
    [self.navTitleLabel setFrame:CGRectMake(0, 20+_iphoneXTopPadding, DZSUIScreen_width, 44)];
    [self.navTitleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:16]];
    [self.navTitleLabel setTextColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0]];
    [self.navTitleLabel setText:@"首页"];
    [self.navTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navView addSubview:self.segmentControl];
    [self.navView setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0]];
}

- (void)_createNavView222:(BOOL)hidden
{
    self.navView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, _iphoneXTopPadding, DZSUIScreen_width, NavigationBar_Height)];
    [self.view addSubview:self.navView];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:15];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setFrame:CGRectMake(7, 27, 30, 30)];
    [self.navView addSubview:self.loginButton];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage BBSImageNamed:@"/Home/postThreadWhite@2x.png"] forState:UIControlStateNormal];
    [self.postButton setFrame:CGRectMake(DZSUIScreen_width - 7 - 30, 27, 30, 30)];
    [self.postButton addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.postButton];
    self.postButton.hidden = hidden;
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage BBSImageNamed:@"/Common/searchWhite@2x.png"] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(BBS_LEFT(self.postButton) - 10 - 30, 27, 30, 30)];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.searchButton];
    
    self.searchButton.hidden = hidden;
    
    self.navTitleLabel = [UILabel new];
    [self.navTitleLabel setFrame:CGRectMake(0, 20, DZSUIScreen_width, 44)];
    [self.navTitleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:16]];
    [self.navTitleLabel setTextColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0]];
    [self.navTitleLabel setText:@"首页"];
    [self.navTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navView addSubview:self.segmentControl];
    [self.navView setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0]];
}

- (void)_refreshUI
{
    if ([BBSUIContext shareInstance].currentUser) {
       
        if ([BBSUIContext shareInstance].currentUser.avatar) {
            MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
            [getter removeImageObserver:self.verifyImgObserver];
            [self.loginButton setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault3.png"] forState:UIControlStateNormal];
            NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", [BBSUIContext shareInstance].currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
            if (![[BBSUIContext shareInstance].currentUser.avatar containsString:@"?"])
            {
                urlString = [BBSUIContext shareInstance].currentUser.avatar;
            }
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

- (void)setContentOffSet:(CGFloat)offSetf
{
    if (offSetf >= 0 && offSetf <= 245-64)
    {
        CGFloat alpha = offSetf / 181.0;
        [self.navView setBackgroundColor:[UIColor colorWithWhite:0.f alpha:alpha]];
    }
    else if (offSetf < 0)
    {
//        CGRect navFrame = self.navView.frame;
//        navFrame.origin.y = -offSetf;
//        self.navView.frame = navFrame;
    }
    
    _lastTableViewOffsetY = offSetf;
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

#pragma mark -搜索
- (void)searchAction:(UIButton *)sender {
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    
    id controller = [MOBFViewController currentViewController];
    if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
    {
        controller = ((UITabBarController *)controller).selectedViewController;
    }
    
    [((UIViewController *)controller).navigationController pushViewController:vc animated:YES];
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

-(void)selectIndex:(NSInteger)index
{
    if (index == 1)
    {
        self.postButton.hidden = NO;
        self.searchButton.hidden = NO;
    }
    else
    {
        self.postButton.hidden = YES;
        self.searchButton.hidden = YES;
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
