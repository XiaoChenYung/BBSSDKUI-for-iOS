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

#import "BBSUIContext.h"
#import "BBSUIUserInfoViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>

@interface BBSUIHomeViewController ()<iBBSUIFastPostViewControllerDelegate>

@property (nonatomic, strong) LBSegmentControl * segmentControl;

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
    
    self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake(0, 0, 160, 42) titleFontSize:17];
    self.segmentControl.titles = @[@"帖子", @"版块"];
    self.segmentControl.viewControllers = @[vc, vc2];
    [self.segmentControl setBottomViewColor:[UIColor whiteColor]];
    [self.segmentControl setTitleNormalColor:[UIColor whiteColor]];
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
        
        [self.navigationController pushViewController:editVC animated:YES];
    }
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
        BBSUIUserInfoViewController *userInfoViewController = [[BBSUIUserInfoViewController alloc] initWithUser:[BBSUIContext shareInstance].currentUser];
        [self.navigationController pushViewController:userInfoViewController animated:YES];
    }}

#pragma mark - iBBSUIFastPostViewControllerDelegate

- (void)didBeginPostThread
{
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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

- (void)setupLeftBarButton
{
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.frame = CGRectMake(0, 0, 30, 30);
    
    if ([BBSUIContext shareInstance].currentUser && [BBSUIContext shareInstance].currentUser.avatar) {
        NSString *avatarURL = [[BBSUIContext shareInstance].currentUser.avatar stringByAppendingFormat:@"&timestamp=%f", [NSDate date].timeIntervalSince1970];
        
        [login.layer setCornerRadius:15];
        [login.layer setMasksToBounds:YES];
        [login setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault.png"] forState:UIControlStateNormal];
        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:avatarURL] result:^(UIImage *image, NSError *error) {
            
            if (error) {
                [login setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault.png"] forState:UIControlStateNormal];
            }else{
                [login setImage:image forState:UIControlStateNormal];
            }
            
        }];
    }else{
        [login.layer setMasksToBounds:NO];
        [login setImage:[UIImage BBSImageNamed:@"/Home/login.png"] forState:UIControlStateNormal];
    }
    
    [login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:login];
}

- (void)setupRightBarButton
{
    UIButton *postThread = [UIButton buttonWithType:UIButtonTypeCustom];
    postThread.frame = CGRectMake(0, 0, 30, 30);
    [postThread setImage:[UIImage BBSImageNamed:@"/Home/postThread.png"] forState:UIControlStateNormal];
    [postThread addTarget:self action:@selector(editThread:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postThread];
}

@end
