//
//  BBSUIReplyEditor.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FinishEditHandler)(BOOL cancelled,NSArray <UIImage *>*,NSString *,NSDictionary *);

@interface BBSUIReplyEditor : UIViewController

- (void)showWithUserName:(NSString *)userName finishEdit:(FinishEditHandler)handler ;

- (void)dismiss;

@property (nonatomic, assign) BOOL isPortal;

@property (nonatomic,assign) BOOL isHiddenLBSMenu;

@end
