//
//  BBSUITribuneViewController.h
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/4.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import "BBSUIThreadListView.h"
#import <BBSSDK/BBSForum.h>

@interface BBSUITribuneViewController : UIViewController

@property (nonatomic, assign) NSInteger orderType;

@property (nonatomic, strong) NSString *keyword;

@property (nonatomic, strong) NSString *catname;
//===
@property (nonatomic, assign) PageType pageType;


// 针对门户  1-允许评论，0-不允许评论
@property (nonatomic, strong) NSNumber *allowcomment;

- (instancetype)initWithForum:(BBSForum *)forum
                   selectType:(BBSUIThreadSelectType)selectType;

- (instancetype)initWithPageType:(PageType)pageType;

- (instancetype)initWithCatid:(NSInteger)catid;

- (void)refreshData:(BBSUIThreadOrderType)orderType;

- (void)refresh;

@end
