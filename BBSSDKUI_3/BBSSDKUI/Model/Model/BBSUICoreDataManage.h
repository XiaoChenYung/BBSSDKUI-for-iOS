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
- (void)deleteHistoryWithAid:(NSInteger)aid;

- (NSArray *)queryHistoryWithId:(NSInteger)ID limit:(NSInteger)limit;

- (CGFloat)getDataSize;

- (void)clearCache;

@property (nonatomic, assign) NSInteger historyCount;

@end
