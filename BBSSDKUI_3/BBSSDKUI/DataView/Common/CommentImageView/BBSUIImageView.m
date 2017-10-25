//
//  BBSUIImageView.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIImageView.h"
#import "Masonry.h"

@interface BBSUIImageView()

@property(nonatomic, copy) void (^result)();

@end

@implementation BBSUIImageView

+ (instancetype)viewWithImage:(UIImage *)image
{
    BBSUIImageView *imageView = [[BBSUIImageView alloc] initWithImage:image];
    return imageView ;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _image = image ;
        [self configUI];
    }
    return self ;
}


- (void)configUI
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    imageView.layer.cornerRadius = 12;
    imageView.layer.masksToBounds = YES;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage BBSImageNamed:@"/Common/delete.png"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(didDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-7);
        make.right.equalTo(self).offset(-7);
        make.width.height.equalTo(@23);
    }];
}

- (void)didDelete:(UIButton *)sender
{
    [self removeFromSuperview];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didDeleted:)])
    {
        [_delegate didDeleted:self];
    }
}

@end
