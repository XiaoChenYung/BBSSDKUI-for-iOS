//
//  BBSUIThreadSummaryImageContentView.h
//  BBSSDKUI_WF
//
//  Created by xiaochen yang on 2019/2/11.
//  Copyright © 2019 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSUIThreadSummaryImageContentView;

@protocol BBSUIThreadSummaryImageContentViewDelegate <NSObject>

- (void)threadSummaryImageContentView:(BBSUIThreadSummaryImageContentView *)contentView didSelectedIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BBSUIThreadSummaryImageContentView : UIView

@property (nonatomic, strong) NSArray *images;

//@property (nonatomic, weak) id<BBSUIThreadSummaryImageContentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
