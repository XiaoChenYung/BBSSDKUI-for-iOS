//
//  BBSUIUserOtherInfoTableHeaderView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserOtherInfoTableHeaderView.h"
#import "UIView+VisualEffects.h"
#import "BBSUIFansViewController.h"
#import "BBSUIUserInfoViewController.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>

#define THEMEBACKGROUNDCOLOR DZSUIColorFromHex(0x6285F6)

@interface BBSUIUserOtherInfoTableHeaderView ()

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *divViewLine;

@property (nonatomic, strong) UIView *horizontalViewLine;

@property (nonatomic, assign) UserType userType;

@property (nonatomic, strong) BBSUser *currentUser;
/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@end

@implementation BBSUIUserOtherInfoTableHeaderView

- (instancetype)init :(UserType)userType{
    if (self = [super init]) {
        [self configUI];
        
        if (userType == UserTypeMe) {
            [self _settingFrame_me];
        }else{
            [self _settingFrame_other];
        }
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame :(UserType)userType{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
        
        if (userType == UserTypeMe) {
            [self _settingFrame_me];
        }else{
            [self _settingFrame_other];
        }
    }
    
    return self;
}

- (void)configUI {
    [self addVisualEffectView];
    
    // 头像
    CGFloat avatarWH = 93;
    
    self.avatarImageView =
    ({
        BBSUIZoomImageView *avatar = [[BBSUIZoomImageView alloc] init];
        avatar.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:avatar];
        avatar.clipsToBounds = YES;
        avatar.layer.cornerRadius = avatarWH/2;
        
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(avatarWH, avatarWH));
            make.centerX.equalTo(self);
            make.top.equalTo(@54);
        }];
        
        avatar;
    });
    
    // 名称
    self.nameLabel =
    ({
        UILabel *name = [UILabel new];
        name.preferredMaxLayoutWidth = 100;
        [name setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        name.textColor = DZSUIColorFromHex(0xFFFFFF);
        name.font = [UIFont systemFontOfSize:20];
        name.textAlignment = NSTextAlignmentCenter;
        [self addSubview:name];
        
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(self.avatarImageView.mas_bottom).offset(10);
            make.height.equalTo(@22);
        }];
        
        name;
    });
    
    // 地址
    self.addressButton =
    ({
        UIButton *address = [UIButton new];
        [address setTintColor:DZSUIColorFromHex(0xFFFFFF)];
        address.titleLabel.font = [UIFont systemFontOfSize:10];
        [address setImage:[UIImage BBSImageNamed:@"/User/Address3.png"] forState:UIControlStateNormal];
        address.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:address];
        
        [address mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(12);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(9);
            make.centerX.equalTo(self);
            make.left.equalTo(@20);
        }];
        
        address;
    });
    
    
    // 个签
    self.originLabel =
    ({
        UILabel *origin = [UILabel new];
        origin.textColor = DZSUIColorFromHex(0xFFFFFF);
        origin.font = [UIFont systemFontOfSize:12];
        origin.alpha = 0.5;
        origin.textAlignment = NSTextAlignmentCenter;
        [self addSubview:origin];
        
        [origin mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(self.addressButton.mas_bottom).offset(14);
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
        }];
        
        origin;
    });
    
    // 关注
    self.noticeButton =
    ({
        NSArray *colorArray = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
        BBSUIButton *notice = [[BBSUIButton alloc] initWithFrame:CGRectMake(0, 0, 92, 26) FromColorArray:colorArray ByGradientType:leftToRight];
        notice.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:notice];
        [notice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(92, 26));
            make.top.mas_equalTo(self.originLabel.mas_bottom).offset(21);
        }];
        notice;
    });
    
    // 关注和粉丝按钮
    self.divViewLine =
    ({
        UIView *viewLine = [UIView new];
        viewLine.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
        [self addSubview:viewLine];
        
        [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@-21);
            make.width.equalTo(@0).priorityHigh();
            make.height.equalTo(@10);
            make.centerX.equalTo(self);
        }];
        viewLine;
    });
    
    self.attentionCountButton =
    ({
        UIButton *attentCount = [UIButton new];
        attentCount.titleLabel.lineBreakMode = 0;
        attentCount.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:attentCount];
        
        [attentCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.originLabel.mas_bottom).offset(77);
            make.height.equalTo(@20);
            make.left.equalTo(@0);
            make.right.mas_equalTo(self.divViewLine.mas_left);
            
        }];
        attentCount;
    });
    
    self.fansCountButton =
    ({
        UIButton *fansCount = [UIButton new];
        fansCount.titleLabel.lineBreakMode = 0;
        fansCount.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:fansCount];
        
        [fansCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.attentionCountButton.mas_top);
            make.right.equalTo(@0);
            make.left.mas_equalTo(self.divViewLine.mas_right);
            make.height.equalTo(self.attentionCountButton.mas_height);
        }];
        fansCount;
    });
    
    
    
