//
//  BBSUIThreadDetailWebViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadDetailWebViewController.h"
#import "NSBundle+BBSSDKUI.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <MOBFoundation/MOBFJSContext.h>
#import <MOBFoundation/MOBFJson.h>
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSPost.h>
#import "BBSJSImageDownload.h"
#import "BBSUIImagePreviewWebController.h"
#import "BBSUICheckAttachmentWebViewController.h"
#import "BBSUILoadUrlViewController.h"
#import "BBSUIModelToObject.h"

@interface BBSUIThreadDetailWebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) BBSThread *model;

@property (nonatomic, strong) BBSJSImageDownload *imageDownload;

@end

@implementation BBSUIThreadDetailWebViewController

- (instancetype)initWithThreadModel:(BBSThread *)model
{
    self = [super init];
    if (self) {
        _model = model;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"帖子详情";
    [self.webView setDelegate:self];//设置代理
        
    [self registerNativeMethods];//注册本地native方法
    [self loadHTML];//加载HTML
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.webView.delegate = self;
}

#pragma mark - webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //TODO 网页加载完成
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *scheme = [url scheme];
    //点击跳转链接
    if (![scheme isEqualToString:@"file"]) {
        
        BBSUILoadUrlViewController *checkVC = [[BBSUILoadUrlViewController alloc] initWithUrl:[url absoluteString]];
        if (self.navigationController) {
            [self.navigationController pushViewController:checkVC animated:YES];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - private
- (void)loadHTML
{
    NSString *filePath = [[NSBundle bbsLoadBundle] pathForResource:@"HTML/mobforum/index" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
}

- (void)registerNativeMethods
{
    [self registerGetForumListMethod];
    [self registerGetPostMethod];
    [self registerDownloadImages];
    [self registerOpenImage];
    [self registerOpenAttachment];
    [self registerOpenHref];
}

#pragma mark - 注册js方法
- (void)registerGetForumListMethod
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getForumThreadDetails" block:^(NSArray *arguments) {
        
        NSString *callback = nil;
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            callback = arguments[0];
        }
        
        NSDictionary *forumDetailDic = [BBSUIModelToObject objectFromThreadModel:theWebController.model];
        
        if (callback)
        {
            [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:forumDetailDic]]];
        }
        
    }];
}

- (void)registerGetPostMethod
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getPosts" block:^(NSArray *arguments) {
        
        NSInteger fid = 0;
        NSInteger tid = 0;
        NSInteger page = 0;
        NSInteger pageSize = 0;
        NSString *callback = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            fid = [arguments[0] integerValue];
        }
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
        {
            tid = [arguments[1] integerValue];
        }
        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSNumber class]])
        {
            page = [arguments[2] integerValue];
        }
        if (arguments.count > 3 && [arguments[3] isKindOfClass:[NSNumber class]])
        {
            pageSize = [arguments[3] integerValue];
        }
        if (arguments.count > 4 && [arguments[4] isKindOfClass:[NSString class]]) {
            callback = arguments[4];
        }
        
        [BBSSDK getPostListWithFid:fid tid:tid pageIndex:page pageSize:pageSize result:^(NSArray *postList, NSError *error) {
            
            NSMutableArray *postArray = [NSMutableArray array];
            [postList enumerateObjectsUsingBlock:^(BBSPost *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[BBSPost class]]) {
                    NSDictionary *postDic = [BBSUIModelToObject objectFromPostModel:obj];
                    [postArray addObject:postDic];
                }
            }];
            
            if (!error && postArray.count > 0) {
                if (callback)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [theWebController.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:postArray]]];
                    });
                }
            }else{
                if (callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(false)", callback]];
                    });
                    
                }
            }
            
        }];
        
    }];
}

- (void)registerDownloadImages
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"downloadImages" block:^(NSArray *arguments) {
        
        NSArray *imageUrlsArray = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSArray class]])
        {
            imageUrlsArray = arguments[0];
        }
        
        if (imageUrlsArray.count > 0) {
            
            if (!theWebController.imageDownload) {
                theWebController.imageDownload = [[BBSJSImageDownload alloc] initWithJSContext:theWebController.jsContext imageArray:imageUrlsArray isImageViewer:NO webView:theWebController.webView];
            }
            
        }
    }];
}

- (void)registerOpenImage
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openImage" block:^(NSArray *arguments) {
        
        NSArray *imageUrlsArray = nil;
        NSInteger index = 0;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSArray class]])
        {
            imageUrlsArray = arguments[0];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]]) {
            index = [arguments[1] integerValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BBSUIImagePreviewWebController *previewWebVC = [[BBSUIImagePreviewWebController alloc] initWithUrls:imageUrlsArray index:index];
            [theWebController.navigationController pushViewController:previewWebVC animated:YES];
        });
    }];
}

- (void)registerOpenAttachment
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openAttachment" block:^(NSArray *arguments) {
        
        NSDictionary *attachmentDic = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]]) {
            attachmentDic = arguments[0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BBSUICheckAttachmentWebViewController *checkVC = [[BBSUICheckAttachmentWebViewController alloc] initWithAttachment:attachmentDic];
            if (theWebController.navigationController) {
                [theWebController.navigationController pushViewController:checkVC animated:YES];
            }
        });
        
    }];
}

- (void)registerOpenHref
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openHref" block:^(NSArray *arguments) {
        
        NSString *href = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            href = arguments[0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BBSUILoadUrlViewController *checkVC = [[BBSUILoadUrlViewController alloc] initWithUrl:href];
            if (theWebController.navigationController) {
                [theWebController.navigationController pushViewController:checkVC animated:YES];
            }
        });
        
    }];
}

@end
