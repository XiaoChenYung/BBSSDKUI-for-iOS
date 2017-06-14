//
//  BBSUIUserEditViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/19.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import "BBSUIUserEditView.h"
#import <BBSSDK/BBSUser.h>

@interface BBSUIUserEditViewController : BBSUIBackViewController

- (instancetype)initWithUser:(BBSUser *)user editType:(BBSUIEditUserInfoType)type;

@end
