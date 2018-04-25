//
//  AppDelegate.m
//  BBSSDKDemo
//
//  Created by liyc on 2017/3/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "AppDelegate.h"
#import "MyBBSViewController.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDKUI/BBSUIForumHomeViewController.h>
#import <MobLink/MobLink.h>
#import <MobLink/IMLSDKRestoreDelegate.h>


#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//#define Appkey @"1bbd3fd16d288" //安卓巴士
//#define Appkey @"1bbd456d78f24" //code4app
//#define Appkey @"1c0aa3d963957" //test

//Appkey：1bbd456d78f24
//AppScrect：cee607fd53bc73ffbc73bbc753540526
//
//#define Appkey @"1cef71d01649c"
//#define AppSecret @"9303897ca795d764c704df5843d4450b"

//#define Appkey @"1cef71d01649c"
//#define AppSecret @"9303897ca795d764c704df5843d4450b"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [ShareSDK registerActivePlatforms:@[
//                                        @(SSDKPlatformTypeSinaWeibo),
//                                        @(SSDKPlatformTypeMail),
//                                        @(SSDKPlatformTypeSMS),
//                                        @(SSDKPlatformTypeCopy),
//                                        @(SSDKPlatformTypeWechat),
//                                        @(SSDKPlatformTypeQQ),
//                                        @(SSDKPlatformTypeRenren),
//                                        @(SSDKPlatformTypeFacebook),
//                                        @(SSDKPlatformTypeTwitter),
//                                        @(SSDKPlatformTypeGooglePlus)
//                                        ]
//                             onImport:^(SSDKPlatformType platformType)
//     {
//         switch (platformType)
//         {
//             case SSDKPlatformTypeWechat:
//                 [ShareSDKConnector connectWeChat:[WXApi class]];
//                 break;
//             case SSDKPlatformTypeQQ:
//                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
//                 break;
//             default:
//                 break;
//         }
//     }
//                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
//     {
//         
//         switch (platformType)
//         {
//             case SSDKPlatformTypeWechat:
//                 [appInfo SSDKSetupWeChatByAppId:@"wx8f541f6c92eaca46"
//                                       appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
//                 break;
//             case SSDKPlatformTypeQQ:
//                 [appInfo SSDKSetupQQByAppId:@"1106410295"
//                                      appKey:@"QXjmJrcrh2BcSQAP"
//                                    authType:SSDKAuthTypeBoth];
//                 break;
//             default:
//                 break;
//         }
//     }];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    MyBBSViewController *vc = [[MyBBSViewController alloc] init];
    [_window setRootViewController:vc];
    [_window makeKeyAndVisible];
    
//    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    BBSUIForumHomeViewController *homeVC = [BBSUIForumHomeViewController forumHomeViewControllerWithTitle:@"安卓巴士"];
//
//    [_window setRootViewController:homeVC];
//    [_window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)IMLSDKWillRestoreScene:(MLSDKScene *)scene Restore:(void (^)(BOOL isRestore, RestoreStyle style))restoreHandler
{
    restoreHandler(YES, RestoreStyleMLDefault);
}


@end
