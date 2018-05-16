//
//  BBSUIThreadDetailViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIWebViewController.h"
@class BBSThread;

@interface BBSUIThreadDetailViewController : BBSUIWebViewController

- (instancetype)initWithThreadModel:(BBSThread *)model;

- (instancetype)initWithFid:(NSInteger)fid tid:(NSInteger)tid;



@end
