//
//  BBSUIBackViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/3/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"

typedef NS_ENUM(NSInteger, BBSUINavigationBarStyle) {
    /**
     * Default value. All download operations will execute in queue style (first-in-first-out).
     */
    BBSUINavigationBarStyleDefault,
    
    /**
     * All download operations will execute in stack style (last-in-first-out).
     */
    BBSUINavigationBarStyleWhite
};

@interface BBSUIBackViewController : BBSUIBaseViewController

- (void)backButtonHandler:(UIButton *)button;

@end
