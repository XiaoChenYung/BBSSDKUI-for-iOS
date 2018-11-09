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
#import "BBSUIForumViewController.h"
#import "BBSUIFastPostViewController.h"
#import "BBSUILoginViewController.h"
#import "BBSUISearchViewController.h"
#import "BBSUINewsViewController.h"
#import "BBSUITribuneViewController.h"

#import "BBSUIContext.h"
#import "BBSUIUserMeInfoViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUIStatusBarTip.h"
#import "UIButton+WebCache.h"
#import "BBSUILaunchConfig.h"
#import "BBSUIAlertView.h"


@interface BBSUIHomeViewController ()<iBBSUIFastPostViewControllerDelegate,BBSUILBSegmentControlDelegate>

@property (nonatomic, strong) BBSUILBSegmentControl * segmentControl;
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@property (nonatomic, strong) UIButton          *postButton;
@property (nonatomic, strong) UIButton          *searchButton;

// 加锁操作
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation BBSUIHomeViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.semaphore = dispatch_semaphore_create(0);
        self.queue = dispatch_queue_create("HomeViewControllerQueue", DISPATCH_QUEUE_SERIAL);
       
        dispatch_async(_queue, ^{
            //阻塞线程，直到获取配置信息完成之后
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            
        });

        [BBSSDK getGlobalSettings:^(NSDictionary *settings, NSError *error) {
            if (settings)
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
                NSLog(@"oooooooooooo  --1%@",settings);
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
                    //BBSUIAlertView *alertView = [[BBSUIAlertView alloc] initWithMessage:@"请更新插件版本" cancelButtonTitle:@"知道了" cancelBlock: nil];
                    //[alertView show];
                }
            }
            else
            {
                [self _setupVC:NO];
            }
        }];
        
        //阻塞线程，直到获取配置信息完成之后
        //dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
    
    return self;
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
    [self setupRightBarButton];
    //[self setupLeftBarButton];
    //设置自定义标题栏按钮
    [self setCustomNavTitleView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLeftBarButton];
}

#pragma mark - configure VC
- (void)setCustomNavTitleView
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf _setupVC:YES];
            dispatch_semaphore_signal(self.semaphore);
        });
    });
}

- (void)_setupVC:(BOOL)isSettingsLoadSuccess
{
    NSLog(@"oooooooooooo  --2%@",[NSThread currentThread]);
    NSDictionary *settings = [BBSUIContext shareInstance].settings;
    BOOL hidden = NO;
    
    /* 不管是否用插件接口，要调用一下settings
     * 使用插件，就不再使用settings中的portol字段，默认显示论坛
     * 不是用插件，使用settings中portol字段，来判断是都显示资讯和论坛
     */
    
    NSString *address =  settings[@"address"];
    if (address.length > 0)
    {//是插件
        [self setupSegmentControlWithPortal];
        hidden = YES;
    }
    else
    {//不使用插件
        if (settings[@"portal"] && [settings[@"portal"] integerValue] == 1 && isSettingsLoadSuccess)
        {
            [self setupSegmentControlWithPortal];
            hidden = YES;
        }
        else
        {
            [self setupSegmentControlWithNoPortal];
            hidden = NO;
        }
    }
    
//    if (usePlugApi)
//    {//使用的是插件
//        [self setupSegmentControlWithPortal];
//        hidden = YES;
//    }
//    else
//    {//不使用插件
//        if (settings[@"portal"] && [settings[@"portal"] integerValue] == 1 && isSettingsLoadSuccess)
//        {
//            [self setupSegmentControlWithPortal];
//            hidden = YES;
//        }
//        else
//        {
//            [self setupSegmentControlWithNoPortal];
//            hidden = NO;
//        }
//    }
}

