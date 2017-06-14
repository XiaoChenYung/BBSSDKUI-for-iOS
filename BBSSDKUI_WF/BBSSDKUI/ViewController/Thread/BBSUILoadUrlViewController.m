//
//  BBSUILoadUrlViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/14.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUILoadUrlViewController.h"

@interface BBSUILoadUrlViewController ()

@end

@implementation BBSUILoadUrlViewController

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.urlString = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    [self loadUrl];
}

- (void)dealloc
{
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUrl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

#pragma mark - uiwebview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //截取字符串，设置标题
    NSString *webTitleName=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *theTitle = webTitleName;
    if (theTitle.length > 16) {
        NSString *fileNamePre = [theTitle substringWithRange:NSMakeRange(0, 8)];
        NSString *fileNameSuf = [theTitle substringWithRange:NSMakeRange(theTitle.length - 8, 8)];
        theTitle = [NSString stringWithFormat:@"%@...%@", fileNamePre, fileNameSuf];
    }
    self.title = theTitle;
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

@end
