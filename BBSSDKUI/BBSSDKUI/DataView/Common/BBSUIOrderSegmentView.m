//
//  BBSUIOrderSegmentView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIOrderSegmentView.h"

@implementation BBSUIOrderSegmentView

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    for (int i = 0; i < titleArray.count; i++) {
        CGFloat width = [self.titleArray[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.btnFont]}].width+10;
        titleWidth = width + titleWidth;
    }
    [self cretBtnView];
    
}
- (void)setBtnViewHeight:(NSInteger)btnViewHeight {
    _btnViewHeight = btnViewHeight;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor= [UIColor whiteColor];
        _btnView = [[UIView alloc]init];
        _btnView.frame = CGRectMake(0,0,self.frame.size.width,self.btnViewHeight);
        [self CreatelineView];
        [self addSubview:_btnView];
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)cretBtnView {
    _btnView.frame = CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width,self.btnViewHeight);
    for (int i = 0; i < [self.titleArray count]; i++)  {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+10;
        [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
        if (i == 0) {
            [btn setTitleColor: [UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0] forState:UIControlStateNormal];
            [btn.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Medium" size:14]];
            _seletedBtn = btn;
        } else {
            [btn setTitleColor:[UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:14]];
        }
        CGFloat width = [self.titleArray[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.btnFont]}].width+10;
        CGFloat ScreenWidth = [[UIScreen mainScreen] bounds].size.width ;
        CGFloat jianJu = (ScreenWidth - titleWidth)/(self.titleArray.count +1);
        btn.frame = CGRectMake(jianJu+i*(width+jianJu), 0,width,self.btnViewHeight);
        if (i == 0) {
            self.lineView.frame = CGRectMake(jianJu,self.btnViewHeight-self.btnLineHeight,width,self.btnLineHeight);
        }
        
        lastBtn = btn;
        [_btnView addSubview:btn];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIView *downLine = [UIView new];
    downLine.frame = CGRectMake(0,self.btnViewHeight-0.3,[[UIScreen mainScreen] bounds].size.width, 0.3);
    downLine.backgroundColor = [UIColor blackColor];
    downLine.alpha = 0.3;
    [_btnView addSubview:downLine];
    [_btnView addSubview:self.lineView];
    
    
}

- (void)CreatelineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithRed:255/255.0 green:170/255.0 blue:66/255.0 alpha:1/1.0];
    }
}

//自己写的方法(按钮的点击方法/自己的方法)
- (void)btnClick:(UIButton *)sender {
    
    [UIView animateWithDuration:0.1 animations:^{
//        [_seletedBtn setTitleColor:[UIColor colorWithRed:0.276 green:0.274 blue:0.277 alpha:1.000] forState:UIControlStateNormal];
        [_seletedBtn setTitleColor:[UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [_seletedBtn.titleLabel setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:14]];
        [sender setTitleColor:[UIColor colorWithRed:42/255.0 green:43/255.0 blue:48/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [sender.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Medium" size:14]];
        CGFloat x = CGRectGetMinX(sender.frame);
        CGFloat width = CGRectGetWidth(sender.frame);
        self.lineView.frame = CGRectMake(x,self.btnViewHeight-self.btnLineHeight, width, self.btnLineHeight);
    }];
    
    _seletedBtn = sender;
    
    if (self.delegate) {
        [self.delegate clickHandler:(sender.tag - 10)];
    }
    
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    index = scrollView.contentOffset.x/scrollView.frame.size.width;
    UIButton *btn = (UIButton *)[self.btnView viewWithTag:index+10];
    if (_seletedBtn != btn) {
        [UIView animateWithDuration:0.1 animations:^{
            [btn setTitleColor:[UIColor colorWithRed:0.885 green:0.000 blue:0.039 alpha:1.000] forState:UIControlStateNormal];
            [_seletedBtn setTitleColor:[UIColor colorWithRed:0.276 green:0.274 blue:0.277 alpha:1.000] forState:UIControlStateNormal];
            CGFloat x = CGRectGetMinX(btn.frame);
            CGFloat width = CGRectGetWidth(btn.frame);
            self.lineView.frame = CGRectMake(x,self.btnViewHeight-self.btnLineHeight, width,self.btnLineHeight);
        }];
        _seletedBtn = btn;
    }
}


@end
