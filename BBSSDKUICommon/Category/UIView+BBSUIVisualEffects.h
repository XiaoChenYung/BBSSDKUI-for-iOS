//
//  UIView+BBSUIVisualEffects.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSUIUserOtherInfoView.h"

@interface UIView (BBSUIVisualEffects)

/**
 设置view的背景图片
 @param image image
 */
- (void)bbs_backgroundImageWithImage:(UIImage *)image;

/**
 设置毛玻璃效果
 */
//- (void)bbs_addVisualEffectView;
- (void)bbs_addVisualEffectView:(UserType)oneType;

@end
