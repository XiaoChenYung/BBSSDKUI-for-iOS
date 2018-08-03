//
//  BBSUICollectionTableViewCell.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSUICollectionView.h"
@class BBSThread;

@interface BBSUICollectionTableViewCell : UITableViewCell

@property (nonatomic, copy)void (^addressOnClickBlock)(BBSThread *collection);

@property (nonatomic, assign) BBSUICollectionViewType collectionViewType;

@property (nonatomic, strong) BBSThread *collection;

@end
