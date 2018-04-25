//
//  BBSUIForumSummaryCellTableViewCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/24.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumSummaryCellTableViewCell.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"
#import <BBSSDK/BBSForum.h>
#import "BBSForum+BBSUI.h"
#import "BBSUIProcessHUD.h"
#import "BBSUIContentInsetsLabel.h"
#import "NSString+BBSUIParagraph.h"

#define BBSUIForumImageViewHeight 50

@interface BBSUIForumSummaryCellTableViewCell ()

@property (nonatomic, strong) UIImageView                   *forumImageView;
@property (nonatomic, strong) UILabel                       *forumNameLabel;
@property (nonatomic, strong) UILabel                       *forumDesLabel;
@property (nonatomic, strong) BBSUIContentInsetsLabel       *todayUpdateLabel;
@property (nonatomic, strong) UILabel *forumCountLab;

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
#pragma mark - initUI
- (void)configureUI
{
    self.forumImageView = [UIImageView new];
    [self.contentView addSubview:self.forumImageView];
    [self.forumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(BBSUIForumImageViewHeight, BBSUIForumImageViewHeight));
    }];
    [self.forumImageView.layer setCornerRadius:25];
    [self.forumImageView.layer setMasksToBounds:YES];
    
    //MARK:名字29292F
    
    self.forumNameLabel = [UILabel new];
    [self.contentView addSubview:self.forumNameLabel];
    [self.forumNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumImageView.mas_right).with.offset(10);
        
        make.top.equalTo(self).with.offset(12);
        //make.size.mas_equalTo(CGSizeMake(70, 15));
    }];
    [self.forumNameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    self.forumNameLabel.textColor = DZSUIColorFromHex(0x29292F);
    //self.forumNameLabel.adjustsFontSizeToFitWidth = YES;
    
    //版块统计数字
    self.forumCountLab = [UILabel new];
    [self.contentView addSubview:self.forumCountLab];
    [self.forumCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumNameLabel.mas_right).with.offset(7);
        make.centerY.mas_equalTo(self.forumNameLabel);
        
    }];
    [self.forumCountLab setFont:[UIFont boldSystemFontOfSize:10.0f]];
    [self.forumCountLab setTextColor:DZSUIColorFromHex(0xffffff)];
    self.forumCountLab.backgroundColor = DZSUIColorFromHex(0xFFAA42);
    self.forumCountLab.text = @"今日: 22";
    
    //今日更新
    self.todayUpdateLabel = [BBSUIContentInsetsLabel new];
    [self.contentView addSubview:self.todayUpdateLabel];
    [self.todayUpdateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumNameLabel.mas_right).with.offset(5);
        make.centerY.mas_equalTo(self.forumNameLabel.mas_centerY);
        make.height.mas_equalTo(@15);
    }];
    [self.todayUpdateLabel.layer setCornerRadius:3.0f];
    [self.todayUpdateLabel.layer setMasksToBounds:YES];
    [self.todayUpdateLabel setBackgroundColor:DZSUIColorFromHex(0xF2F4F7)];
    [self.todayUpdateLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
    [self.todayUpdateLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.todayUpdateLabel setHidden:YES];
    
    //置顶DDE1EB
    self.stickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.stickButton];
    [self.stickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        //make.height.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(85, 27));
    }];

    [self.stickButton.layer setBorderWidth:0.5];
    [self.stickButton.layer setBorderColor:DZSUIColorFromHex(0x50A3D3).CGColor];
    [self.stickButton.layer setCornerRadius:5];
    [self.stickButton setTitle:@"置顶" forState:UIControlStateNormal];
    [self.stickButton setTitleColor:DZSUIColorFromHex(0x50A3D3) forState:UIControlStateNormal];
    [self.stickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.stickButton addTarget:self action:@selector(stickButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    //描述
    self.forumDesLabel = [UILabel new];
    [self.contentView addSubview:self.forumDesLabel];
    [self.forumDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.mas_equalTo(self.forumImageView.mas_bottom);
        //make.left.equalTo(self.forumNameLabel.mas_right).with.offset(5);
        make.top.equalTo(self.forumNameLabel.mas_bottom).with.offset(3);
        make.left.mas_equalTo(self.forumNameLabel.mas_left);
    }];
    [self.forumDesLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.forumDesLabel setTextColor:DZSUIColorFromHex(0x9A9CAA)];
    //    [self.forumDesLabel setHidden:YES];
    
    self.seperateView = [UIView new];
    [self.contentView addSubview:self.seperateView];
    [self.seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumDesLabel.mas_left);
        make.right.equalTo(self.contentView).with.offset(0);
        make.bottom.equalTo(self.contentView).with.offset(-0.5);
        make.height.mas_equalTo(@0.5);
    }];
    [self.seperateView setBackgroundColor:DZSUIColorFromHex(0xD8D8D8)];
    self.seperateView.hidden = YES;
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
    if (forum.forumPic) {
        self.forumImageView.image = [UIImage BBSImageNamed:@"/Forum/forumList3.png"];
        
        __weak typeof (self) weakSelf = self;
        
        if (forum.forumPic && forum.forumPic.length)
        {
            [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:forum.forumPic] result:^(UIImage *image, NSError *error) {
                if (!error && image)
                {
                    weakSelf.forumImageView.image = image;
                }
                else
                {
                    weakSelf.forumImageView.image = [UIImage BBSImageNamed:@"/Forum/forumList3.png"];
                }
                
            }];
        }
        
    }else{
        if (forum.fid == 0) {
            [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Forum/AllFroum.png"]];
        }else{
            [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Forum/forumList3.png"]];
        }
        
    }
    CGSize size = [self getAttributeSizeWithText:forum.name fontSize:16];
    [self.forumNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumImageView.mas_right).with.offset(10);
        
        make.top.equalTo(self).with.offset(12);
        make.size.mas_equalTo(CGSizeMake(size.width+5, size.height));
    }];
    
    [self.forumNameLabel setText:forum.name];
    
    if (forum.forumDescription && ![forum.forumDescription isEqualToString:@""]) {
        
        self.forumDesLabel.attributedText = [NSString bbs_stringWithString:forum.forumDescription fontSize:10 defaultColorValue:@"ACADB8" lineSpace:0 wordSpace:0];
        
    }else{
        [self.forumDesLabel setText:@"版主很懒，什么也没说"];
    }
    
    if (forum.fid == 0)
    {
        self.forumDesLabel.text = @"";
    }
    
    [self.todayUpdateLabel setText:@" 今日:0 "];
    self.forumCountLab.text = [NSString stringWithFormat:@" 今日:%ld", forum.todayposts];
    
    if (self.isShowcount) {
        self.forumCountLab.hidden = YES;
    }else {
        self.forumCountLab.hidden = NO;
    }
    
    [self changeButtonStatus];
    
}

