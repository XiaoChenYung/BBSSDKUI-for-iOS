//
//  BBSUIButton.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
}GradientType;

@interface BBSUIButton : UIButton

//!@brief 建议颜色设置为2个相近色为佳，设置3个相近色能形成拟物化的凸起感
- (id)initWithFrame:(CGRect)frame FromColorArray:(NSArray*)colorArray ByGradientType:(GradientType)gradientType;

- (void)displayButtonImageFromColors:(NSArray*)colorArray ByGradientType:(GradientType)gradientType;

@end
