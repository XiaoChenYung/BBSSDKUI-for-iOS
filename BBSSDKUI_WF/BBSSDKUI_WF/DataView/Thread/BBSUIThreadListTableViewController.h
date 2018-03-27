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

@interface BBSUIThreadListTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger orderType;

- (instancetype)initWithForum:(BBSForum *)forum
                   selectType:(BBSUIThreadSelectType)selectType;

- (instancetype)initWithPageType:(PageType)pageType;

- (instancetype)initWithCatid:(NSInteger)catid;

- (void)refreshData:(BBSUIThreadOrderType)orderType;

- (void)refresh;

@property (nonatomic, strong) NSString *keyword;

@property (nonatomic, strong) NSString *catname;

// 针对门户  1-允许评论，0-不允许评论
@property (nonatomic, strong) NSNumber *allowcomment;

@end
