//
//  BBSUIPortalDetailViewController.m
//  BBSSDKUI_WF
//
//  Created by chuxiao on 2018/1/24.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIPortalDetailViewController.h"
#import <BBSSDK/BBSThread.h>
#import "Masonry.h"
#import "BBSUIMacro.h"
#import "BBSUIReplyEditor.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSThreadAttachment.h>
#import <BBSSDK/BBSComment.h>
#import <BBSSDK/BBSLocation.h>
#import "BBSJSImageDownload.h"
#import "BBSUIImagePreviewHUD.h"
#import "BBSUICheckAttachmentWebViewController.h"
#import "BBSUILoadUrlViewController.h"
#import "BBSUIContext.h"
#import "BBSUIReplyStateView.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "BBSUILoginViewController.h"
#import "BBSUIProcessHUD.h"
#import "UIImage+BBSFunction.h"
#import "UIView+BBSUIBadge.h"
#import "BBSUIUserOtherInfoViewController.h"
#import "BBSUIPopoverView.h"
#import "BBSUIAccusationViewController.h"
#import "BBSUIProcessHUD.h"
#import "MBProgressHUD.h"
#import "BBSUICoreDataManage.h"
#import "BBSUIShareView.h"
#import <BBSSDK/BBSMOBFScene.h>
#import "BBSUILBSShowLocationViewController.h"
#import "BBSUILBSLocationProxy.h"

@interface BBSUIPortalDetailViewController ()

@property (nonatomic, strong) BBSThread *threadModel;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) BBSUIReplyEditor *replyEditor;
@property (nonatomic, strong) BBSJSImageDownload *imageDownload;
@property (nonatomic, strong) BBSUIReplyStateView *replyView;
@property (nonatomic, assign) NSInteger aid;
//@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, assign) BOOL isFavirated;

@end

@implementation BBSUIPortalDetailViewController

+ (NSString *)MLSDKPath
{
    return @"/portal/detail";
}

- (instancetype)initWithMobLinkScene:(BBSMOBFScene *)scene;
{
    self = [super init];
    if (self)
    {
        NSDictionary *sceneDict = [scene getParams];
        self.aid = [sceneDict[@"aid"] integerValue];
    }
    return self;
}

- (instancetype)initWithAid:(NSInteger)aid
{
    if (self = [super init]) {
        self.aid = aid;
    }
    
    return self;
}

- (instancetype)initWithThreadModel:(BBSThread *)model
{
    if (self = [super init])
    {
        self.threadModel = model;
        self.aid = self.threadModel.aid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupJSNativeWithNativeExtPath:@"/HTML_Portal/assets/js/NativeExt"];
    [self registerNativeMethods];//注册本地native方法
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    
    if ([[BBSUIContext shareInstance].currentUser.uid integerValue] == _threadModel.authorId) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.navigationController.navigationBar setTranslucent:NO];
    //状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)setup
{
    self.webView.backgroundColor = [UIColor whiteColor];

    self.webView.delegate = self ;
    [self setBarButtonItem];
    [self configBottomBar];
    [self loadWeb];
    
}

- (void)setBarButtonItem
{
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage BBSImageNamed:@"/Thread/more@2x.png"] forState:UIControlStateNormal];
    [moreButton setFrame:CGRectMake(0, 0, 44, 44)];
    [moreButton addTarget:self action:@selector(moreButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
}

- (void)configBottomBar
{
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).with.offset(-50);
    }];
    
    self.bottomBar =
    ({
        UIView *bottomBar = [[UIView alloc] init];
        bottomBar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomBar];
        [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.equalTo(@50);
        }];
        bottomBar ;
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reply:)];
    [self.bottomBar addGestureRecognizer:tap];
    
    
    UIView *topLine = [[UIView alloc] init];
    topLine.alpha  = 0.1;
    topLine.backgroundColor = [UIColor darkGrayColor];
    [_bottomBar addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_bottomBar);
        make.height.equalTo(@1);
    }];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomBar).with.offset(-7);
        make.centerY.equalTo(self.bottomBar);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [shareButton addTarget:self action:@selector(shareButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage BBSImageNamed:@"/Thread/share@2x.png"] forState:UIControlStateNormal];
    
