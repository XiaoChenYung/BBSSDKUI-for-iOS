//
//  BBSUICollectionViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIWhiteNavViewController.h"
#import "BBSUICollectionView.h"

/**
 我的收藏、我的帖子
 */
@interface BBSUICollectionViewController : BBSUIWhiteNavViewController

@property (nonatomic, assign) BBSUICollectionViewType collectionViewType;

@property (nonatomic, strong) BBSUICollectionView *collectionView;

@property (nonatomic, copy) void (^deleteCellBlock)();

@end
