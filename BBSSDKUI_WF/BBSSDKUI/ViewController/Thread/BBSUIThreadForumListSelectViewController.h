//
//  BBSUIThreadForumListSelectViewController.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSForum;

@interface BBSUIThreadForumListSelectViewController : UIViewController

- (instancetype) initWithResult:(void(^)(BBSForum *selectedForum))result ;

@end
