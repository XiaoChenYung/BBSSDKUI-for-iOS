//
//  BBSUIViewsRepliesView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BBSUIViewTypeViews,
    BBSUIViewTypeReplies,
} BBSUIViewType;

@interface BBSUIViewsRepliesView : UIView

+ (instancetype) viewWithType:(BBSUIViewType)type;

@property (nonatomic, assign) NSInteger count ;

@end
