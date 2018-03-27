//
//  BBSUIUserOtherInfoView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIZoomImageView.h"

typedef NS_ENUM(NSInteger, UserType){
    UserTypeMe      = 0,
    UserTypeOther   = 1
};


/**
 个人信息、他人信息 view
 */
@interface BBSUIUserOtherInfoView : BBSUIBaseView

@property (nonatomic, strong) BBSUser *user;

- (instancetype)init:(UserType)userType;

- (instancetype)initWithFrame:(CGRect)frame :(UserType)userType;

- (void)refreshData:(void(^)(NSInteger))informationCount;

/**
 查看他人帖子时候传递
 */
@property (nonatomic, assign) NSInteger authorid;
@end


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
@property (nonatomic, strong) UIButton *noticeButton;

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

@end
