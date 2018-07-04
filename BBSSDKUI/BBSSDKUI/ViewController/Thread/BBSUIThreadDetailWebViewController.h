//
//  BBSUIThreadDetailWebViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIWebViewController.h"
#import <BBSSDK/BBSThread.h>

@interface BBSUIThreadDetailWebViewController : BBSUIWebViewController

- (instancetype)initWithThreadModel:(BBSThread *)model;

@end
