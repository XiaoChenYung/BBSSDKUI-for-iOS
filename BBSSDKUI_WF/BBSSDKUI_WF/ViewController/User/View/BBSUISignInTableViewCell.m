//
//  BBSUISignInTableViewCell.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/3.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUISignInTableViewCell.h"

@interface BBSUISignInTableViewCell()

/**
 头像
 */
@property (nonatomic, strong)UIImageView *headeImageView;

/**
 名字
 */
@property (nonatomic, strong)UILabel *nameLab;

/**
 时间
 */
@property (nonatomic, strong) UILabel *timeLab;

@end

@implementation BBSUISignInTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self _initViews];
    }
    return self;
}

#pragma mark - UI
- (void)_initViews
{
    //头像
    UIImageView *headeImageView  = [UIImageView new];
    [self.contentView addSubview:headeImageView];
    [headeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(11);
        make.size.mas_offset(CGSizeMake(42, 42));
    }];

    headeImageView.image = [UIImage BBSImageNamed:@"User/Camera.png"];
    headeImageView.layer.cornerRadius = 21/2;
    headeImageView.layer.masksToBounds = YES;
    
    //名字
    UILabel *nameLab = [UILabel new];
    [self.contentView addSubview:nameLab];
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headeImageView.mas_right).offset(8);
        make.centerY.equalTo(headeImageView);
    }];
    nameLab.textColor = DZSUIColorFromHex(0x29292F);
    nameLab.font = BBSFont(15);
    nameLab.text = @"金城武";
    
    //签到
    UILabel *timeLab = [UILabel new];
    [self.contentView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(nameLab);
        make.right.mas_equalTo(-5);
    }];
    timeLab.textColor = DZSUIColorFromHex(0x9A9CAA);
    timeLab.font = BBSFont(10);
    timeLab.text = @"10:00签到";
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
