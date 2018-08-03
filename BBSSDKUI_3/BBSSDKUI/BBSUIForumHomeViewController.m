//
//  BBSUIForumHomeViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumHomeViewController.h"
#import "BBSUIHomeViewController.h"

@interface BBSUIForumHomeViewController()<UIGestureRecognizerDelegate>

@end

@implementation BBSUIForumHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.interactivePopGestureRecognizer.delegate =  self;
}

+(BBSUIForumHomeViewController *)forumHomeViewControllerWithTitle:(NSString *)title
{
    BBSUIHomeViewController *forumVC = [[BBSUIHomeViewController alloc] init];
    BBSUIForumHomeViewController *homeVC = [[BBSUIForumHomeViewController alloc] initWithRootViewController:forumVC];    
    return homeVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count <= 1 ) {
        return NO;
    }
    
    return YES;
}

@end
