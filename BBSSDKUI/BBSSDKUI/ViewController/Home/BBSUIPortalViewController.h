//
//  BBSUIPortalViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2018/1/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"

@interface BBSUIPortalViewController : BBSUIBaseViewController

@property (nonatomic, copy) void (^offSetBlock)(CGFloat offset);

@end
