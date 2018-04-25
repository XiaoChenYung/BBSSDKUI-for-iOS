//
//  BBSUIContentInsetsLabel.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIContentInsetsLabel.h"

@implementation BBSUIContentInsetsLabel

- (instancetype)init {
    if (self = [super init]) {
        _contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _contentInsets)];
}


@end