//    _favButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.bottomBar addSubview:_favButton];
//    [_favButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(shareButton.mas_left).with.offset(-15);
//        make.centerY.equalTo(shareButton.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//    }];
//    [_favButton addTarget:self action:@selector(favButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
//    [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favDeselected@2x.png"] forState:UIControlStateNormal];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:_commentButton];
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(shareButton.mas_left).with.offset(-15);
        make.centerY.equalTo(shareButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_commentButton addTarget:self action:@selector(commentButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_commentButton setImage:[UIImage BBSImageNamed:@"/Thread/comment@2x.png"] forState:UIControlStateNormal];
    [self updateUI];
    
    UIView *midLine = [[UIView alloc] init];
    midLine.alpha  = 0.0;
    midLine.backgroundColor = [UIColor lightGrayColor];
    [_bottomBar addSubview:midLine];
    
    self.replyView =
    ({
        BBSUIReplyStateView *replyView = [[BBSUIReplyStateView alloc] init];
        
        if ((self.allowcomment && self.allowcomment.integerValue == 0) || self.threadModel.allowcomment == 0)
        {
            [replyView.replyBtn setTitle:@"禁止评论" forState:UIControlStateDisabled];
        }else
        {
            [replyView addTapGestureRecognizerWithTarget:self action:@selector(reply:)];
        }

        replyView.state = BBSUIReplyStateNormal;
        [_bottomBar addSubview:replyView];
        [replyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(_bottomBar);
            make.right.equalTo(midLine.mas_left);
        }];
        replyView ;
    });
}

- (void)updateUI
{
    if (_threadModel.commentnum > 0) {
        [_commentButton bbs_MakeBadgeText:[NSString stringWithFormat:@"%zd", _threadModel.commentnum] textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont systemFontOfSize:12]];
    }
    // ??? 
//    if (_threadModel.favid != 0) {
//        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favSelected@2x.png"] forState:UIControlStateNormal];
//        self.isFavirated = YES;
//    }else{
//        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favDeselected@2x.png"] forState:UIControlStateNormal];
//        self.isFavirated = NO;
//    }
    
    //    if (_threadModel.authorId == [[BBSUIContext shareInstance].currentUser.uid integerValue]) {
    //        [self.favButton setEnabled:NO];
    //    }
}

- (void)loadWeb
{
    NSString *path = [[NSBundle bbsLoadBundle] pathForResource:@"/HTML_Portal/html/index" ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:[NSURL fileURLWithPath:[path stringByDeletingLastPathComponent]]];
}

- (void)registerNativeMethods
{
    [self registerGetPostMethod];
    [self registerGetForumThreadDetails];
    [self registerDownloadImages];
    [self registerOpenImage];
    [self registerOpenAttachment];
    [self registerOpenHref];
    [self registReplyComment];
    [self registImagePress];
    [self registFollowMethod];
    [self registOpenAuthor];
    [self registLikeArticle];
    [self registRelated];
    [self registShowAddress];
}

#pragma mark - 注册js方法

