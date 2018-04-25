//
//  BBSCurrentViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BBSCurrentViewController : NSObject

+ (instancetype)share;

@property (nonatomic, strong, readonly) __kindof UIViewController *currentViewController;

@property (nonatomic, strong) __kindof UINavigationController *currentNavigationController;

@end
