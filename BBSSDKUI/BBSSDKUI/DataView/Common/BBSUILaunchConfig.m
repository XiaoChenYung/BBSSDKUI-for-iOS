//
//  BBSUILaunchConfig.m
//  BBSSDKUI
//
//  Created by chuxiao on 2018/2/11.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUILaunchConfig.h"
#import "BBSUIContext.h"
#import "BBSUICoreDataManage.h"

@implementation BBSUILaunchConfig

+ (instancetype) shareInstance
{
    static BBSUILaunchConfig * share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[BBSUILaunchConfig alloc] init];
    });
    return share ;
}

- (void)cleaerUserConfig
{
    [BBSUIContext shareInstance].currentUser = nil;
    [[BBSUICoreDataManage shareManager] clearCache];
}

@end
