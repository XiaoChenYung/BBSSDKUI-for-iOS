//
//  BBSUIInformationTableViewCell.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSInformation;

@interface BBSUIInformationTableViewCell : UITableViewCell

@property (nonatomic, strong) BBSInformation *information;

/**
 小红点
 */
@property (nonatomic, strong) UIView *redView;

@end
