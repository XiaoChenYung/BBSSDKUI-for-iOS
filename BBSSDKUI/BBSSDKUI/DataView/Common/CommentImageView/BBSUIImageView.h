//
//  BBSUIImageView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBSUIImageView ;

@protocol iBBSUIImageViewDelegate <NSObject>

- (void) didDeleted:(BBSUIImageView *)view ;

@end

@interface BBSUIImageView : UIView

+ (instancetype)viewWithImage:(UIImage *)image ;

@property(nonatomic ,strong) UIImage *image ;

@property (nonatomic, weak) id<iBBSUIImageViewDelegate> delegate ;

@end