// TODO: 获取帖子详情
- (void)registerGetForumThreadDetails
{
    __weak typeof(self) theWebController = self;
    
    [self.jsContext registerJSMethod:@"getNewsArticleDetails" block:^(NSArray *arguments) {
        NSString *callback = nil;
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            callback = arguments[0];
        }
        
        if (self.hasContent)
        {
            NSDictionary * res = [theWebController dictionaryWithThread:_threadModel];
            [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:res]]];
        }
        else{
            [BBSSDK getPortalDetailWithAid:self.aid result:^(BBSThread *thread, NSError *error) {
                if (!error && thread)
                {
                    if([thread.title hasSuffix:@"..."]){
                        thread.title = [thread.title substringToIndex:([thread.title length]-3)];// 去掉最后一个","
                    }
                    if (self.allowcomment && [self.allowcomment integerValue] == 0)
                    {
                        thread.allowcomment = 0;
                    }
                    thread.type = @"portal";
                    thread.catname = self.catname;
                    // author和username长度截取
                    if (thread.author.length > 10) thread.author = [thread.author substringToIndex:10];
                    
                    if (thread.username.length > 10) thread.username = [thread.username substringToIndex:10];
                    
                    _threadModel = thread;
                    [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
                    [theWebController updateUI];
                    NSDictionary * res = [theWebController dictionaryWithThread:thread];
                    
                    if (callback)
                    {
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:res]]];
                    }
                }
                else
                {
                    if (self.isViewLoaded && self.view.window)
                    {
                        BBSUIAlert(@"获取详情失败:%@",error.userInfo[@"description"]);
                    }
                }
            }];
        }

    }];
}

/**
 获取评论
 */
- (void)registerGetPostMethod
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getComments" block:^(NSArray *arguments) {
        
        NSInteger aid = 0;
        NSInteger page = 0;
        NSInteger pageSize = 0;
        NSString *callback = nil;
        
//        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
//        {
//            aid = [arguments[0] integerValue];
//        }
//
//        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
//        {
//            page = [arguments[2] integerValue];
//        }
//
//        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSNumber class]])
//        {
//            pageSize = [arguments[3] integerValue];
//        }
//
//        if (arguments.count > 3 && [arguments[3] isKindOfClass:[NSString class]])
//        {
//            callback = arguments[3];
//        }
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            aid = [arguments[0] integerValue];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
        {
            page = [arguments[1] integerValue];
        }
        
        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSNumber class]])
        {
            pageSize = [arguments[2] integerValue];
        }
        
        if (arguments.count > 3 && [arguments[3] isKindOfClass:[NSString class]])
        {
            callback = arguments[3];
        }
        
        [BBSSDK getPortalCommentListWithAid:self.aid pageIndex:page pageSize:pageSize result:^(NSArray *postList, NSError *error) {
            
            NSMutableArray *postArray = [NSMutableArray array];
            
            for (BBSComment *obj in postList)
            {
                if ([obj isKindOfClass:[BBSComment class]])
                {
                    NSDictionary *postDic = [theWebController dictionaryWithComment:obj];
                    [postArray addObject:postDic];
                }
            }
            
            if (callback)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [theWebController.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:postArray]]];
                });
            }
            
            if (error && self.isViewLoaded && self.view.window)
            {
                BBSUIAlert(@"获取详情失败:%@",error.userInfo[@"description"]);
            }
            
        }];
    }];
}

/**
 下载图片
 */
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

/**
 打开详情图片
 */
- (void)registerOpenImage
{
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
            
            [BBSUIImagePreviewHUD showWithImageUrls:imageUrlsArray index:index];
            
        });
    }];
}

/**
 打开附件
 */
- (void)registerOpenAttachment
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openAttachment" block:^(NSArray *arguments) {
        
        NSLog(@"ÒÒÒÒÒÒÒÒ  %@",arguments);
        
        NSMutableDictionary *mdicAttachment = [NSMutableDictionary new];
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *attachmentDic = nil;
            attachmentDic = arguments[0];
            
            mdicAttachment[@"fileName"] = attachmentDic[@"filename"];
            mdicAttachment[@"createdOn"] = attachmentDic[@"dateline"];
            mdicAttachment[@"fileSize"] = attachmentDic[@"filesize"];
//            mdicAttachment[@"readPerm"] = attachmentDic[@"readPerm"];
            mdicAttachment[@"isImage"] = attachmentDic[@"isimage"];
