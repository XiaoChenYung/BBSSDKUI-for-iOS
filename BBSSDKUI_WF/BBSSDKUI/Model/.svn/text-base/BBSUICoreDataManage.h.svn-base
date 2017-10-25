//
//  BBSUICoreDataManage.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History.h"
@class BBSThread;

@interface BBSUICoreDataManage : NSObject

+ (instancetype) shareManager;

- (void)addHistoryWithThread:(BBSThread *)thread;

- (void)deleteHistoryWithTid:(NSInteger)tid;

- (NSArray *)queryHistoryWithTid:(NSInteger)tid limit:(NSInteger)limit;

@property (nonatomic, assign) NSInteger historyCount;

@end
