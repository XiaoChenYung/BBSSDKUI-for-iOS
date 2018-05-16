//
//  BBSUILBSLocationProxy.m
//  BBSSDKUI
//
//  Created by wukx on 2018/5/10.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUILBSLocationProxy.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation BBSUILBSLocationProxy

+ (instancetype)sharedInstance
{
    static BBSUILBSLocationProxy *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBSUILBSLocationProxy alloc] init];
    });
    return instance;
}

- (BOOL)isLBSUsable
{
    if ([AMapServices sharedServices].apiKey == nil || [[AMapServices sharedServices].apiKey isEqualToString:@""])
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *AMapApiKey = [infoDictionary objectForKey:@"AMapApiKey"];
        if (AMapApiKey != nil && ![[AMapApiKey stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            return YES;
        }
        else
        {
            return NO;
        }
    }else{
        return YES;
    }
}

@end
