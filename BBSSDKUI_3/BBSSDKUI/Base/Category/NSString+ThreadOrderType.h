//
//  NSString+ThreadOrderType.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBSUIThreadSelectType)
{
    BBSUIThreadSelectTypeLatest = 0,        //最新
    BBSUIThreadSelectTypeHeats = 1,         //热门
    BBSUIThreadSelectTypeDigest = 2,        //精华
    BBSUIThreadSelectTypeDisplayOrder = 3   //置顶
};

typedef NS_ENUM(NSInteger, BBSUIThreadOrderType)
{
    BBSUIThreadOrderCommentTime = 0,    //最后回复时间排序
    
    BBSUIThreadOrderPostTime = 1        //发布时间排序
};

@interface NSString (ThreadOrderType)

+ (NSString *)selectTypeStringFromSelectType:(BBSUIThreadSelectType)selectType;

+ (NSString *)orderTypeStringFromOrderType:(BBSUIThreadOrderType)orderTypel;



@end
