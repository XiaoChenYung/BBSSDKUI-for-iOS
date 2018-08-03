//
//  BBSUIUserEditView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/19.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSUser.h>

typedef NS_ENUM(NSInteger, BBSUIEditUserInfoType)
{
    BBSUIEditUserInfoTypeRegister,
    BBSUIEditUserInfoTypeEdit
};

@interface BBSUIUserEditView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame user:(BBSUser *)currentUser editType:(BBSUIEditUserInfoType)type;

@end
