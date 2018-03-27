//
//  BBSUIThreadListTableViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSUIThreadListView.h"
#import <BBSSDK/BBSForum.h>
#import "BBSUIEnum.h"

@interface BBSUIThreadListTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger orderType;

- (instancetype)initWithForum:(BBSForum *)forum
                   selectType:(BBSUIThreadSelectType)selectType
                     pageType:(PageType)pageType;

- (void)refreshData:(BBSUIThreadOrderType)orderType;

- (void)refresh;

@property (nonatomic, strong) NSString *keyword;

@end
