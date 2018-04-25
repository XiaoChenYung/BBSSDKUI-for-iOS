//
//  BBSUILBSLocationCell.h
//  BBSLBSPro
//
//  Created by wukx on 2018/4/4.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMapPOI;
@interface BBSUILBSLocationCell : UITableViewCell

- (void)setCheck:(BOOL)check;
- (void)configureForData:(AMapPOI *)data keyword:(NSString *)keyword;

+ (CGFloat)cellHeight;

+ (NSString *)getID;

@end
