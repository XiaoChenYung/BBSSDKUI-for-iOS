//
//  BBSUINavHeaderView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

@interface BBSUINavHeaderView : BBSUIBaseView

@property (nonatomic, weak) UITableView *tableView;

@property(nonatomic,copy) NSMutableArray *tableViews;

@property (nonatomic, strong) NSArray <UIButton *>*rightButotnArray;

@property (nonatomic, strong) NSString *title;

@end
