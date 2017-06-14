//
//  BBSUIEmailSendView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

typedef NS_ENUM(NSInteger, BBSUIEmailSendType)
{
    BBSUIEmailSendTypeNeedIdentity,
    BBSUIEmailSendTypeRetrievePassword,
    BBSUIEmailSendTypeRegister
};

@interface BBSUIEmailSendView : BBSUIBaseView

- (instancetype)initWithFrame:(CGRect)frame email:(NSString *)email userName:(NSString *)userName sendType:(BBSUIEmailSendType)sendType;

@end
