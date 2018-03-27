//
//  BBSUIContext.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/26.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIContext.h"
#import <MOBFoundation/MOBFDataService.h>
#import <sys/utsname.h>

static NSString * const kCurrentUser = @"com.bbsui.currentUser";
static NSString * const kGlobalSettings = @"com.bbsui.globalSettings";
static NSString * const kLastFastPostTime = @"com.bbsui.lastFastPostTime";

@interface BBSUIContext()
{
    BBSUser *_currentUser;
    NSDictionary *_settings;
    NSInteger _lastFastPostTime;
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


- (NSDictionary *)settings
{
    if (!_settings)
    {
        _settings = [[MOBFDataService sharedInstance] cacheDataForKey:kGlobalSettings domain:@"BBSUISETTINGS"];
    }
    return _settings;
}

- (void)setSettings:(NSDictionary *)settings
{
    _settings = settings;
    [[MOBFDataService sharedInstance] setCacheData:settings forKey:kGlobalSettings domain:@"BBSUISETTINGS"];
}

//- (NSInteger)lastFastPostTime
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger lastPostTime = [defaults integerForKey:kLastFastPostTime];
//
//    return lastPostTime;
//}
//
//- (void)setLastFastPostTime:(NSInteger)lastFastPostTime
//{
//    _lastFastPostTime = lastFastPostTime;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@(lastFastPostTime) forKey:kLastFastPostTime];
//}

- (BOOL) isIphoneX
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone10,3"]) return YES;
    if ([platform isEqualToString:@"iPhone10,6"]) return YES;
    
    return NO;
}


@end
