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

#define BBSUIForumImageViewHeight 42

@interface BBSUIForumSummaryCellTableViewCell ()

@property (nonatomic, strong) UIImageView                   *forumImageView;
@property (nonatomic, strong) UILabel                       *forumNameLabel;
@property (nonatomic, strong) UILabel                       *forumDesLabel;
@property (nonatomic, strong) BBSUIContentInsetsLabel       *todayUpdateLabel;


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
    [self.forumImageView.layer setCornerRadius:5];
    [self.forumImageView.layer setMasksToBounds:YES];
//    [self.forumImageView sd_setImageWithURL:nil placeholderImage:[UIImage BBSImageNamed:@"Home/wutu@2x.png"]];
    
    self.forumNameLabel = [UILabel new];
    [self.contentView addSubview:self.forumNameLabel];
    [self.forumNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumImageView.mas_right).with.offset(10);
        make.right.equalTo(self).with.offset(-100);
        make.top.equalTo(self).with.offset(12);
//        make.height.mas_equalTo(20);
    }];
    [self.forumNameLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [self.forumNameLabel setTextColor:DZSUIColorFromHex(0x2D3037)];
    
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
//    self.todayUpdateLabel.contentInsets = UIEdgeInsetsMake(2, 5, 0, 0.f); // 设置左内边距
    [self.todayUpdateLabel setHidden:YES];
    
    self.stickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.stickButton];
    [self.stickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(@25);
    }];
    [self.stickButton.layer setBorderWidth:0.5];
    [self.stickButton.layer setBorderColor:DZSUIColorFromHex(0x50A3D3).CGColor];
    [self.stickButton.layer setCornerRadius:5];
    [self.stickButton setTitle:@"置顶" forState:UIControlStateNormal];
    [self.stickButton setTitleColor:DZSUIColorFromHex(0x50A3D3) forState:UIControlStateNormal];
    [self.stickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.stickButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [self.stickButton addTarget:self action:@selector(stickButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    self.forumDesLabel = [UILabel new];
    [self.contentView addSubview:self.forumDesLabel];
    [self.forumDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.forumImageView.mas_bottom);
        make.left.mas_equalTo(self.forumNameLabel.mas_left);
//        make.right.mas_equalTo(self.stickButton.mas_left).with.offset(-10);
    }];
    [self.forumDesLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [self.forumDesLabel setTextColor:DZSUIColorFromHex(0xABAFBA)];
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
        self.forumImageView.image = [UIImage BBSImageNamed:@"/Common/forumList.png"];
        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:forum.forumPic] result:^(UIImage *image, NSError *error) {
            
            if (image) {
                self.forumImageView.image = image;
            }else{
                if (forum.fid == 0) {
                    [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Forum/All.png"]];
                }else{
                    [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Common/forumList.png"]];
                }
            }
        }];
        
    }else{
        if (forum.fid == 0) {
            [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Forum/All.png"]];
        }else{
            [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Common/forumList.png"]];
        }
        
    }
    [self.forumNameLabel setText:forum.name];
    if (forum.forumDescription && ![forum.forumDescription isEqualToString:@""]) {
        [self.forumDesLabel setText:[[self strToAttriWithStr:forum.forumDescription] string]];
    }else{
        [self.forumDesLabel setText:@"版主很懒，什么也没说"];
    }
    
    [self.todayUpdateLabel setText:@" 今日:0 "];
    
    [self changeButtonStatus];
    
//    for (BBSForum *stickForum in self.stickForumArray) {
//        if (forum.fid == stickForum.fid) {
//            forum.isSticked = stickForum.isSticked;
//            [self changeButtonStatus];
//            break;
//        }
//    }
}

- (NSAttributedString *)strToAttriWithStr:(NSString *)htmlStr{
    return [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                 documentAttributes:nil
                                              error:nil];
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        
        html = [html stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];
    }
    return html;
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
        [self.stickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.stickButton setBackgroundColor:DZSUIColorFromHex(0xABAFBA)];
        [self.stickButton.layer setBorderWidth:0];
        [self.stickButton setContentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
        
    }else{
        
        [self.stickButton.layer setBorderWidth:0.5];
        [self.stickButton.layer setBorderColor:DZSUIColorFromHex(0x5B7EF0).CGColor];
        [self.stickButton.layer setCornerRadius:5];
        [self.stickButton setTitle:@"置顶" forState:UIControlStateNormal];
        [self.stickButton setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
        [self.stickButton setContentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
        [self.stickButton setBackgroundColor:[UIColor clearColor]];

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