//            mdicAttachment[@"width"] = attachmentDic[@"width"];
            mdicAttachment[@"uid"] = attachmentDic[@"uid"];
            mdicAttachment[@"url"] = attachmentDic[@"url"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BBSUICheckAttachmentWebViewController *checkVC = [[BBSUICheckAttachmentWebViewController alloc] initWithAttachment:mdicAttachment];
            if (theWebController.navigationController) {
                [theWebController.navigationController pushViewController:checkVC animated:YES];
            }
        });
        
    }];
}

/**
 打开链接
 */
- (void)registerOpenHref
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openHref" block:^(NSArray *arguments) {
        
        NSString *href = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]])
        {
            href = arguments[0];
        }
        
        if ([href containsString:@"mod=attachment&id="])
        {
            NSString *ID = [href componentsSeparatedByString:@"mod=attachment&id="].lastObject;
            for (BBSThreadAttachment * obj in _threadModel.attachments)
            {
                if (obj.attachid == [ID integerValue])
                {
                    // 通过附件形式打开
                    NSMutableDictionary *mdicAttachment = [NSMutableDictionary new];
                    
                    mdicAttachment[@"fileName"] = obj.filename;
                    mdicAttachment[@"createdOn"] = @(obj.dateline);
                    mdicAttachment[@"fileSize"] = @(obj.filesize);
                    //            mdicAttachment[@"readPerm"] = attachmentDic[@"readPerm"];
                    mdicAttachment[@"isImage"] = @(obj.isimage);
                    //            mdicAttachment[@"width"] = attachmentDic[@"width"];
                    mdicAttachment[@"uid"] = @(obj.uid);
                    mdicAttachment[@"url"] = obj.url;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BBSUICheckAttachmentWebViewController *checkVC = [[BBSUICheckAttachmentWebViewController alloc] initWithAttachment:mdicAttachment];
                        if (theWebController.navigationController) {
                            [theWebController.navigationController pushViewController:checkVC animated:YES];
                        }
                    });
                    
                    return;
                }
            }
        }
        
        
        // 打开连接
        dispatch_async(dispatch_get_main_queue(), ^{
            BBSUILoadUrlViewController *checkVC = [[BBSUILoadUrlViewController alloc] initWithUrl:href];
            if (theWebController.navigationController) {
                [theWebController.navigationController pushViewController:checkVC animated:YES];
            }
        });
        
    }];
}

/**
 回复评论
 */
- (void)registReplyComment
{
    __weak typeof(self) theController = self;
    [self.jsContext registerJSMethod:@"replyComment" block:^(NSArray *arguments) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            [theController presentLogin];
            return ;
        }
        
        NSDictionary *comment = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]])
        {
            comment = arguments[0];
        }
        
        NSString *name = comment[@"author"];
        NSInteger pid = [comment[@"pid"] integerValue];
        
        [self.replyEditor showWithUserName:name finishEdit:^(BOOL cancelled, NSArray<UIImage *> *images, NSString *content, NSDictionary *locationInfo) {
            if (cancelled)
            {
                return ;
            }
            [theController uploadCommentWithImages:images content:content prePid:pid locationInfo:locationInfo];
        }];
    }];
}

/**
 图片长按点击
 */
- (void)registImagePress
{
    __weak typeof(self) weakSelf = self;
    [self.jsContext registerJSMethod:@"pressImgCallback" block:^(NSArray *arguments) {
        
        NSString *src = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]])
        {
            src = arguments[0];
        }
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIPopoverPresentationController *popoverController = vc.popoverPresentationController;
        popoverController.sourceView = self.view;
        popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,self.view.frame.size.height,1.0,1.0);
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存到手机相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:src] result:^(UIImage *image, NSError *error) {
                
                UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }];
            
        }];
        
        [vc addAction:cancel];
        [vc addAction:save];
        
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

/**
 关注
 */
