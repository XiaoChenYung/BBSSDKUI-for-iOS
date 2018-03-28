//
//  BBSUICheckAttachmentWebViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICheckAttachmentWebViewController.h"
#import <MOBFoundation/MOBFoundation.h>
#import "BBSUIDownloadView.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"

@interface BBSUICheckAttachmentWebViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) NSDictionary *attachment;

@property (nonatomic, strong) BBSUIDownloadView *downLoadView;

@property (nonatomic, strong) UIBarButtonItem *moreButtonItem;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, copy) NSString *fileURL;

@end

@implementation BBSUICheckAttachmentWebViewController

- (instancetype)initWithAttachment:(NSDictionary *)attachment
{
    self = [super init];
    if (self) {
        self.attachment = attachment;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置导航栏标题
    [self setNavigationTitle];
    
    //更多按钮
    [self addRightItem];
    [self addDownloadView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    self.webView.delegate = nil;
}

#pragma mark - private methods
- (void)setNavigationTitle
{
    NSString *attachmentName = self.attachment[@"fileName"];
    if ([attachmentName isKindOfClass:[NSString class]]) {
        NSString *fileName = [attachmentName stringByDeletingPathExtension];
        NSString *extendName = [attachmentName pathExtension];
        if (fileName.length > 6) {
            NSString *fileNamePre = [fileName substringWithRange:NSMakeRange(0, 4)];
            NSString *fileNameSuf = [fileName substringWithRange:NSMakeRange(fileName.length - 3, 2)];
            attachmentName = [NSString stringWithFormat:@"%@...%@%@", fileNamePre, fileNameSuf, extendName ? [NSString stringWithFormat:@".%@", extendName] : nil];
        }
        
        self.title = attachmentName;
    }
}

- (void)addRightItem {
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(0, 0, 40, 40)];
    [self.moreButton setImage:[UIImage BBSImageNamed:@"/Common/more@2x.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(moreButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreButton];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)addDownloadView
{
    //下载展示
    __weak typeof(self) theWebController = self;
    self.downLoadView = [[BBSUIDownloadView alloc] init];
    [self.view addSubview:self.downLoadView];
    [self.downLoadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(NavigationBar_Height, 0, 0, 0));
    }];
    [self.downLoadView setFinishResult:^(NSString *fileURL, BOOL canOpen, BOOL isTxt) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fileURL) {
                theWebController.fileURL = fileURL;
                if (canOpen) {
                    [theWebController.downLoadView setHidden:YES];
                }else{
                    [theWebController.downLoadView setHidden:NO];
                }
                
                theWebController.navigationItem.rightBarButtonItem = theWebController.moreButtonItem;
                [theWebController loadContent:isTxt];
                
            }
        });
        
    }openInOther:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [theWebController.moreButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
    }];
    [self.downLoadView setAttachment:self.attachment];
}

#pragma mark -下载文件
- (void)loadContent:(BOOL)isTxt
{
    if (isTxt) {
        ///编码可以解决 .txt 中文显示乱码问题
        NSStringEncoding *useEncodeing = nil;
        //带编码头的如utf-8等，这里会识别出来
        NSString *content = [NSString stringWithContentsOfFile:self.fileURL usedEncoding:useEncodeing error:nil];
        //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
        if (!content) {
            content = [NSString stringWithContentsOfFile:self.fileURL encoding:0x80000632 error:nil];
        }
        //还是识别不到，按GB18030编码再解码一次.
        if (!content) {
            content = [NSString stringWithContentsOfFile:self.fileURL encoding:0x80000631 error:nil];
        }
        if (content) {
            [self.webView loadHTMLString:content baseURL:nil];
            return;
        }
    }
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.fileURL]];
    [self.webView loadRequest:request];
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
    
    UIPopoverPresentationController *popoverController = alert.popoverPresentationController;
    popoverController.sourceView = self.view;
    popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,DZSUIScreen_height,1.0,1.0);
    
    [self addActionTarget:alert title:@"用其他应用打开" color:[UIColor blackColor] action:^(UIAlertAction *action) {
        
        theWebController.documentInteractionController = [UIDocumentInteractionController
                                                          interactionControllerWithURL:[NSURL fileURLWithPath:theWebController.fileURL]];
        [theWebController.documentInteractionController setDelegate:theWebController];
        [theWebController.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:theWebController.view animated:YES];
        
    }];
    
    [self addCancelActionTarget:alert title:@"取消"];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private methods
// 取消按钮
-(void)addCancelActionTarget:(UIAlertController*)alertController title:(NSString *)title
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"啊啊啊啊啊啊");
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

@end
