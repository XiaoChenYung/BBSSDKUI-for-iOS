//
//  BBSThread+BBSUI.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSThread+BBSUI.h"
#import <objc/runtime.h>

@implementation BBSThread (BBSUI)

- (BOOL)isSelected
{
    return [objc_getAssociatedObject(self, @"BBSThreadSelectKey") boolValue];
}

- (void)setSelect:(BOOL)select
{
    objc_setAssociatedObject(self, @"BBSThreadSelectKey", @(select), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
