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
    BBSUIThreadSummaryCellTypeHistory,
    BBSUIThreadSummaryCellTypePortal
} BBSUIThreadSummaryCellType;

@interface BBSUIThreadSummaryCell : UITableViewCell

@property (nonatomic, assign ,getter=isReaded) BOOL read;

- (void)setThreadModel:(BBSThread *)threadModel cellType:(BBSUIThreadSummaryCellType)cellType;

@end