- (CGSize)getAttributeSizeWithText:(NSString *)text fontSize:(int)fontSize
{
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    NSAttributedString *attributeSting = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    size = [attributeSting size];
    return size;
}

- (void)stickButtonHandler:(UIButton *)stickButton
{
    //不是置顶状态，判断是否超过8个
    if (!self.forumModel.isSticked) {
        if (self.stickForumArray.count >= 8) {
            
            [BBSUIProcessHUD showFailInfo:@"最多置顶8个版块喔~" delay:3];
            
            return;
        }
        [self.stickForumArray addObject:self.forumModel];
        
    }else{
        for (int i = 0; i < self.stickForumArray.count; i++) {
            BBSForum *stickForum = self.stickForumArray[i];
            if (stickForum.fid == self.forumModel.fid) {
                [self.stickForumArray removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    self.forumModel.isSticked = !self.forumModel.isSticked;
    [self changeButtonStatus];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickChanged:)]) {
        [self.delegate stickChanged:self];
    }
    
}

- (void)changeButtonStatus
{
    if (self.forumModel.isSticked) {
        
        [self.stickButton setTitle:@"取消置顶" forState:UIControlStateNormal];
        [self.stickButton setTitleColor:DZSUIColorFromHex(0xFF9B4E) forState:UIControlStateNormal];
        [self.stickButton setBackgroundColor:[UIColor whiteColor]];
        [self.stickButton.layer setBorderWidth:0.5];
        [self.stickButton.layer setBorderColor:DZSUIColorFromHex(0xFF9B4E).CGColor];
        [self.stickButton setContentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
        
    }else{
        [self.stickButton setTitle:@"置顶" forState:UIControlStateNormal];
        [self.stickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.stickButton setContentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
        [self.stickButton setBackgroundColor:DZSUIColorFromHex(0xFEAF5D)];
        [self.stickButton.layer setBorderColor:[UIColor clearColor].CGColor];

    }
}

- (void)updateUIConstraints
{
    if (self.forumModel.isSticked) {
        [self.forumDesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).with.offset(-95);
        }];
    }else{
        [self.forumDesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).with.offset(-70);
        }];
    }
}

- (void)setStickButtonHidden:(BOOL)hidden
{
    [self.stickButton setHidden:hidden];
    
    if (hidden) {
        [self.forumDesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).with.offset(-10);
        }];
    }else{
        [self updateUIConstraints];
    }
}

@end
