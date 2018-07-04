//
//  BBSUIImagePreviewWebController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIImagePreviewWebController.h"
#import "NSBundle+BBSSDKUI.h"
#import "BBSUIJSNative.h"
#import "UIImage+BBSFunction.h"
#import "BBSJSImageDownload.h"

@interface BBSUIImagePreviewWebController ()

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) BBSUIJSNative *jsNative;

@property (nonatomic, strong) NSArray *urlsArray;

@property (nonatomic) NSInteger index;

@property (nonatomic, strong) UIBarButtonItem *moreButtonItem;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) BBSJSImageDownload *imageDownload;

@end

@implementation BBSUIImagePreviewWebController

- (BBSUIImagePreviewWebController *)initWithUrls:(NSArray *)urls index:(NSInteger)index
{
    self = [super init];
    if (self) {
        _urlsArray = urls;
        _index = index;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //更多按钮
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(0, 0, 40, 40)];
    [self.moreButton setImage:[UIImage BBSImageNamed:@"/Common/more@2x.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(moreButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreButton];
    self.navigationItem.rightBarButtonItem = self.moreButtonItem;
    
    [self loadHTML];
    
    [self registerNativeMethods];
    
}

- (void)dealloc{
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button handler
- (void)moreButtonHandler:(UIButton *)moreButton
{
    __weak typeof(self) theWebController = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self addActionTarget:alert title:@"保存到相册" color:[UIColor blackColor] action:^(UIAlertAction *action) {
        
        [theWebController.imageDownload saveImage];
        
    }];
    
    [self addCancelActionTarget:alert title:@"取消"];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private methods
// 取消按钮
-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [action setValue:DZSUIColorFromHex(0x89BD6A) forKey:@"_titleTextColor"];
    [alertController addAction:action];
}
//添加对应的title    这个方法也可以传进一个数组的titles  我只传一个是为了方便实现每个title的对应的响应事件不同的需求不同的方法
- (void)addActionTarget:(UIAlertController *)alertController title:(NSString *)title color:(UIColor *)color action:(void(^)(UIAlertAction *action))actionTarget
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        actionTarget(action);
    }];
    [action setValue:color forKey:@"_titleTextColor"];
    [alertController addAction:action];
}

#pragma mark - private methods
- (void)loadHTML
{
    NSString *filePath = [[NSBundle bbsLoadBundle] pathForResource:@"HTML/mobforum/imgshow" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
}

- (void)registerNativeMethods
{
    [self registerGetImageUrlsAndIndex];
    [self registerSetCurrentImageSrc];
}

- (void)registerGetImageUrlsAndIndex
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getImageUrlsAndIndex" block:^(NSArray *arguments) {
        
        NSString *callback = nil;
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            callback = arguments[0];
        }
        
        if (callback)
        {
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:theWebController.urlsArray, @"imageUrls",
                                   @(theWebController.index), @"index",
                                   nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:param]]];
            });
            
            if (!theWebController.imageDownload) {
                theWebController.imageDownload = [[BBSJSImageDownload alloc] initWithJSContext:theWebController.jsContext imageArray:theWebController.urlsArray isImageViewer:YES webView:theWebController.webView];
            }
        }
        
    }];
}

- (void)registerSetCurrentImageSrc
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"setCurrentImageSrc" block:^(NSArray *arguments) {
        
        NSString *imgSrc = nil;
        NSInteger *index = 0;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            imgSrc = arguments[0];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]]) {
            index = [arguments[1] integerValue];
        }
            
        if (!theWebController.imageDownload) {
            theWebController.imageDownload = [[BBSJSImageDownload alloc] initWithJSContext:theWebController.jsContext imageArray:theWebController.urlsArray isImageViewer:YES webView:theWebController.webView];
        }
        
        [theWebController.imageDownload setCurrentIndex:index url:imgSrc];
        
    }];
}

@end
