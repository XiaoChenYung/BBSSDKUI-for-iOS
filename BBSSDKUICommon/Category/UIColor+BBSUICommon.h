//
//  UIColor+BBSUICommon.h
//  BBSSDKUI
//
//  Created by liyc on 2017/3/3.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BBSUICommon)

/**
 *  获取颜色
 *
 *  @param string 颜色字符串
 *
 *  @return 颜色
 */
+ (instancetype)bbs_colorFormString:(NSString *)string;

/**
 *  获取随机颜色
 *
 *  @return 随机色
 */
+ (instancetype)bbs_randomColor;

@end
