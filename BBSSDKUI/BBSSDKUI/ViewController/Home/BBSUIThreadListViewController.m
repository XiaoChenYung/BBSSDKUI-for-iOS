//
//  BBSUIThreadListViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadListViewController.h"
#import "BBSUIThreadListView.h"
#import "Masonry.h"

@interface BBSUIThreadListViewController ()

@property (nonatomic, strong) BBSUIThreadListView *threadListView;

@property (nonatomic, strong) BBSForum *currentForumModel;

@end

@implementation BBSUIThreadListViewController

- (instancetype)initWithForumModel:(BBSForum *)forumModel
{
    self = [super init];
    if (self) {
        _currentForumModel = forumModel;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.threadListView = [[BBSUIThreadListView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) forum:_currentForumModel];
    [self.view addSubview:self.threadListView];
}


@end
