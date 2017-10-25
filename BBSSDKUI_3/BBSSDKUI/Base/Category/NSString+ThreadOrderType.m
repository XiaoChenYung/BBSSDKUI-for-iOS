//
//  NSString+ThreadOrderType.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "NSString+ThreadOrderType.h"

@implementation NSString (ThreadOrderType)

+ (NSString *)selectTypeStringFromSelectType:(BBSUIThreadSelectType)selectType
{
    NSString *selectTypeString = nil;
    if (selectType == BBSUIThreadSelectTypeLatest) {
        selectTypeString = @"latest";
    }else if (selectType == BBSUIThreadSelectTypeHeats)
    {
        selectTypeString = @"heats";
    }else if (selectType == BBSUIThreadSelectTypeDigest)
    {
        selectTypeString = @"digest";
    }else if (selectType == BBSUIThreadSelectTypeDisplayOrder)
    {
        selectTypeString = @"displayOrder";
    }
    
    return selectTypeString ? : @"latest";
}

+ (NSString *)orderTypeStringFromOrderType:(BBSUIThreadOrderType)orderType
{
    NSString *orderTypeString = nil;
    if (orderType == BBSUIThreadOrderCommentTime) {
        orderTypeString = @"lastPost";
    }else if (orderType == BBSUIThreadOrderPostTime)
    {
        orderTypeString = @"createdOn";
    }
    
    return orderTypeString ? : @"lastPost";
}

@end
