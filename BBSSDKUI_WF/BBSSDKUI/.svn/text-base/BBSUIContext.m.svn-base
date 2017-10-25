//
//  BBSUIContext.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/26.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIContext.h"
#import <MOBFoundation/MOBFDataService.h>

static NSString * const kCurrentUser = @"com.bbsui.currentUser";

@interface BBSUIContext()
{
    BBSUser *_currentUser;
}

@end

@implementation BBSUIContext

+ (instancetype) shareInstance
{
    static BBSUIContext * share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[BBSUIContext alloc] init];
    });
    return share ;
}

- (BBSUser *)currentUser
{
    if (!_currentUser)
    {
        _currentUser = [[MOBFDataService sharedInstance] cacheDataForKey:kCurrentUser domain:@"BBSUI"];
    }
    return _currentUser ;
}

- (void)setCurrentUser:(BBSUser *)currentUser
{
    _currentUser = currentUser;
   
    [[MOBFDataService sharedInstance] setCacheData:currentUser forKey:kCurrentUser domain:@"BBSUI"];
}


@end
