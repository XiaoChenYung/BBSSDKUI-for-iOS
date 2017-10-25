//
//  BBSUIAccusationTableViewCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/29.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIAccusationTableViewCell.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIAccusationTableViewCell ()

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation BBSUIAccusationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureUI
{
    self.selectImageView = [UIImageView new];
    [self.contentView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    [self.selectImageView setImage:[UIImage BBSImageNamed:@"/Thread/AccusationDeselected.png"]];
    
    self.messageLabel = [UILabel new];
    [self.contentView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectImageView.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    [self.messageLabel setFont:[UIFont systemFontOfSize:15]];
    [self.messageLabel setTextColor:DZSUIColorFromHex(0x4E4F57)];
}

- (void)setAccusationMessage:(NSString *)accusationMessage selected:(BOOL)selected
{
    [self.messageLabel setText:accusationMessage];
    
    if (selected) {
        [self.selectImageView setImage:[UIImage BBSImageNamed:@"/Thread/AccusationSelected.png"]];
    }else{
        [self.selectImageView setImage:[UIImage BBSImageNamed:@"/Thread/AccusationDeselected.png"]];
    }
}

@end
