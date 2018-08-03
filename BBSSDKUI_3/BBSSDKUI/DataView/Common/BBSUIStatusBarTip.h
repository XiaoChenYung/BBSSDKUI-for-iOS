//
//  BBSUIStatusBarTip.h
//  BBSSDKUI
//
//  Created by liyc on 2017/8/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSUIStatusBarTip : UIWindow

+(BBSUIStatusBarTip *)shareStatusBar;

-(void)showMessage:(NSString*)strMessage logImage:(UIImage *)logImage delayTime:(NSInteger)delay;

- (void)postBegin;

- (void)postFailed:(NSString *)msg;

- (void)postSuccess;

@end
