//
//  BBSUIForumViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumViewController.h"
#import "BBSUIForumView.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "BBSUIUserMeInfoViewController.h"

@interface BBSUIForumViewController ()

@property (nonatomic, strong) BBSUIForumView *forumView;

@property (nonatomic, strong) UIImageView *img;

@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@end

@implementation BBSUIForumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.forumView = [[BBSUIForumView alloc] init];
    [self.view addSubview:self.forumView];
    [self.forumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = @"粉丝";
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Frameworks/BBSSDKUI" ofType:@"framework"]];
//        NSLog(@"bundle: %@", bundle);
//        NSArray *objs = [bundle loadNibNamed:@"BBSUIPostTip" owner:nil options:nil];
//        
//        UIView *xibView = objs[0];
//        //    xibView.backgroundColor = [UIColor redColor];
//        
//        [[UIApplication sharedApplication].keyWindow addSubview:xibView];
//        [xibView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo([UIApplication sharedApplication].keyWindow);
//        }];
//    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self setupLeftBarButton];
    [self.forumView reloadStickData];
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

- (void)login:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.mob.bbs.sdk.BBSNeedLogin" object:nil];
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
                userInfoViewController.hidesBottomBarWhenPushed = true;
                [self.navigationController pushViewController:userInfoViewController animated:YES];
                
            }else{
                
                if (error.code == 9001200) {
                    
                    [BBSUIContext shareInstance].currentUser = nil;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.mob.bbs.sdk.BBSNeedLogin" object:nil];
                    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
//                                        [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
                }
                
                return ;
            }
        }];
    }
}

@end
