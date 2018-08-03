//
//  BBSUIUserInfoTableViewCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserInfoTableViewCell.h"
#import "Masonry.h"

@interface BBSUIUserInfoTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BBSUIUserInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI
{
    self.titleLabel = [UILabel new];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    [self.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.titleLabel setTextColor:DZSUIColorFromHex(0x8C8C8C)];
    
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}

@end
