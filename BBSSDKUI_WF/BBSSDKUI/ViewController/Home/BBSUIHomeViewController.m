//
//  BBSUIHomeViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIHomeViewController.h"
#import "LBSegmentControl.h"
#import "BBSUIThreadListViewController.h"
#import "BBSUIForumViewController.h"
#import "BBSUIFastPostViewController.h"
#import "BBSUILoginViewController.h"
#import "BBSUISearchViewController.h"

#import "BBSUIContext.h"
#import "BBSUIUserMeInfoViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "BBSUIMainStyleNavigationController.h"
#import "BBSUIStatusBarTip.h"
#import "UIButton+WebCache.h"

@interface BBSUIHomeViewController ()<iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) LBSegmentControl * segmentControl;
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@end

@implementation BBSUIHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRightBarButton];
    //    [self setupLeftBarButton];
    //设置自定义标题栏按钮
    [self setCustomNavTitleView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLeftBarButton];
    
}

- (void)setCustomNavTitleView
{
    //首页所有帖子列表视图
    BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] init];
    BBSUIForumViewController *vc2 = [[BBSUIForumViewController alloc] init];
    
    self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, 160, 42) titleFontSize:17 isIntegrated:YES];
    self.segmentControl.titles = @[@"帖子", @"版块"];
    self.segmentControl.viewControllers = @[vc, vc2];
    [self.segmentControl setBottomViewColor:[UIColor whiteColor]];
    [self.segmentControl setTitleNormalColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]];
    [self.segmentControl setTitleSelectColor:[UIColor whiteColor]];
    self.segmentControl.isTitleScale = NO;
    self.segmentControl.isIntegrated = YES;
    self.segmentControl.bottomViewIsAlignment = YES;
    self.navigationItem.titleView= self.segmentControl;
}

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
        
        __weak typeof (self) weakSelf = self;
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
}

@end
