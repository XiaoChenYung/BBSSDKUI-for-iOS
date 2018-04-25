//
//  BBSUILBSShowLocationViewController.h
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BBSUILBSShowLocationViewController : UIViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
