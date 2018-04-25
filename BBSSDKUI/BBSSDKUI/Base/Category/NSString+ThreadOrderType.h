//
//  NSString+ThreadOrderType.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSUIEnum.h"

@interface NSString (ThreadOrderType)

+ (NSString *)selectTypeStringFromSelectType:(BBSUIThreadSelectType)selectType;

+ (NSString *)orderTypeStringFromOrderType:(BBSUIThreadOrderType)orderTypel;



@end
