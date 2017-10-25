//
//  BBSUIForumSummaryCellTableViewCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/24.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumSummaryCellTableViewCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "UIImage+BBSFunction.h"
#import <BBSSDK/BBSForum.h>

#define BBSUIForumImageViewHeight 40

@interface BBSUIForumSummaryCellTableViewCell ()

@property (nonatomic, strong) UIImageView   *forumImageView;
@property (nonatomic, strong) UILabel       *forumNameLabel;
@property (nonatomic, strong) UILabel       *forumDesLabel;
@property (nonatomic, strong) UILabel       *todayUpdateLabel;
@property (nonatomic, strong) UIButton      *stickButton;

@end

@implementation BBSUIForumSummaryCellTableViewCell

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
    self.forumImageView = [UIImageView new];
    [self.contentView addSubview:self.forumImageView];
    [self.forumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(BBSUIForumImageViewHeight, BBSUIForumImageViewHeight));
    }];
    [self.forumImageView.layer setCornerRadius:10];
    [self.forumImageView.layer setMasksToBounds:YES];
//    [self.forumImageView sd_setImageWithURL:nil placeholderImage:[UIImage BBSImageNamed:@"Home/wutu@2x.png"]];
    
    self.forumNameLabel = [UILabel new];
    [self.contentView addSubview:self.forumNameLabel];
    [self.forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumImageView.mas_right).with.offset(10);
        make.top.equalTo(self).with.offset(14);
//        make.height.mas_equalTo(20);
    }];
    [self.forumNameLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [self.forumNameLabel setTextColor:DZSUIColorFromHex(0x3A4045)];

    
    self.forumDesLabel = [UILabel new];
    [self.contentView addSubview:self.forumDesLabel];
    [self.forumDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.forumImageView.mas_bottom);
        make.left.mas_equalTo(self.forumNameLabel.mas_left);
    }];
    [self.forumDesLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.forumDesLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
}

- (void)setForumModel:(BBSForum *)forumModel
{
    _forumModel = forumModel;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutData:_forumModel];
}

- (void)layoutData:(BBSForum *)forum
{
    [self.forumImageView setImage:[UIImage BBSImageNamed:@"Home/wutu@2x.png"]];
    [self.forumNameLabel setText:forum.name];
//    [self.forumDesLabel setText:forum.forumDescription];
    [self.forumDesLabel setText:@"果粉狂欢年正式启动"];
}



@end
