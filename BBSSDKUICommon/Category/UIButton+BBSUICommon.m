//
//  UIButton+BBSUICommon.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/3.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "UIButton+BBSUICommon.h"

@implementation UIButton (BBSUICommon)

+ (instancetype)bbs_buttonWithTitle:(NSString *)title
                     titleColor:(UIColor *)titleColor
                backgroundColor:(UIColor *)backgroundColor
                           font:(CGFloat)font
                         target:(id)target
                         action:(SEL)action
                      superView:(UIView *)view
{
    return [self bbs_buttonWithFrame:CGRectZero
                           title:title
                      titleColor:titleColor
                 backgroundColor:backgroundColor
                            font:font
                          target:target
                          action:action
                       superView:view];
}

+ (instancetype)bbs_buttonWithFrame:(CGRect)frame
                          title:(NSString *)title
                     titleColor:(UIColor *)titleColor
                backgroundColor:(UIColor *)backgroundColor
                           font:(CGFloat)font
                         target:(id)target
                         action:(SEL)action
                      superView:(UIView *)view
{
    return [self bbs_buttonWithFrame:frame
                           title:title
                      titleColor:titleColor
                 backgroundColor:backgroundColor
                            font:font
                       imageName:nil
                          target:target
                          action:action
                       superView:view];
}

+ (instancetype)bbs_buttonWithImageName:(NSString *)imageName
                             target:(id)target
                             action:(SEL)action
                          superView:(UIView *)view
{
    return [self bbs_buttonWithFrame:CGRectZero
                       imageName:imageName
                          target:target
                          action:action
                       superView:view];
}

+ (instancetype)bbs_buttonWithFrame:(CGRect)frame
                      imageName:(NSString *)imageName
                         target:(id)target
                         action:(SEL)action
                      superView:(UIView *)view
{
    return [self bbs_buttonWithFrame:frame
                           title:nil
                      titleColor:nil
                 backgroundColor:nil
                            font:0
                       imageName:imageName
                          target:target
                          action:action
                       superView:view];
}

#pragma mark - Private

+ (instancetype)bbs_buttonWithFrame:(CGRect)frame
                          title:(NSString *)title
                     titleColor:(UIColor *)titleColor
                backgroundColor:(UIColor *)backgroundColor
                           font:(CGFloat)font
                      imageName:(NSString *)imageName
                         target:(id)target
                         action:(SEL)action
                      superView:(UIView *)view
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (imageName != nil)
    {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    if (backgroundColor != nil)
    {
        [button setBackgroundColor:backgroundColor];
    }
    
    if (titleColor != nil)
    {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    if (view != nil)
    {
        [view addSubview:button];
    }
    
    button.frame = frame;
    button.titleLabel.font = [UIFont systemFontOfSize:font];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
