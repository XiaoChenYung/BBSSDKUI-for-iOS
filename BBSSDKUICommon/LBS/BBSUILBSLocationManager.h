//
//  BBSUILBSLocationManager.h
//  BBSSDKUI_WF
//
//  Created by wukx on 2018/4/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSUILBSLocationManager : NSObject

@property(nonatomic, assign) float lontitue;
@property(nonatomic, assign) float latitude;

+ (BBSUILBSLocationManager *)shareManager;

- (BOOL)isOpenLocationServices;

- (void)startLocation;
- (void)stopLocation;

@end
