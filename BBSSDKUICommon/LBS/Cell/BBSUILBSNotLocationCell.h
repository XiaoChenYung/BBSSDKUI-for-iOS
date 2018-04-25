//
//  BBSUILBSNotLocationCell.h
//  BBSLBSPro
//
//  Created by wukexiu on 2018/4/4.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSUILBSNotLocationCell : UITableViewCell

- (void)setCheck:(BOOL)check;
- (void)configureForTitle:(NSString *)title;

+ (CGFloat)cellHeight;

+ (NSString *)getID;

@end
