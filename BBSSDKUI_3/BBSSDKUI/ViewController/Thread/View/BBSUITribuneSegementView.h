//
//  BBSUITribuneSegementView.h
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/6.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 选择类型枚举
typedef NS_ENUM(NSInteger, BBSMenuType) {
    BBSUISegmentViewMenuTypeNew  = 0, // 最新
    BBSUISegmentViewMenuTypeHot    = 1, // 热门
    BBSUISegmentViewMenuTypeCream  = 2,  // 精华
    BBSUISegmentViewMenuTypeTop = 3, //置顶
    BBSUISegmentViewMenuReplySort = 4,//回复时间排序
    BBSUISegmentViewMenuSendSort = 5//发帖时间排序
};


@protocol iBBSUISegmentViewDelegate <NSObject>

- (void)selectSegementType:(NSInteger)index;
-(void)selectSortByType:(NSInteger)sortIndex;

@end

@interface BBSUITribuneSegementView : UIView

@property (nonatomic, weak) id <iBBSUISegmentViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *buttonsArr;

@property (nonatomic, assign) BOOL isHover;

- (void)hoverViewClick:(UIButton *)sender;


@end
