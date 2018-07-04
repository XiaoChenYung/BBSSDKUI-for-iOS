//
//  BBSUIForumViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumViewController.h"
#import "BBSUIForumView.h"

@interface BBSUIForumViewController ()

@property (nonatomic, strong) BBSUIForumView *forumView;

@property (nonatomic, strong) UIImageView *img;

@end

@implementation BBSUIForumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.forumView = [[BBSUIForumView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  CGRectGetWidth(self.view.frame),
                                                                  CGRectGetHeight(self.view.frame) - NavigationBar_Height)];
    [self.view addSubview:self.forumView];
    self.title = @"所有版块";
    self.automaticallyAdjustsScrollViewInsets=NO;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.forumView reloadStickData];
}

@end
