//
//  BBSUILBSLocationProxy.h
//  BBSSDKUI
//
//  Created by wukx on 2018/5/10.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSUILBSLocationProxy : NSObject

/**
 单例
 */
+(instancetype)sharedInstance;


/**
 地图是否可用
 */
- (BOOL)isLBSUsable;

@end