- (void)registFollowMethod
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"followAuthor" block:^(NSArray *arguments) {
        
        if (![BBSUIContext shareInstance].currentUser) {
            [theWebController presentLogin];
            return;
        }
        
        NSInteger authorId = -1;
        NSInteger isFollow = -1;
        NSString *callback = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            authorId = [arguments[0] integerValue];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]]) {
            isFollow = [arguments[1] integerValue];
        }
        
        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSString class]]) {
            callback = arguments[2];
        }
        
        if (callback) {
            if (isFollow == 0) {
                [BBSSDK followWithFollowuid:authorId result:^(NSError *error) {
                    if (!error) {
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(true)", callback]];
                    }else{
                        
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(false)", callback]];
                        
                        if (error.code == 9001200) {
                            [theWebController presentLogin];
                            return ;
                        }
                        
                        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:HUD];
                        if (error.code == 900404) {
                            HUD.label.text = @"Discuz论坛错误：无法关注自己";
                        }else{
                            HUD.label.text = error.userInfo[@"description"];
                        }
                        
                        HUD.contentColor = [UIColor whiteColor];
                        HUD.mode = MBProgressHUDModeText;
                        HUD.bezelView.backgroundColor = [UIColor blackColor];
                        [HUD showAnimated:YES];
                        [HUD hideAnimated:YES afterDelay:2];
                    }
                }];
            }else{
                [BBSSDK unfollowWithFollowuid:authorId result:^(NSError *error) {
                    if (!error) {
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(true)", callback]];
                    }else{
                        [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(false)", callback]];
                        
                        if (error.code == 9001200) {
                            [theWebController presentLogin];
                            return ;
                        }
                    }
                }];
            }
            
        }
        
        
        
    }];
    
}

/**
 查看其它用户
 */
- (void)registOpenAuthor
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openAuthor" block:^(NSArray *arguments) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
        else
        {
            NSInteger authorId = -1;
            
            if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
            {
                authorId = [arguments[0] integerValue];
                
                BBSUIUserOtherInfoViewController *vc = [[BBSUIUserOtherInfoViewController alloc] initWithAuthorid:authorId];
                [theWebController.navigationController pushViewController:vc animated:YES];
            }
        }
        
        //进入其他用户详情入口
    }];
    
}

/**
 赞
 */
- (void)registLikeArticle
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"likeArticle" block:^(NSArray *arguments) {
        
        if (![BBSUIContext shareInstance].currentUser) {
            [theWebController presentLogin];
            return;
        }
        
        NSInteger aid = -1;
        NSInteger clickid = 1;
        NSString *callback = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            aid = [arguments[0] integerValue];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSString class]])
        {
            callback = arguments[1];
        }
        
        [BBSSDK likePortalWithAid:aid clickid:@(clickid) result:^(NSError *error) {
            if (!error) {
                if (callback) {
                    [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(true)", callback]];
                }
            }else{
                if (callback) {
                    [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(false)", callback]];
                }
                
                if (error.code == 9001200) {
                    [theWebController presentLogin];
                    return ;
                }
                
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.contentColor = [UIColor whiteColor];
                HUD.label.text = error.userInfo[@"description"];
                HUD.mode = MBProgressHUDModeText;
                HUD.bezelView.backgroundColor = [UIColor blackColor];
                [HUD showAnimated:YES];
                [HUD hideAnimated:YES afterDelay:2];
                
            }
        }];
    
        
    }];
}


/**
 查看关联文章
 */
- (void)registRelated
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"openRelatedArticle" block:^(NSArray *arguments) {
        
        NSInteger aid = -1;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            aid = [arguments[0] integerValue];
            
            BBSUIPortalDetailViewController *portalDetail = [[BBSUIPortalDetailViewController alloc] initWithAid:aid];
            [theWebController.navigationController pushViewController:portalDetail animated:YES];
        }
        
        //进入其他用户详情入口
    }];
    
}

- (void)registShowAddress{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"showAddress" block:^(NSArray *arguments) {
        NSDictionary *comment = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]])
        {
            comment = arguments[0];
        }
        NSString *poiTitle = comment[@"POITitle"];
        float latitude = [comment[@"lat"] floatValue];
        float longitude = [comment[@"lon"] floatValue];
        CLLocationCoordinate2D coordinate = {latitude,longitude};
        BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:poiTitle];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
        [theWebController presentViewController:nav animated:YES completion:nil];
    }];
    
}

