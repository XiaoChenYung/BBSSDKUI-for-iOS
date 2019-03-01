//
//  DZSThreadAbstractCell.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBSUIViewsRepliesView ;
@class BBSThread ;

typedef enum : NSUInteger {
    BBSUIThreadSummaryCellTypeHomepage,
    BBSUIThreadSummaryCellTypeForums,
    BBSUIThreadSummaryCellTypeSearch,
    BBSUIThreadSummaryCellTypeHistory,//历史
    BBSUIThreadSummaryCellTypePortal,
    BBSUIThreadSummaryCellTypeAttion//关注
} BBSUIThreadSummaryCellType;

@interface BBSUIThreadSummaryCell : UITableViewCell

@property (nonatomic, copy)void (^addressOnClickBlock)(BBSThread *threadModel);

@property (nonatomic, copy)void (^deleteOnClickBlock)(BBSThread *threadModel);

@property (nonatomic, strong) BBSThread *threadModel;

@property (nonatomic, assign ,getter=isReaded) BOOL read;

@property (nonatomic, assign) BBSUIThreadSummaryCellType cellType;

@property (nonatomic, assign) BOOL isMyPosts;

@end
