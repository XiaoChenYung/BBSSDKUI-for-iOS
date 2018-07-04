//
//  BBSUIForumHomeViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/15.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumHomeViewController.h"
#import "BBSUIForumViewController.h"

@implementation BBSUIForumHomeViewController

+(BBSUIForumHomeViewController *)forumHomeViewControllerWithTitle:(NSString *)title
{
    BBSUIForumViewController *forumVC = [[BBSUIForumViewController alloc] initWithTitle:title];
    BBSUIForumHomeViewController *homeVC = [[BBSUIForumHomeViewController alloc] initWithRootViewController:forumVC];
    
    return homeVC;
}

@end
