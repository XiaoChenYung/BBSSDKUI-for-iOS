//
//  BBSUIFansTableViewCell.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIFansTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSFans.h>

@interface BBSUIFansTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;
@end

@implementation BBSUIFansTableViewCell

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
    
    // icon
    CGFloat iconHW = 40;
    
    self.avatarImageView = [UIImageView new];
    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.width.height.mas_equalTo(iconHW);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    self.avatarImageView.layer.cornerRadius = iconHW / 2;
    self.avatarImageView.layer.masksToBounds = YES;

    // name
    self.nameLabel = [UILabel new];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).offset(15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@20);
    }];
    [self.nameLabel setFont:[UIFont systemFontOfSize:14]];
    [self.nameLabel setTextColor:DZSUIColorFromHex(0x2D3037)];
    
    // attention
    self.attentionButton = [UIButton new];
    [self.contentView addSubview:self.attentionButton];
    [self.attentionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
}


- (void)setFans:(BBSFans *)fans{
    
    self.avatarImageView.image = [UIImage BBSImageNamed:@"/Common/defaultHeadImg.jpg"];
    self.nameLabel.text = fans.userName;
    [self.attentionButton setImage:[UIImage BBSImageNamed:@"/User/CancelAttention.png"] forState:UIControlStateNormal];
    
    if (fans.avatar) {
        MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
        [getter removeImageObserver:self.verifyImgObserver];
        NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", fans.avatar,[[NSDate date] timeIntervalSince1970]];
        self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
            
            if (error) {
                self.avatarImageView.image = [UIImage BBSImageNamed:@"/Common/defaultHeadImg.jpg"];
            }else{
                self.avatarImageView.image = image;
            }
        }];
        
    }
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}

@end