#pragma mark - click event

- (void)seeThreadOwnerOnly:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    
    NSString *js = [NSString stringWithFormat:@"BBSSDKNative.updateCommentHtml(%zd,%zd)",_threadModel.authorId,sender.selected];
    NSLog(@"excute js:%@",js);
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    
}

- (void)updateComment:(BBSComment *)comment prePid:(NSInteger)pid
{
    NSMutableDictionary *postDic = [self dictionaryWithComment:comment];
    NSString *js = [NSString stringWithFormat:@"BBSSDKNative.addNewCommentHtml(%@,%zd)",[MOBFJson jsonStringFromObject:postDic],_threadModel.authorId];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)commentButtonHandler:(UIButton *)button
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"BBSSDKNative.goComment()"];
    
}


- (void)shareButtonHandler:(UIButton *)button
{
    //    if (![BBSUIContext shareInstance].currentUser)
    //    {
    //        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
    //        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    //        [self.navigationController presentViewController:nav animated:YES completion:nil];
    //    }
    //
    //    else if(self.threadModel)
    //    {
    [[BBSUIShareView alloc] init:self.threadModel flag:1];
    //    }
    return;
}

- (void)moreButtonHandler:(UIButton *)button
{
    
    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    [orderPopoverView showToView:button withActions:[self moreActions] button:nil];
}

- (NSArray<BBSUIPopoverAction *> *)moreActions {
    
    __weak typeof(self) theController = self;
    BBSUIPopoverAction *createdOnOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"举报" handler:^(BBSUIPopoverAction *action) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            [theController presentLogin];
            return ;
        }
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.contentColor = [UIColor whiteColor];
        HUD.label.text = @"举报成功";
        HUD.mode = MBProgressHUDModeText;
        HUD.bezelView.backgroundColor = [UIColor blackColor];
        [HUD showAnimated:YES];
        [HUD hideAnimated:YES afterDelay:2];
    }];
    
    return @[createdOnOrderAction];
}

- (void)reply:(id)sender
{
    if ((self.allowcomment && self.allowcomment.integerValue == 0) || self.threadModel.allowcomment == 0)
    {
        return;
    }
    
    if (![BBSUIContext shareInstance].currentUser)
    {
        [self presentLogin];
        return ;
    }
    
    if(self.replyView.state != BBSUIReplyStateNormal)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self ;
    
    
    [self.replyEditor showWithUserName:_threadModel.author finishEdit:^(BOOL cancelled, NSArray<UIImage *> *images, NSString *content, NSDictionary *locationInfo) {
        
        if (cancelled)
        {
            return ;
        }
        
        [weakSelf uploadCommentWithImages:images content:content prePid:0 locationInfo:locationInfo];
    }];
}

- (void)uploadCommentWithImages:(NSArray *)images content:(NSString *)content prePid:(NSInteger)pid locationInfo:(NSDictionary *)locationInfo
{
    if (!(content.length || images.count))
    {
        [BBSUIProcessHUD showFailInfo:@"请输入回复内容" delay:3];
        return;
    }
    
    self.replyView.state = BBSUIReplyStateUploading;
    
    NSArray *imagesArray = images.copy;
    
    NSMutableString *comment = content.mutableCopy;
    
    if (!images.count)
    {
        [self postCommentWithHTML:content pid:pid locationInfo:locationInfo];
        return;
    }
    
    static dispatch_semaphore_t seamphore;
    static dispatch_once_t onceToken;
    static dispatch_queue_t replyImage;
    
    dispatch_once(&onceToken, ^{
        seamphore = dispatch_semaphore_create(1);
        replyImage = dispatch_queue_create("uploadReplyImage", DISPATCH_QUEUE_CONCURRENT);
    });
    
    __block NSError *postError;
    
    for (NSInteger i=0; i<imagesArray.count; i++)
    {
        dispatch_async(replyImage, ^{
            dispatch_semaphore_wait(seamphore, DISPATCH_TIME_FOREVER);
            
            NSString *path = [self pathOfsavedImage:imagesArray[i]];
            
            [BBSSDK uploadImageWithContentPath:path result:^(NSString *url, NSError *error) {
                
                if (!error && url)
                {
                    [comment appendFormat:@"<img src=\"%@\">",url];
                }
                else
                {
                    postError = error;
                }
                
                if (i==imagesArray.count-1)
                {
                    if (postError)
                    {
                        [self postCommentError:error];
                    }
                    else
                    {
                        NSLog(@"%@",comment);
                        
                        [self postCommentWithHTML:comment pid:pid locationInfo:locationInfo];
                    }
                }
                
                dispatch_semaphore_signal(seamphore);
            }];
        });
    }
}

