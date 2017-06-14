//
//  BBSUICacheManager.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/24.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSUICacheManager : NSObject

+ (BBSUICacheManager *)sharedInstance;

/**
 置顶版块
 */
@property (nonatomic, strong) NSArray *stickForums;

@end
