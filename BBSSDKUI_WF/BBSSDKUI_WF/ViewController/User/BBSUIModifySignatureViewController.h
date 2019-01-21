//
//  BBSUIModifySignatureViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/27.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"

/**
 修改个性签名
 */
@interface BBSUIModifySignatureViewController : BBSUIBaseViewController

@property (nonatomic, copy) void(^SightmlBlock)(NSString *sightml);

@end
