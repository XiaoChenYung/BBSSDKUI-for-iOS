//
//  BBSUIForumHeaderFooterView.h
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/12.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BBSUIForumHeaderFooterViewDelegate<NSObject>

- (void)editForumHeaderView:(NSInteger)section;
- (void)expectForumHeaderView:(NSInteger)section;

@end

@interface BBSUIForumHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, assign) NSInteger sectionTag;
@property (nonatomic, weak) id <BBSUIForumHeaderFooterViewDelegate> deleagte;

+ (instancetype)sectionHeadViewWithTableView:(UITableView *)tableView section:(NSInteger)section allData:(NSArray *)allData;

- (void)updateHeaderView:(NSArray *)allData isSelectForum:(BOOL)isSelectForum;

@property (nonatomic, assign) BOOL isclicked;

/**
 编辑
 */
@property (nonatomic, assign) BOOL isEdited;

- (void)tetttttt;
- (void)hideEditButton;

@end