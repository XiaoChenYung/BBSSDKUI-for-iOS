//
//  BBSUIThreadAuthorInfoView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadAuthorInfoView.h"
#import "Masonry.h"

@interface BBSUIThreadAuthorInfoView ()

/**
 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 作者
 */
@property (nonatomic, strong) UILabel *authorLabel;

/**
 创建时间
 */
@property (nonatomic, strong) UILabel *createdOnLabel;

/**
 回复
 */
@property (nonatomic, strong) UIImageView *repliesImageView;

/**
 回复数
 */
@property (nonatomic, strong) UILabel *repliesLabel;


@end

@implementation BBSUIThreadAuthorInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
        [self setViewAutoLaytout];
    }
    
    return self;
}

#pragma mark - private
- (void)configureUI
{
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.layer.cornerRadius = 20.0;
    self.avatarImageView.layer.masksToBounds = YES;
    [self addSubview:_avatarImageView];
    
    self.authorLabel = [UILabel new];
    [self addSubview:_authorLabel];
    
    self.createdOnLabel = [UILabel new];
    [self addSubview:_createdOnLabel];
    
    self.repliesImageView = [UIImageView new];
    [self addSubview:_repliesImageView];
    
    self.repliesLabel = [UILabel new];
    [self addSubview:_repliesLabel];

}

- (void)setViewAutoLaytout
{
    //头像
//    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        /**
//         *  相对于self而言，距离顶部是10像素
//         */
//        make.top.equalTo(@10);
//        
//        /**
//         *  相对于self而言，距离左边是0像素
//         */
//        make.left.equalTo(@0);
//        
//        /**
//         *  相对于self而言，高度是40像素
//         */
//        make.height.equalTo(@40);
//        
//        /**
//         *  相对于self而言，宽度是40像素
//         */
//        make.width.equalTo(@40);
//        /**
//         *  相对于self而言，距离底部是-10像素 ！！！在这里注意，这里是以self的底部而言，往上走10个像素。因为基于y轴，所以它是要写出-10个像素
//         */
//        make.bottom.equalTo(@(-10));
//    }];
//    
//    //昵称
//    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.top.equalTo(@10);
//        /**
//         *  相对avatarImageView的最右边来说，距离iconImageView的最右边是10个像素
//         */
//        make.left.equalTo(self.avatarImageView.mas_right).with.offset(10);
//        make.bottom.equalTo(@(-10));
//    }];
//    
//    [self.createdOnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@10);
//        make.left.equalTo(self.authorLabel.mas_right).with.offset(10);
//        make.bottom.equalTo(@(-10));
//    }];
}

- (void)setThreadModel:(BBSThread *)threadModel
{
    _threadModel = threadModel;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self.authorLabel setText:_threadModel.author];
}

@end
