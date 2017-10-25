//
//  BBSUIDarkBackView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIDarkBackView.h"
#import "Masonry.h"

@implementation BBSUIDarkBackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    if (self = [super init]) {
        [self configUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *view = [UIView new];
    [self addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(@0);
    }];
    
    view.alpha = 0.3;
    view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *recoginize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    
    [view addGestureRecognizer:recoginize];
    
}

- (void)tapAction:(UIGestureRecognizer *)recognize{
    [self removeFromSuperview];
}


@end


