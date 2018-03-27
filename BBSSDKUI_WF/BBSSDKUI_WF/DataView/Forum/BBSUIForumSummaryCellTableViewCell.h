//
//  BBSUIForumSummaryCellTableViewCell.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/24.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BBSSDK/BBSForum.h>

@class BBSUIForumSummaryCellTableViewCell;
@protocol BBSUIForumSummaryCellDelegate <NSObject>

- (void)stickChanged:(BBSUIForumSummaryCellTableViewCell *)cell;

@end

@interface BBSUIForumSummaryCellTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView        *seperateView;

@property (nonatomic, weak) id <BBSUIForumSummaryCellDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *stickForumArray;

@property (nonatomic, strong) BBSForum *forumModel;

@property (nonatomic, strong) UIButton *stickButton;

- (void)setStickButtonHidden:(BOOL)hidden;

@end

