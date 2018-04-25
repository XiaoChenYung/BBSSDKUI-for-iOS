//
//  BBSUIEmailSendViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIDarkBlueViewController.h"
#import "BBSUIEmailSendView.h"
#import "BBSUIWhiteNavViewController.h"

@interface BBSUIEmailSendViewController : BBSUIWhiteNavViewController

- (instancetype)initWithEmail:(NSString *)email userName:(NSString *)userName sendType:(BBSUIEmailSendType)sendType;

@end
