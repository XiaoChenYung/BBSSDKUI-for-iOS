//
//  BBSUIUserInfoTableViewCell.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BBSSDK/BBSUser.h>

@interface BBSUIUserInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) BBSUser *user;

- (void)setTitle:(NSString *)title;

@end
