//
//  BBSUILBSLocationViewController.h
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBSUILBSLocationViewController;

typedef void(^LBSLocationSelectBlock) (id locationInfo);

@interface BBSUILBSLocationViewController : UIViewController

@property (nonatomic, copy) LBSLocationSelectBlock locationSelectBlock;

@property (nonatomic, assign) BOOL isPresent;
@property (nonatomic, strong) NSDictionary *preLocationDic;

@end
