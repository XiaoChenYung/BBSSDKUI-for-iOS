//
//  BBSUILBSSearchResultViewController.h
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class BBSUILBSSearchResultViewController;
@class AMapPOI;

@protocol BBSUILBSSearchResultViewControllerDelegate <NSObject>

- (void)BBSUILBSSearchResultViewController:(BBSUILBSSearchResultViewController *)searchResultController didSelectPoiWithPoiInfo:(AMapPOI *)poiInfo keyword:(NSString *)keyword;

@end

@interface BBSUILBSSearchResultViewController : UITableViewController

@property (weak, nonatomic) id<BBSUILBSSearchResultViewControllerDelegate> delegate;

@property(nonatomic,copy)NSString *keyword;
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;

@end
