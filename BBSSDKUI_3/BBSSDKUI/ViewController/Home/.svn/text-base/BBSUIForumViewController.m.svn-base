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

@property (nonatomic, copy) void (^resultHandler)(BBSForum *forum);

@end

@implementation BBSUIForumViewController

- (instancetype)initWithSelectType:(BBSUIForumViewControllerType)forumType resultHandler:(void (^)(BBSForum *))resultHandler
{
    self = [super init];
    if (self) {
        self.forumType = forumType;
        self.resultHandler = resultHandler;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat Height;
    if (_forumType == BBSUIForumViewControllerTypeSelectForum)
    {
        self.title = @"选择版块";
        Height= 0;
    }
    else
    {
        self.title = @"全部版块";
        Height = NavigationBar_Height;
    }
    
    // Do any additional setup after loading the view.
    
    self.forumView = [[BBSUIForumView alloc] initWithFrame:CGRectMake(0,
                                                                      Height,
                                                                      CGRectGetWidth(self.view.frame),
                                                                      CGRectGetHeight(self.view.frame) - NavigationBar_Height)
                                                 forumType:self.forumType
                                             selectHandler:self.resultHandler];

    [self.view addSubview:self.forumView];
    
    self.automaticallyAdjustsScrollViewInsets=NO; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
