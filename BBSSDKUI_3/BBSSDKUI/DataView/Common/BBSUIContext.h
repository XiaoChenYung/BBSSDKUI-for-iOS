//
//  BBSUIContext.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/26.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BBSSDK/BBSSDK.h>

@interface BBSUIContext : NSObject

+ (instancetype) shareInstance ;

@property (nonatomic, strong) BBSUser *currentUser ;

/**
 全局配置
 {
 "floodctrl":"15", // 两次发表时间间隔(秒),两次发帖间隔小于此时间则不允许发布，0 为不限制
 "portal":1 // 是否开启门户，1为开启，0为未开启（默认）
 "target":{
 "appkey":"aaaaaaa",
 "appSecret":"bbbbbbbbbbbbbbbbbb"
 }
 */
@property (nonatomic, strong) NSDictionary *settings;

/**
 上次发帖时间
 */
@property (nonatomic, assign) NSInteger lastFastPostTime;

@property (nonatomic, assign, readonly) BOOL isIphoneX;

@end
