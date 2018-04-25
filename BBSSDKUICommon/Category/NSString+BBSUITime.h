//
//  NSString+BBSUITime.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/22.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BBSUITime)

+ (NSString *)bbs_timeTextWithOffset:(NSInteger)offset;

+ (NSString *)bbs_timeTextWithTimesStamp:(double)timesStamp;

@end
