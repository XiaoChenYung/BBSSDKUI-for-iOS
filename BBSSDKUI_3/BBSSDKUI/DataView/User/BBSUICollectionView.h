//
//  BBSUICollectionView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

typedef NS_ENUM(NSInteger, BBSUICollectionViewType)
{
    CollectionViewTypeThreadList            = 1,    // 个人帖子
    CollectionViewTypeThreadFavorites       = 2,    // 收藏帖子
    CollectionViewTypeOtherUserThreadList   = 3,    // 查看他人帖子
    CollectionViewTypeHistory               = 4     // 历史记录
};

@interface BBSUICollectionView : BBSUIBaseView

@property (nonatomic, strong) UITableView *collectionTableView;

- (void)refreshData;

/**
 查看他人帖子时候传递
 */
@property (nonatomic, strong) NSNumber *authorid;

@property (nonatomic, copy) void (^deleteCellBlock)();

- (instancetype)init:(BBSUICollectionViewType)type;
- (instancetype)initWithFrame:(CGRect)frame type:(BBSUICollectionViewType)type;


@end
