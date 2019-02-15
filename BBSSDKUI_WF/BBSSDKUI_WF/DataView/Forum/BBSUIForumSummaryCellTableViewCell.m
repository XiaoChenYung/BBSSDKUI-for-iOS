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
    self.forumImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.forumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(12);
        make.size.mas_equalTo(CGSizeMake(BBSUIForumImageViewHeight, BBSUIForumImageViewHeight));
    }];


    //MARK:名字29292F
    self.forumNameLabel = [UILabel new];
    [self.contentView addSubview:self.forumNameLabel];
    [self.forumNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forumImageView.mas_right).mas_offset(10);
        make.top.equalTo(self.contentView).mas_offset(12);
        make.height.mas_equalTo(20);
        //make.size.mas_equalTo(CGSizeMake(70, 15));
    }];
    [self.forumNameLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    self.forumNameLabel.textColor = DZSUIColorFromHex(0x3E3E3E);
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
    self.forumCountLab.backgroundColor = DZSUIColorFromHex(0x6D96FF);
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
        make.size.mas_equalTo(CGSizeMake(71, 25));
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
    self.forumDesLabel.numberOfLines = 0;
    self.forumDesLabel.preferredMaxLayoutWidth = DZSUIScreen_width - 84;
    [self.forumDesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.forumDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forumNameLabel.mas_bottom).mas_offset(6);
//        make.bottom.equalTo(self.contentView).mas_offset(-12);
//        make.height.mas_equalTo(20);
        make.left.equalTo(self.forumNameLabel);
        make.right.equalTo(self.contentView).mas_offset(-12);
    }];
    [self.forumDesLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.forumDesLabel setTextColor:DZSUIColorFromHex(0x9A9CAA)];
    //[self.forumDesLabel setHidden:YES];
    
    self.seperateView = [UIView new];
    [self.contentView addSubview:self.seperateView];
    [self.seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forumDesLabel.mas_bottom).mas_offset(12);
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
    [self layoutData:_forumModel];
//    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutData:_forumModel];
}

#pragma mark - 加载数据
- (void)layoutData:(BBSForum *)forum
{
    if (!self.isCube) {
        [self.forumImageView.layer setCornerRadius:25];
        [self.forumImageView.layer setMasksToBounds:YES];
        [self.forumImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(BBSUIForumImageViewHeight, BBSUIForumImageViewHeight));
        }];
    } else {
        [self.forumImageView.layer setCornerRadius:0];
        [self.forumImageView.layer setMasksToBounds:true];
        [self.forumImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, BBSUIForumImageViewHeight));
        }];
    }
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
        NSLog(@"详情:%@", [[self strToAttriWithStr:forum.forumDescription] string]);
    }else{
        [self.forumDesLabel setText:@"版主很懒，什么也没说"];
    }
//    CGFloat height = [[[self strToAttriWithStr:forum.forumDescription] string] boundingRectWithSize:CGSizeMake(DZSUIScreen_width - 84, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.forumDesLabel.font} context:nil].size.height;
//    [self.forumDesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(height + 6);
//    }];
//    [self.forumDesLabel setNeedsLayout];
//    [self.forumDesLabel layoutIfNeeded];
//    [self.forumDesLabel sizeToFit];
    [self.todayUpdateLabel setText:@" 今日:0 "];
    self.forumCountLab.text = [NSString stringWithFormat:@" 今日:%ld", forum.todayposts];
    if (forum.todayposts > 0) {
        self.forumCountLab.hidden = NO;
    }else {
        self.forumCountLab.hidden = YES;
    }
    
    [self changeButtonStatus];
    [self.contentView layoutIfNeeded];
}

- (void) hiddForumCountLabel
{
     self.forumCountLab.hidden = YES;
}

- (NSAttributedString *)strToAttriWithStr:(NSString *)htmlStr{
    return [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                 documentAttributes:nil
                                              error:nil];
}

- (NSString *)filterHTML:(NSString *)html
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

#pragma mark - 事件处理
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
        [self.stickButton setBackgroundColor:DZSUIColorFromHex(0xDDE1EB)];
        [self.stickButton.layer setBorderWidth:0];
        
    }else{

        [self.stickButton.layer setBorderWidth:0.5];
        [self.stickButton.layer setBorderColor:DZSUIColorFromHex(0x5B7EF0).CGColor];
        [self.stickButton.layer setCornerRadius:5];
        [self.stickButton setTitle:@"置顶" forState:UIControlStateNormal];
        [self.stickButton setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
        [self.stickButton setBackgroundColor:[UIColor clearColor]];
        [self.stickButton setBackgroundColor:DZSUIColorFromHex(0xFFFFFF)];
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
