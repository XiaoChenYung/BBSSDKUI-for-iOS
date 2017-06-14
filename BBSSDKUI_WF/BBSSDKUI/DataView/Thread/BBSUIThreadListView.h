//
//  BBSUIThreadListView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSForum.h>

typedef NS_ENUM(NSInteger, BBSUIThreadSelectType)
{
    BBSUIThreadSelectTypeLatest = 0,        //最新
    BBSUIThreadSelectTypeHeats = 1,         //热门
    BBSUIThreadSelectTypeDigest = 2,        //精华
    BBSUIThreadSelectTypeDisplayOrder = 3   //置顶
};

typedef NS_ENUM(NSInteger, BBSUIThreadOrderType)
{
    BBSUIThreadOrderCommentTime = 0,    //最后回复时间排序
    
    BBSUIThreadOrderPostTime = 1        //发布时间排序
};

@interface BBSUIThreadListView : BBSUIBaseView

@property (nonatomic, assign) NSInteger currentSelectType;

@property (nonatomic, assign) NSInteger currentOrderType;

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum;

- (void)requestDataWithOrderType:(BBSUIThreadOrderType)orderType;

@end

@interface BBSUIThreadListTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger orderType;

- (instancetype)initWithForum:(BBSForum *)forum selectType:(BBSUIThreadSelectType)selectType;

- (void)refreshData:(BBSUIThreadOrderType)orderType;

@end