- (void)postCommentWithHTML:(NSString *)html pid:(NSInteger)pid locationInfo:(NSDictionary *)locationInfo
{
    
    NSString *address = @"";
    NSString *poiTitle = @"";
    float lat = 0;
    float lng = 0;
    BBSLocation *location = nil;
    if (locationInfo) {
        poiTitle = locationInfo[@"name"];
        address = locationInfo[@"address"];
        NSArray *arr = [locationInfo[@"location"] componentsSeparatedByString:@","];
        if ([arr count] == 2) {
            lat = [[locationInfo[@"location"] componentsSeparatedByString:@","].firstObject floatValue];
            lng = [[locationInfo[@"location"] componentsSeparatedByString:@","].lastObject floatValue];
        }
        location = [[BBSLocation alloc] initWithPOITitle:poiTitle address:address latitude:lat longitude:lng];
    }
    
    [BBSSDK postPortalCommentWithAid:_threadModel.aid uid:_threadModel.authorId message:html location:location result:^(BBSComment *comment, NSError *error) {
        if (!error)
        {
            [self postCommentSuccess:comment prePid:pid comment:html];
        }
        else
        {
            [self postCommentError:error];
        }
    }];
}

- (void)postCommentError:(NSError *)error
{
    BBSUIAlert(@"%@",error.userInfo[@"description"]);
    
    self.replyView.state = BBSUIReplyStateFail;
    __weak typeof(self) theController = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        theController.replyView.state = BBSUIReplyStateNormal;
    });
    
    if (error.code == 9001200)
    {
        //[BBSUIDataService cacheThreadDraft:nil];
        [self presentLogin];
    }
}

#pragma mark - 回复成功
- (void)postCommentSuccess:(BBSComment *)post prePid:(NSInteger)pid comment:(NSString *)comment
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.contentColor = [UIColor whiteColor];
    HUD.label.text = @"回复成功";
    HUD.mode = MBProgressHUDModeText;
    HUD.bezelView.backgroundColor = [UIColor blackColor];
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
    
    //    post.message = comment;
    [self updateComment:post prePid:pid];
    [self.replyEditor dismiss];
    self.replyEditor = nil;
    
    self.replyView.state = BBSUIReplyStateSuccess;
    __weak typeof(self) theController = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        theController.replyView.state = BBSUIReplyStateNormal;
    });
    
    _threadModel.commentnum ++ ;
    [self updateUI];
}

