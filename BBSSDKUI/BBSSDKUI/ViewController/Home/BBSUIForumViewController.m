//
//  BBSUIForumViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/16.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumViewController.h"
#import "BBSUIForumListView.h"
#import "Masonry.h"

@interface BBSUIForumViewController ()

@property (nonatomic, strong) BBSUIForumListView *forumListView;

@end

@implementation BBSUIForumViewController

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        self.title = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.forumListView = [BBSUIForumListView new];
    [self.view addSubview:self.forumListView];
    [self.forumListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
