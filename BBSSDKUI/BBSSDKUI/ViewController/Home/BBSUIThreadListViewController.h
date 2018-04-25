//
//  BBSUIThreadListViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2018/1/9.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import "BBSUIEnum.h"

@interface BBSUIThreadListViewController : BBSUIBaseViewController

@property (nonatomic, strong) UITableView       *homeTableView;

@property (nonatomic, assign) BBSUIThreadListViewType viewType;

@property (nonatomic, copy) void (^offSetBlock)(CGFloat offset);

@property (nonatomic, copy) void (^refreshBannerBlock)(NSArray *bannnerList, NSError *error);

- (instancetype)initWithCatid:(NSInteger)catid allowcomment:(NSInteger)allowcomment;

@end