- (NSDictionary *)dictionaryWithThread:(BBSThread *)thread
{
    NSMutableDictionary *threadDic = [NSMutableDictionary dictionary];
    
    threadDic[@"aid"] = @(thread.aid);
    threadDic[@"title"] = thread.title ? thread.title:@"";
    threadDic[@"author"] = thread.author ? thread.author:@"";
    threadDic[@"authorid"] = @(thread.authorid);
    threadDic[@"avatar"] =  thread.avatar ? thread.avatar:@"";
    threadDic[@"dateline"] = @(thread.dateline);
    threadDic[@"viewnum"] = @(thread.viewnum);
    threadDic[@"commentnum"] = @(thread.commentnum);
    threadDic[@"sharetimes"] = @(thread.sharetimes);
    threadDic[@"favtimes"] = @(thread.favtimes);
    threadDic[@"summary"] = thread.summary ? thread.summary:@"";
    threadDic[@"content"] = thread.content ? thread.content:@"";
    threadDic[@"pic"] = thread.pic ? thread.pic:@"";
    threadDic[@"click1"] = @(thread.click1);
    threadDic[@"click2"] = @(thread.click2);
    threadDic[@"click3"] = @(thread.click3);
    threadDic[@"click4"] = @(thread.click4);
    threadDic[@"click5"] = @(thread.click5);
    threadDic[@"allowcomment"] = @(thread.allowcomment);
    threadDic[@"related"] = thread.related;
    if (thread.related.count > 3)
    {
        threadDic[@"related"] = @[thread.related[0], thread.related[1], thread.related[2]];
    }
    
    threadDic[@"username"] = thread.username? thread.username:@"";
    threadDic[@"uid"] = @(thread.originUid);
    
    
    NSMutableArray *attachments = [NSMutableArray array];
    
    // 附件
    for (BBSThreadAttachment * obj in thread.attachments)
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        dic[@"filename"] = obj.filename;
        NSString *extension = [obj.filename pathExtension];
        if (extension) {
            dic[@"extension"] = extension;
        }
        dic[@"filetype"] = obj.filetype;
        dic[@"dateline"] = @(obj.dateline);
        dic[@"thumb"] = @(obj.thumb);
        dic[@"isimage"] = @(obj.isimage);
        dic[@"filesize"] = @(obj.filesize);
        dic[@"attachid"] = @(obj.attachid);
        dic[@"remote"] = @(obj.remote);
        dic[@"aid"] = @(obj.aid);
        dic[@"url"] = obj.url;
        
        [attachments addObject:dic];
    }
    
        threadDic[@"attachments"] = attachments;
    
    return threadDic ;
}

- (NSMutableDictionary *)dictionaryWithComment:(BBSComment *)comment
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    postDic[@"cid"] = @(comment.cid);
    postDic[@"id"] = @(comment.ID);
    postDic[@"idtype"] = comment.idtype;
    postDic[@"username"] = comment.username;
    postDic[@"uid"] = @(comment.uid);
    postDic[@"avatar"] = comment.avatar;
    postDic[@"dateline"] = @(comment.dateline);
    postDic[@"message"] = comment.message;
    postDic[@"postip"] = comment.postip;
    postDic[@"status"] = @(comment.status);
    postDic[@"deviceName"] = comment.fromType;
    postDic[@"POITitle"] = comment.poiTitle;
    postDic[@"lat"] = @(comment.latitude);
    postDic[@"lon"] = @(comment.longitude);
    return postDic;
}

- (NSString *)pathOfsavedImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageMd5 = [MOBFData stringByMD5Data:data];
    
    NSString *path = [imageMd5 stringByAppendingString:@".jpeg"];
    
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    
    NSLog(@"%@",cachePath);
    
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createFileAtPath:cachePath contents:nil attributes:nil];
        [data writeToFile:cachePath atomically:NO];
    }
    return cachePath ;
}


- (BBSUIReplyEditor *)replyEditor
{
    if (!_replyEditor)
    {
        _replyEditor = [[BBSUIReplyEditor alloc] init];
        _replyEditor.isPortal = YES;
        
        if ([[BBSUILBSLocationProxy sharedInstance] isLBSUsable])
        {
            _replyEditor.isHiddenLBSMenu = NO;
        }
        else
        {
            _replyEditor.isHiddenLBSMenu = YES;
        }
    }
    
    return _replyEditor;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
    if (error)
    {
        BBSUIAlert(@"保存失败:%@",error);
    }
}

#pragma mark - private methods
- (void)presentLogin
{
    [BBSUIContext shareInstance].currentUser = nil;
    [BBSSDK logout:nil];
    
    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
