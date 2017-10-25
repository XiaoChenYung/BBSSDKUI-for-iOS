//
//  BBSUIUserOtherInfoTableHeaderView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIZoomImageView.h"
#import "BBSUIButton.h"
#import "BBSUIUserOtherInfoView.h"

/**
 个人信息、他人信息 tableviewHeader
 */
@interface BBSUIUserOtherInfoTableHeaderView : BBSUIBaseView

/**
 头像
 */
@property (nonatomic, strong) BBSUIZoomImageView *avatarImageView;

/**
 名称
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 个性签名
 */
@property (nonatomic, strong) UILabel *originLabel;

/**
 地址
 */
@property (nonatomic, strong) UIButton *addressButton;

/**
 关注按钮
 */
@property (nonatomic, strong) BBSUIButton *noticeButton;

/**
 关注数量
 */
@property (nonatomic, strong) UIButton *attentionCountButton;

/**
 粉丝数量
 */
@property (nonatomic, strong) UIButton *fansCountButton;

- (instancetype)init:(UserType)userType;

- (instancetype)initWithFrame:(CGRect)frame :(UserType)userType;

- (void)setHeaderWithUser:(BBSUser *)currentUser;

- (void)settingNoticeButton:(BOOL)isAttention;

@end
