//
//  BBSUIPortalDetailViewController.h
//  BBSSDKUI_WF
//
//  Created by chuxiao on 2018/1/24.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIWebViewController.h"
@class BBSThread;

@interface BBSUIPortalDetailViewController : BBSUIWebViewController

- (instancetype)initWithThreadModel:(BBSThread *)model;

- (instancetype)initWithAid:(NSInteger)aid;

@property (nonatomic, strong) NSString *catname;

//1-允许评论，0-不允许评论
@property (nonatomic, strong) NSNumber *allowcomment;

@end
