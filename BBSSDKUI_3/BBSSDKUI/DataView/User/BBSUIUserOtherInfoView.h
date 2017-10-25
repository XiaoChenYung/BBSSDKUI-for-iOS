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
#import "BBSUIButton.h"

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


