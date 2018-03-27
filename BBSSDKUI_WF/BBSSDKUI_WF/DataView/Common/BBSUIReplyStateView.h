//
//  BBSUIReplyStateView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BBSUIReplyStateNormal,
    BBSUIReplyStateSuccess,
    BBSUIReplyStateFail,
    BBSUIReplyStateUploading,
} BBSUIReplyState;

@interface BBSUIReplyStateView : UIView

@property (nonatomic, assign) BBSUIReplyState state;

// 开放出来是为了改写title
@property(nonatomic, strong) UIButton *replyBtn;

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;

@end
