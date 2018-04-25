//
//  BBSUIBannerPreviewViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/10.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBannerPreviewViewController.h"

@interface BBSUIBannerPreviewViewController ()

@property (nonatomic, copy) NSString *bannerTitle;

@end

@implementation BBSUIBannerPreviewViewController

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.bannerTitle = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.bannerTitle) {
        self.title = self.bannerTitle;
    }
    
    if (self.urlString) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        [self.webView loadRequest:urlRequest];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
