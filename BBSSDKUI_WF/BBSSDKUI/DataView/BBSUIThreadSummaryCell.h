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
    BBSUIThreadSummaryCellTypeForums
} BBSUIThreadSummaryCellType;

@interface BBSUIThreadSummaryCell : UITableViewCell

@property (nonatomic, strong) BBSThread *threadModel;

@property (nonatomic, assign ,getter=isReaded) BOOL read;

@property (nonatomic, assign) BBSUIThreadSummaryCellType cellType;

@end