//    self.backButton =
//    ({
//        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
//        [back setImage:[UIImage BBSImageNamed:@"/Common/BackButton3@2x.png"] forState:UIControlStateNormal];
//        [back addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
//        [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [self addSubview:back];
//        [back mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(10);
//            make.top.equalTo(self).with.offset(27);
//            make.width.mas_equalTo(@44);
//        }];
//        back;
//    });
}

- (void)backAction:(UIButton *)button {
    [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
}

- (void)_settingFrame_me
{
    _userType = UserTypeMe;
    
    self.nameLabel.textColor = DZSUIColorFromHex(0x2A2B30);
    [self.addressButton setTitleColor:DZSUIColorFromHex(0xACADB8) forState:UIControlStateNormal];
    self.originLabel.textColor = DZSUIColorFromHex(0x4E4F57);
    
    [self.noticeButton setImage:[UIImage BBSImageNamed:@"/User/Edit@2x.png"] forState:UIControlStateNormal];
    [self.noticeButton setTitle:@"编辑资料" forState:UIControlStateNormal];
    [self.noticeButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.noticeButton.layer.borderColor = DZSUIColorFromHex(0x7A94FA).CGColor;
    self.noticeButton.layer.borderWidth = 0.5;
    self.noticeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.noticeButton setTitleColor:DZSUIColorFromHex(0x7A94FA) forState:UIControlStateNormal];
    
    [self.noticeButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_settingFrame_other
{
    _userType = UserTypeOther;
}


- (void)setHeaderWithUser:(BBSUser *)currentUser
{
    _currentUser = currentUser;
    
    self.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
    if (currentUser.avatar) {
        MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
        [getter removeImageObserver:self.verifyImgObserver];
        NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
        self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
            
            if (error) {
                self.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
                [self backgroundImageWithImage:[UIImage BBSImageNamed:@"/User/AvatarDefault3.png"]];
            }else{
                self.avatarImageView.image = image;
                [self backgroundImageWithImage:image];
            }
            
        }];
        
    }
    
    
    self.nameLabel.text = currentUser.userName;
    self.originLabel.text = currentUser.sightml;
    
    if (currentUser.sightml.length == 0)
    {
        self.originLabel.text = @"这家伙很懒";
    }
    
    [self.addressButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",currentUser.resideprovince,currentUser.residecity,currentUser.residedist] forState:UIControlStateNormal];
    
    
    [self.attentionCountButton addTarget:self action:@selector(attenTionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.fansCountButton addTarget:self action:@selector(fansBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.noticeButton addTarget:self action:@selector(noticeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self setCountButtonTitle];
    
    if (_userType == UserTypeMe)
    {
        
    }
    else
    {
        [self settingNoticeButton:[_currentUser.follow integerValue]];
    }
}


- (void)setCountButtonTitle {
    
    UIColor *colorDefault;
    UIColor *colorCount;
    
    NSString *strAttention;
    NSString *strFansCount;
    
    if (self.userType == UserTypeMe) {
        colorDefault = DZSUIColorFromHex(0xACADB8);
        colorCount = DZSUIColorFromHex(0x2A2B30);
        
        strAttention = [NSString stringWithFormat:@"%@\n关注",_currentUser.firends];
        strFansCount = [NSString stringWithFormat:@"%@\n粉丝",_currentUser.followers];
    }else{
        colorDefault = DZSUIColorFromHex(0xFFFFFF);
        colorCount = [UIColor whiteColor];
        
        strAttention = [NSString stringWithFormat:@"%@\n关注",_currentUser.firends];
        strFansCount = [NSString stringWithFormat:@"%@\n粉丝",_currentUser.followers];
    }
    
    [self.attentionCountButton setAttributedTitle:[self stringWithString:strAttention defaultColor:colorDefault countColor:colorCount] forState:UIControlStateNormal];
    
    [self.fansCountButton setAttributedTitle:[self stringWithString:strFansCount defaultColor:colorDefault countColor:colorCount] forState:UIControlStateNormal];
}


- (void)settingNoticeButton:(BOOL)isAttention
{
    if (isAttention)
    {
        [self.noticeButton setTitle:@"已关注" forState:UIControlStateNormal];
        [self.noticeButton setTitleColor:DZSUIColorFromHex(0xFFAA42) forState:UIControlStateNormal];
        [self.noticeButton setBackgroundImage:nil forState:UIControlStateNormal];
        
        [self.noticeButton setImage:[UIImage BBSImageNamed:@"/User/Confirm@2x.png"] forState:UIControlStateNormal];
        self.noticeButton.layer.borderColor = DZSUIColorFromHex(0xFFAA42).CGColor;
        self.noticeButton.layer.borderWidth = 0.5;
    }
    else
    {
        NSArray *colroArray = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
        [self.noticeButton displayButtonImageFromColors:colroArray ByGradientType:leftToRight];
        [self.noticeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.noticeButton setTitle:@"关注TA" forState:UIControlStateNormal];
        [self.noticeButton setImage:nil forState:UIControlStateNormal];
    }
}

- (NSMutableAttributedString *)stringWithString:(NSString *)string defaultColor:(UIColor *)defaultColor countColor:(UIColor *)countColor
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:countColor,NSFontAttributeName:[UIFont systemFontOfSize:20]} range:NSMakeRange(0, string.length - 2)];
    [attr addAttributes:@{NSForegroundColorAttributeName:defaultColor,NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(string.length - 2, 2)];
    
    return attr;
}

- (void)nextAction:(UIButton *)button
{
    
    BBSUIUserInfoViewController *vc = [BBSUIUserInfoViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    
}

- (void)noticeBtnAction {
    __weak typeof (self) weakSelf = self;
    
    if ([_currentUser.follow integerValue] == 0) {
        [BBSSDK followWithFollowuid:[_currentUser.uid integerValue] result:^(NSError *error) {
            if (! error) {
                NSLog(@"关注成功！");
                [weakSelf settingNoticeButton:YES];
                _currentUser.follow = @(1);
            }
        }];
    }
    else{
        [BBSSDK unfollowWithFollowuid:[_currentUser.uid integerValue] result:^(NSError *error) {
            if (! error) {
                NSLog(@"取消关注成功");
                [weakSelf settingNoticeButton:NO];
                _currentUser.follow = @(0);
            }
        }];
    }
}

- (void)attenTionBtnAction {
    BBSUIFansViewController *vc = [BBSUIFansViewController new];
    if (_userType == UserTypeMe) {
        vc.fansViewType = BBSUIFansTypeFirendsMe;
    }else{
        vc.fansViewType = BBSUIFansTypeFirendsOther;
        vc.currentUser = _currentUser;
    }
    
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)fansBtnAction {
    BBSUIFansViewController *vc = [BBSUIFansViewController new];
    if (_userType == UserTypeMe) {
        vc.fansViewType = BBSUIFansTypeFollowersMe;
    }else{
        vc.fansViewType = BBSUIFansTypeFollowersOther;
        vc.currentUser = _currentUser;
    }
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}
@end
