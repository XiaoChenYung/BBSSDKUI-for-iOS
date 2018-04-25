//
//  BBSUIForumViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumViewController.h"
#import "BBSUIForumView.h"
#import "BBSUIForumMoreView.h"
#import "BBSUIContext.h"
#import "BBSUIForumSelectView.h"




@interface BBSUIForumViewController ()

@property (nonatomic, strong) BBSUIForumSelectView *forumView;
@property (nonatomic, strong) BBSUIForumMoreView *forumMoreView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *navTitleLabel;


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

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setTitleView];
    [self _configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)_configureUI
{
    CGFloat Height = NavigationBar_Height+10;
    if (_forumType == BBSUIForumViewControllerTypeSelectForum)
    {
        [self.navTitleLabel setText:@"选择版块"];

        self.forumView = [[BBSUIForumSelectView alloc] initWithFrame:CGRectMake(0,
                                                                                  Height,
                                                                                  CGRectGetWidth(self.view.frame),
                                                                                  CGRectGetHeight(self.view.frame) - NavigationBar_Height)
                                                             forumType:self.forumType
                                                         selectHandler:self.resultHandler];
        
    }
    else
    {
        [self.navTitleLabel setText:@"全部版块"];
        
        
        self.forumMoreView = [[BBSUIForumMoreView alloc] initWithFrame:CGRectMake(0,
                                                                                  Height,
                                                                                  CGRectGetWidth(self.view.frame),
                                                                                  CGRectGetHeight(self.view.frame) - NavigationBar_Height)
                                                             forumType:self.forumType
                                                         selectHandler:self.resultHandler];
        
    }
    
    [self.view addSubview:self.forumView];
    [self.view addSubview:self.forumMoreView];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
}

- (void)_setTitleView
{
    CGFloat iphoneXTopPadding = 0;
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        iphoneXTopPadding = 10;
    }
    
    CGFloat controlY = 27 + iphoneXTopPadding;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(7, controlY, 30, 30)];
    [self.backButton setImage:[UIImage BBSImageNamed:@"/Common/backWhite.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    [self.backButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Common/backBlack@2x.png"] withSize:CGSizeMake(60, 60)] forState:UIControlStateNormal];
    
    self.titleView = [[UIView alloc] init];
    [self.titleView setFrame:CGRectMake(50, 30, BBS_WIDTH(self.view) - 100, 44-15)];
    [self.view addSubview:self.titleView];
    
    
    self.navTitleLabel = [UILabel new];
    [self.titleView addSubview:self.navTitleLabel];
    [self.navTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    self.navTitleLabel.text = @"全部版块";
    CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
    CGSize buttonSize = [self.navTitleLabel.text boundingRectWithSize:size
                                                              options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                           attributes:@{ NSFontAttributeName:self.navTitleLabel.font}
                                                              context:nil].size;
    [self.navTitleLabel setFrame:CGRectMake((BBS_WIDTH(self.titleView) - buttonSize.width) / 2, (BBS_HEIGHT(self.titleView) - buttonSize.height) / 2, buttonSize.width, buttonSize.height)];
    [self.navTitleLabel setTextColor:[UIColor blackColor]];

}

#pragma mark - 点击事件
//返回
- (void)backButtonHandler:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
