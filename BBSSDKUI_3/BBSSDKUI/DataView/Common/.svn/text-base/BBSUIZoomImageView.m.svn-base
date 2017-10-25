//
//  BBSUIZoomImageView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIZoomImageView.h"

@interface BBSUIZoomImageView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *picView;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@end
@implementation BBSUIZoomImageView

- (instancetype)init{
    if (self = [super init]) {
        [self config];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self config];
    }
    
    return self;
}

- (void)config {
    self.userInteractionEnabled = YES;
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomImageView:)];
    
    [self addGestureRecognizer:tap];
}

-(void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    imageView.frame = [bgView convertRect:picView.frame fromView:self];
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 1.5;
    self.scrollView.delegate = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.5 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}

//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}


@end
