//
//  BBSUIThreadTypeSignView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/6/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kSignTypeHot = @"/Common/hot3@2x.png";
static NSString *kSignTypeLike = @"/Common/ding3@2x.png";
static NSString *kSignTypePerfect = @"/Common/jin3@2x.png";

@interface BBSUIThreadTypeSignView : UIView

- (void) setupWithPaths:(NSArray *)paths;

@end
