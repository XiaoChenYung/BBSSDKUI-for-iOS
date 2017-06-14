//
//  BBSUICustomNavViewController.h
//  BBSSDKUI
//
//  Created by liyc on 2017/5/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseViewController.h"
#import "BBSUIBackViewController.h"

typedef NS_ENUM(NSInteger, BBSUINavigationBarStyle) {
    /**
     * Default value. All download operations will execute in queue style (first-in-first-out).
     */
    BBSUINavigationBarStyleDefault,
    
    /**
     * All download operations will execute in stack style (last-in-first-out).
     */
    BBSUINavigationBarStyleDarkBlue
};

@interface BBSUICustomNavViewController : BBSUIBackViewController

@property (nonatomic, assign) BBSUINavigationBarStyle navigationBarStyle;

@end