- (void)setupSegmentControlWithNoPortal
{
    //首页所有帖子列表视图
    BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] init];
    
    self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, 80, 42) titleFontSize:17 isIntegrated:YES];
    self.segmentControl.titles = @[@"论坛"];
    self.segmentControl.notScroll = YES;
    self.segmentControl.viewControllers = @[vc];
    [self.segmentControl setBottomViewColor:[UIColor whiteColor]];
    [self.segmentControl setTitleNormalColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]];
    [self.segmentControl setTitleSelectColor:[UIColor whiteColor]];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.isIntegrated = YES;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.segmentControl.delegate = self;
    self.navigationItem.titleView= self.segmentControl;
}

- (void)setupSegmentControlWithPortal
{
    //资讯
    BBSUIThreadListViewController *vc = [BBSUIThreadListViewController new];
    vc.pageType = PageTypePortal;

    //论坛
    BBSUITribuneViewController *vc2 = [[BBSUITribuneViewController alloc] initWithForum:nil selectType:1];
    
    self.segmentControl = [[BBSUILBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, 160, 42) titleFontSize:17 isIntegrated:YES];
    self.segmentControl.titles = @[@"资讯", @"论坛"];
    self.segmentControl.notScroll = YES;
    self.segmentControl.viewControllers = @[vc, vc2];
    [self.segmentControl setBottomViewColor:[UIColor whiteColor]];
    [self.segmentControl setTitleNormalColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]];
    [self.segmentControl setTitleSelectColor:[UIColor whiteColor]];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.isIntegrated = YES;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.segmentControl.delegate = self;
    self.navigationItem.titleView= self.segmentControl;
}

#pragma mark - 首页发帖
- (void)editThread:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        BBSUIFastPostViewController *editVC = [BBSUIFastPostViewController shareInstance];
        editVC.isEnterVc = YES;
        [editVC addPostThreadObserver:self];
        BBSUIMainStyleNavigationController *mainStyleNav = [[BBSUIMainStyleNavigationController alloc] initWithRootViewController:editVC];
        
        [self presentViewController:mainStyleNav animated:YES completion:nil];
    }
}

- (void)searchAction:(UIButton *)sender {
    BBSUISearchViewController *vc = [BBSUISearchViewController new];
    
    id controller = [MOBFViewController currentViewController];
    if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
    {
        controller = ((UITabBarController *)controller).selectedViewController;
    }
    
    [((UIViewController *)controller).navigationController pushViewController:vc animated:YES];
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
        
        [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
            
            if (!error) {
                currentUser.favorites  = user.favorites;
                currentUser.followers  = user.followers;
                currentUser.threads    = user.threads;
                currentUser.firends    = user.firends;
                currentUser.notices    = user.notices;
                
                [BBSUIContext shareInstance].currentUser = currentUser;
                BBSUIUserMeInfoViewController *userInfoViewController = [[BBSUIUserMeInfoViewController alloc] initWithUser:[BBSUIContext shareInstance].currentUser];
                [self.navigationController pushViewController:userInfoViewController animated:YES];
                
            }else{
                
                if (error.code == 9001200) {
                    
                    [BBSUIContext shareInstance].currentUser = nil;
                    
                    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    //                    [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
                }
                
                return ;
            }
        }];
    }}

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

