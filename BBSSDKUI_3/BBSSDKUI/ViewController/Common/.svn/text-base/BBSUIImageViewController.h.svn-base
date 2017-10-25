//
//  BBSUIImageViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBSUIImageViewControllerDelegate <NSObject>

- (void)didTapImage:(UIImage *)image;

@end

@interface BBSUIImageViewController : UIViewController

- (instancetype) initWithUrl:(NSString *)url;

@property (nonatomic, weak) id<BBSUIImageViewControllerDelegate> delegate;

@end
