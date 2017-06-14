//
//  BBSUIFastPostViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUINormalNavViewController.h"

@protocol iBBSUIFastPostViewControllerDelegate <NSObject>

- (void)didBeginPostThread;

- (void)didPostSuccess;

- (void)didPostFailWithError:(NSError *)error;

@end

@interface BBSUIFastPostViewController : BBSUINormalNavViewController

+ (instancetype)shareInstance ;

- (void)addPostThreadObserver:(id<iBBSUIFastPostViewControllerDelegate>) observer;

- (void)removePostThreadObserver:(id<iBBSUIFastPostViewControllerDelegate>) observer;

@end