- (void)setupLeftBarButton
{
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.frame = CGRectMake(0, 0, 30, 30);
    
    [login.layer setMasksToBounds:YES];
    [login.layer setCornerRadius:15];
//    if ([BBSUIContext shareInstance].currentUser && [BBSUIContext shareInstance].currentUser.avatar) {
//
//        NSString *avatarURLBig = [BBSUIContext shareInstance].currentUser.avatar;
//        NSString *avatarURLSmall = [avatarURLBig stringByReplacingOccurrencesOfString:@"big" withString:@"small"];
//
//        NSString *avatarURL = [avatarURLSmall stringByAppendingFormat:@"&timestamp=%f", [NSDate date].timeIntervalSince1970];
//        if (![[BBSUIContext shareInstance].currentUser.avatar containsString:@"?"])
//        {
//            avatarURL = avatarURLSmall;
//        }
////
////        UIImage *scaleImage = [MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Home/NoUser.png"] withSize:CGSizeMake(60, 60)];
////        [login setImage:scaleImage forState:UIControlStateNormal];
////        login.contentMode = UIViewContentModeScaleAspectFill;
////        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:avatarURL] result:^(UIImage *image, NSError *error) {
////
////            UIImage *avatarImage = nil;
////            if (error) {
////                avatarImage = [UIImage BBSImageNamed:@"/Home/NoUser.png"];
////            }else{
////                avatarImage = image;
////            }
////            UIImage *scaleImage = [MOBFImage scaleImage:avatarImage withSize:CGSizeMake(60, 60)];
////            [login setImage:scaleImage forState:UIControlStateNormal];
////
////        }];
//
//        NSLog(@"_____________   %@",avatarURL ? avatarURL : avatarURLBig);
//
//        [login sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarURL ? avatarURL : avatarURLBig]
//                                   forState:UIControlStateNormal
//                           placeholderImage:[UIImage BBSImageNamed:@"/Home/NoUser@2x.png"]
//                                    options:SDWebImageRefreshCached];//不使用缓存
//
//    }else{
//        UIImage *scaleImage = [UIImage BBSImageNamed:@"/Home/NoUser@2x.png"];
//        [login setImage:scaleImage forState:UIControlStateNormal];
//    }
    

    
    if ([BBSUIContext shareInstance].currentUser) {
        
        if ([BBSUIContext shareInstance].currentUser.avatar) {
            MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
            [getter removeImageObserver:self.verifyImgObserver];
            [login setImage:[UIImage BBSImageNamed:@"/Home/NoUser@2x.png"] forState:UIControlStateNormal];
            NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", [BBSUIContext shareInstance].currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
            if (![[BBSUIContext shareInstance].currentUser.avatar containsString:@"?"])
            {
                urlString = [BBSUIContext shareInstance].currentUser.avatar;
            }
            self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error){
                
                if (image) {
                    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0)
                    {
                        [login.widthAnchor constraintEqualToConstant:30].active = YES;
                        [login.heightAnchor constraintEqualToConstant:30].active = YES;
                        [login setImage:image forState:UIControlStateNormal];
                    }
                    else
                    {
                        UIImage *scaleImage = [MOBFImage scaleImage:image withSize:CGSizeMake(30, 30)];
                        [login setImage:scaleImage forState:UIControlStateNormal];
                    }
                    
                    
                    UIImageView *img = [UIImageView new];
                    [img setImage:image];
                    [img setFrame:CGRectMake(0, 100, 100, 100)];
                    //                    [self.view addSubview:img];
                }
                
            }];
            
        }else{
            [login setImage:[UIImage BBSImageNamed:@"/Home/NoUser@2x.png"] forState:UIControlStateNormal];
        }
    }else{
        
        [login setImage:[UIImage BBSImageNamed:@"/Home/NoUser@2x.png"] forState:UIControlStateNormal];
    }
    
    [login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:login];
}

- (void)setupRightBarButton
{
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(0, 0, 30, 30);
    UIImage *editScaleImage = [UIImage BBSImageNamed:@"/Home/PostThread@2x.png"];
    [postThread setImage:editScaleImage forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postThreadBarButton = [[UIBarButtonItem alloc] initWithCustomView:postThread];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 15;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 30);
    UIImage *searchScaleImage = [UIImage BBSImageNamed:@"/Common/SearchGuide@2x.png"];
    [searchBtn setImage:searchScaleImage forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    self.navigationItem.rightBarButtonItems = @[postThreadBarButton, spaceItem, searchBarButton];
    
    self.postButton = postThread;
    self.searchButton = searchBtn;
    
    self.postButton.hidden = YES;
    self.searchButton.hidden = YES;
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
@end
