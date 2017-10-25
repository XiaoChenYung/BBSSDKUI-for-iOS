//
//  BBSUIFansView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/12.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
@class BBSUser;

typedef NS_ENUM(NSInteger, BBSUIFansType){
    BBSUIFansTypeFirendsMe,         // 我的关注
    BBSUIFansTypeFollowersMe,       // 我的粉丝
    BBSUIFansTypeFirendsOther,      // 别人的的关注
    BBSUIFansTypeFollowersOther,    // 别人的的粉丝
};
@interface BBSUIFansView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame tpye:(BBSUIFansType)type currentUser:(BBSUser *)currentUser;

- (void)refreshData;

@end
