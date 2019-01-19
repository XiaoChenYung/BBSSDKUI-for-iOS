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
    
    self.forumView = [[BBSUIForumView alloc] init];
    [self.view addSubview:self.forumView];
    [self.forumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = @"社区";
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.forumView reloadStickData];
}

@end
