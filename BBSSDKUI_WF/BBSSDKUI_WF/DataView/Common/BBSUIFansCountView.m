//
//  BBSUIFansCountView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIFansCountView.h"
#import "Masonry.h"

@implementation BBSUIFansCountView

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

- (void)configUI {
    UIView *viewLine = [UIView new];
    viewLine.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
    [self addSubview:viewLine];
    
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@14);
        make.bottom.equalTo(@-14);
        make.width.equalTo(@1);
        make.centerX.equalTo(self);
    }];
    
    self.attentionCountButton =
    ({
        UIButton *attentCount = [UIButton new];
        [self addSubview:attentCount];
        [attentCount mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
            make.top.left.bottom.equalTo(@0);
            make.right.equalTo(viewLine.mas_left);
        }];
        
        attentCount;
    });
    
    self.fansCountButton =
    ({
        UIButton *fansCount = [UIButton new];
        [self addSubview:fansCount];
        
        [fansCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(@0);
            make.left.equalTo(viewLine.mas_right);
        }];
        
        fansCount;
    });
}



@end
