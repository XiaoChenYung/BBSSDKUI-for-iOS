//
//  BBSUIThreadDetailViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadDetailViewController.h"
#import <BBSSDK/BBSThread.h>
#import "Masonry.h"
#import "BBSUIMacro.h"
#import "BBSUIReplyEditor.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSThreadAttachment.h>
#import <BBSSDK/BBSPost.h>
#import "BBSUIModelToObject.h"
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
#import "UIDevice+Model.h"

@interface BBSUIThreadDetailViewController ()

@property (nonatomic, strong) BBSThread *threadModel;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) BBSUIReplyEditor *replyEditor;
@property (nonatomic, strong) BBSJSImageDownload *imageDownload;
@property (nonatomic, strong) BBSUIReplyStateView *replyView;
@property (nonatomic, assign) NSInteger fid;
@property (nonatomic, assign) NSInteger tid;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, assign) BOOL isFavirated;
@property (nonatomic, strong) NSMutableArray *htmlArr;
@end

@implementation BBSUIThreadDetailViewController

+ (NSString *)MLSDKPath
{
    return @"/thread/detail";
}

- (instancetype)initWithMobLinkScene:(BBSMOBFScene *)scene;
{
    self = [super init];
    if (self)
    {
        NSDictionary *sceneDict = [scene getParams];
        self.fid = [sceneDict[@"fid"] integerValue];
        self.tid = [sceneDict[@"tid"] integerValue];
    }
    return self;
}

- (instancetype)initWithFid:(NSInteger)fid tid:(NSInteger)tid
{
    if (self = [super init]) {
        self.fid = fid;
        self.tid = tid;
    }
    
    return self;
}

- (instancetype)initWithThreadModel:(BBSThread *)model
{
    if (self = [super init])
    {
        self.threadModel = model;
        self.fid = self.threadModel.fid;
        self.tid = self.threadModel.tid;
    }
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupJSNativeWithNativeExtPath:@"/HTML/mobforum/assets/js/NativeExt"];
    [self registerNativeMethods];//注册本地native方法
    [self setup];
    NSLog(@"进来了");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //导航栏
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setTranslucent:YES];
    //状态栏
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    
    if ([[BBSUIContext shareInstance].currentUser.uid integerValue] == _threadModel.authorId) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //导航栏
//    [self.navigationController.navigationBar setBarTintColor:DZSUIColorFromHex(0x5B7EF0)];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    //状态栏
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setup
{
    self.webView.backgroundColor = [UIColor whiteColor];
    self.title = @"帖子详情";
    self.webView.delegate = self ;
    [self setBarButtonItem];
    self.replyEditor = [[BBSUIReplyEditor alloc] init];
    if ([[BBSUILBSLocationProxy sharedInstance] isLBSUsable])
    {
        self.replyEditor.isHiddenLBSMenu = NO;
    }
    else
    {
        self.replyEditor.isHiddenLBSMenu = YES;
    }
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
    
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBar];
    NSInteger offset = [[UIDevice currentDevice] inner_isIphoneXOrLater] ? -34 : 0;
    NSLog(@"高度%@", @(offset));
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).mas_offset(offset);
        make.height.mas_equalTo(50);
    }];
    self.bottomBar = bottomBar;
    
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(bottomBar.mas_top);
    }];
    
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
    shareButton.hidden = true;
    _favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:_favButton];
    _favButton.hidden = true;
    [_favButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(shareButton.mas_left).with.offset(-15);
        make.centerY.equalTo(shareButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_favButton addTarget:self action:@selector(favButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favDeselected@2x.png"] forState:UIControlStateNormal];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:_commentButton];
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomBar).with.offset(-7);
        make.centerY.equalTo(self.favButton.mas_centerY);
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
        [replyView addTapGestureRecognizerWithTarget:self action:@selector(reply:)];
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
    if (_threadModel.replies > 0) {
        [_commentButton bbs_MakeBadgeText:[NSString stringWithFormat:@"%zd", _threadModel.replies] textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont systemFontOfSize:12]];
    }
    
    if (_threadModel.favid != 0) {
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favSelected@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = YES;
    }else{
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favDeselected@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = NO;
    }
    
//    if (_threadModel.authorId == [[BBSUIContext shareInstance].currentUser.uid integerValue]) {
//        [self.favButton setEnabled:NO];
//    }
}

- (void)loadWeb
{
    NSString *path = [[NSBundle bbsLoadBundle] pathForResource:@"/HTML/mobforum/html/index" ofType:@"html"];
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
    [self registShowAddress];
}

#pragma mark - 注册js方法
// TODO: 获取帖子详情
- (void)registerGetForumThreadDetails
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getForumThreadDetails" block:^(NSArray *arguments) {
        NSString *callback = nil;
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            callback = arguments[0];
        }
        
        [BBSSDK getThreadDetailWithFid:self.fid tid:self.tid result:^(BBSThread *thread, NSError *error) {
            if (!error && thread)
            {
                _threadModel = thread;
                 [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
                [theWebController updateUI];
                NSDictionary * res = [theWebController dictionaryWithThread:thread];
                NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] initWithDictionary:res];
                NSLog(@"bbs message: %@", res);
                if ([BBSSDK isUsePlug])
                {
                    mutDic[@"isPlug"] = @1;
                }
                else
                {
                    mutDic[@"isPlug"] = @0;
                }
                
                if (callback)
                {
                    [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:mutDic]]];
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
    }];
}

/**
 获取评论
 */
- (void)registerGetPostMethod
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getPosts" block:^(NSArray *arguments) {
        
        NSInteger fid = 0;
        NSInteger tid = 0;
        NSInteger page = 0;
        NSInteger pageSize = 0;
        NSInteger authorID = 0;
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
        
        if (arguments.count > 4 && [arguments[4] isKindOfClass:[NSNumber class]] )
        {
            authorID = [arguments[4] integerValue];
        }
        
        if (arguments.count > 5 && [arguments[5] isKindOfClass:[NSString class]])
        {
            callback = arguments[5];
        }

        [BBSSDK getPostListWithFid:fid tid:tid authorId:authorID pageIndex:page pageSize:pageSize result:^(NSArray *postList, NSError *error) {
            
            NSMutableArray *postArray = [NSMutableArray array];

            for (BBSPost *obj in postList)
            {
                NSLog(@"bbs message: %@", obj.message);
                if ([obj isKindOfClass:[BBSPost class]])
                {
                    
                    //NSDictionary *postDic = [BBSUIModelToObject objectFromPostModel:obj];
                    //[postArray addObject:postDic];
                    
                    //=====去除插件的来自====
                    NSDictionary *postDic = [BBSUIModelToObject objectFromPostModel:obj];
                    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:postDic];
                    
                    if ([BBSSDK isUsePlug])
                    {
                        res[@"isPlug"] = @1;
                    }
                    else
                    {
                        res[@"isPlug"] = @0;
                    }
                    [postArray addObject:res];
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
        
        /*
         (lldb) po arguments
         <__NSArrayM 0x283f270c0>(
         <__NSArrayM 0x283f24ba0>(
         http://182.92.158.79/utf8_x33_demo_link/data/attachment/forum/201707/24/122930lhlb40w9u99c0cl4.jpeg
         )
         )
         
         */
        NSLog(@"____________ %@",arguments);
        NSArray *imageUrlsArray = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSArray class]])
        {
            imageUrlsArray = arguments[0];
        }
        
        if (imageUrlsArray.count > 0) {
            //MARK:-把if (!theWebController.imageDownload) 修复一个bug，当评论的地方有图片时，加载更多会出现图片加载失败
            //if (!theWebController.imageDownload) {
                theWebController.imageDownload = [[BBSJSImageDownload alloc] initWithJSContext:theWebController.jsContext imageArray:imageUrlsArray isImageViewer:NO webView:theWebController.webView];
            //}

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
        
        NSLog(@"-------打开图片-----%@", arguments);
        
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
        
        NSDictionary *attachmentDic = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]])
        {
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
                        if (error.code == 90090608) {
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
//    __weak typeof(self) theWebController = self;
//    [self.jsContext registerJSMethod:@"openAuthor" block:^(NSArray *arguments) {
//        
//        if (![BBSUIContext shareInstance].currentUser)
//        {
//            BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
//        }
//        else
//        {
//            NSInteger authorId = -1;
//            
//            if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
//            {
//                authorId = [arguments[0] integerValue];
//                BBSUIUserOtherInfoViewController *vc = [[BBSUIUserOtherInfoViewController alloc] initWithAuthorid:authorId];
//                [theWebController.navigationController pushViewController:vc animated:YES];
//            }
//        }
//        //进入其他用户详情入口
//    }];

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
        
        NSInteger fid = -1;
        NSInteger tid = -1;
        NSString *callback = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            fid = [arguments[0] integerValue];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
        {
            tid = [arguments[1] integerValue];
        }
        
        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSString class]])
        {
            callback = arguments[2];
        }
        
        [BBSSDK likeThreadWithFid:fid tid:tid result:^(NSError *error) {
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
                if (error.code ==  90090614)
                {
                    HUD.label.text = @"已评价过本主题";
                }
                else if([error.userInfo[@"code"] isEqualToString:@"900700613"])
                {
                    HUD.label.text = @"不能评价自己的帖子";
                }
                else
                {
                    HUD.label.text = error.userInfo[@"description"];
                }
                
                HUD.mode = MBProgressHUDModeText;
                HUD.bezelView.backgroundColor = [UIColor blackColor];
                [HUD showAnimated:YES];
                [HUD hideAnimated:YES afterDelay:2];
                
            }
        }];
        
    }];
}

- (void)registShowAddress
{
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

- (void)updateComment:(BBSPost *)post prePid:(NSInteger)pid
{
    NSMutableDictionary *postDic = [self dictionaryWithPost:post];
    
    if (post.prePost)
    {
        post.prePost.pid = pid;
        postDic[@"prePost"] = [self dictionaryWithPost:post.prePost];
    }
    
    NSString *js = [NSString stringWithFormat:@"BBSSDKNative.addNewCommentHtml(%@,%zd)",[MOBFJson jsonStringFromObject:postDic],_threadModel.authorId];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)commentButtonHandler:(UIButton *)button
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"BBSSDKNative.goComment()"];

}

/**
 收藏

 @param button 收藏按钮
 */
- (void)favButtonHandler:(UIButton *)button
{
    if (![BBSUIContext shareInstance].currentUser) {
        [self presentLogin];
        return;
    }
    
    button.enabled = NO;
    __weak typeof(self) theController = self;
    if (self.isFavirated) {
        [BBSSDK unFavoriteThreadWithFavid:[NSString stringWithFormat:@"%zd", _threadModel.favid] result:^(NSError *error) {
            if (!error) {
                [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favDeselected@2x.png"] forState:UIControlStateNormal];
                theController.isFavirated = !theController.isFavirated;
            }else{
                
                if (error.code == 9001200) {
                    [theController presentLogin];
                    return ;
                }
                
                BBSUIAlert(@"取消收藏失败");
            }
            button.enabled = YES;
        }];
    }else{
        
        [BBSSDK favoriteThreadWithFid:self.fid tid:self.tid result:^(NSDictionary *favorite, NSError *error) {
            
            if (!error) {
                if (favorite[@"favid"] && [favorite[@"favid"] isKindOfClass:[NSNumber class]]) {
                    _threadModel.favid = [favorite[@"favid"] integerValue];
                }
                [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favSelected@2x.png"] forState:UIControlStateNormal];
                theController.isFavirated = !theController.isFavirated;
            }else{
                
                if (error.code == 9001200) {
                    [theController presentLogin];
                }else{
                    BBSUIAlert(@"收藏失败");
                }
                
            }
            button.enabled = YES;
            
            
        }];
        
    };
}

#pragma mark - 分享

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
        [[BBSUIShareView alloc] init:self.threadModel flag:0];
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
        
        BBSUIAccusationViewController *accusationVC = [[BBSUIAccusationViewController alloc] initWithThread:theController.threadModel];
        [theController.navigationController pushViewController:accusationVC animated:YES];
        
        
    }];
    
    BBSUIPopoverAction *blockUserAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"拉黑用户" handler:^(BBSUIPopoverAction *action) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            [theController presentLogin];
            return ;
        }
        
        UIAlertController *blockVC = [UIAlertController alertControllerWithTitle:nil message:@"拉黑用户，你将不再看到该用户的发帖" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *blockCancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *blockConfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"拉黑成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:true];
                    [[NSUserDefaults standardUserDefaults] setObject: @(self.threadModel.authorId) forKey:@"BlockUserID"];
                }];
                [alertVC addAction:confirmAction];
                //        BBSUIAccusationViewController *accusationVC = [[BBSUIAccusationViewController alloc] initWithThread:theController.threadModel];
                //        [theController.navigationController pushViewController:accusationVC animated:YES];
                [self presentViewController:alertVC animated:true completion:nil];
            });
            
            //1.创建会话对象
            NSURLSession *session = [NSURLSession sharedSession];
            NSString *urlStr = [NSString stringWithFormat:@"http://47.105.63.78:34003/appapi/index.php?mod=user_addblack&buid=%@", [BBSUIContext shareInstance].currentUser.uid];
            //2.根据会话对象创建task
            NSURL *url = [NSURL URLWithString:urlStr];
            
            //3.创建可变的请求对象
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            //4.修改请求方法为POST
            request.HTTPMethod = @"GET";
            
            //5.设置请求体
            //        request.HTTPBody = [@"username=520it&pwd=520it&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
            
            //6.根据会话对象创建一个Task(发送请求）
            /*
             第一个参数：请求对象
             第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
             data：响应体信息（期望的数据）
             response：响应头信息，主要是对服务器端的描述
             error：错误信息，如果请求失败，则error有值
             */
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                //8.解析数据
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"返回数据%@",dict);
                
            }];
            
            //7.执行任务
            [dataTask resume];
        }];
        [blockVC addAction:blockCancelAction];
        [blockVC addAction:blockConfirmAction];
        [self presentViewController:blockVC animated:true completion:nil];
        
    }];
    
    return @[createdOnOrderAction, blockUserAction];
}

#pragma mark - 弹出键盘写回复
- (void)reply:(id)sender
{
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

#pragma mark - ======发评论成功回调========
- (void)postCommentWithHTML:(NSString *)html pid:(NSInteger)pid locationInfo:(NSDictionary *)locationInfo
{
    NSString *address = @"";
    NSString *poiTitle = @"";
    float lat = 0;
    float lng = 0;
    BBSLocation *location = nil;
    if (locationInfo) {
        address = locationInfo[@"address"];
        poiTitle = locationInfo[@"name"];
        NSArray *arr = [locationInfo[@"location"] componentsSeparatedByString:@","];
        if ([arr count] == 2) {
            lat = [[locationInfo[@"location"] componentsSeparatedByString:@","].firstObject floatValue];
            lng = [[locationInfo[@"location"] componentsSeparatedByString:@","].lastObject floatValue];
        }
        location = [[BBSLocation alloc] initWithPOITitle:poiTitle address:address latitude:lat longitude:lng];
    }
    //发评论
    __weak typeof(self) theWebController = self;
    [BBSSDK postCommentWithFid:_threadModel.fid tid:_threadModel.tid reppid:pid message:html location:location result:^(BBSPost *post,NSError *error) {
        if (!error)
        {
            [theWebController postCommentSuccess:post prePid:pid comment:html];
            
            if (pid == 0 && _threadModel.replyShow == 1)
            {
                [self _reLoadWebView];
            }
        }
        else
        {
            [self postCommentError:error];
        }
        
#pragma mark --- 评论数目
        NSLog(@"----pppp----000-%ld", (long)_threadModel.commentnum);
        _threadModel.commentnum = _threadModel.commentnum + 1;
        [[BBSUICoreDataManage shareManager] addHistoryWithThread:_threadModel];
        
        NSLog(@"----pppp---1111--%ld", (long)_threadModel.commentnum);
    }];
}

- (void)_reLoadWebView
{
    __weak typeof(self) theWebController = self;
    [BBSSDK getThreadDetailWithFid:theWebController.fid tid:theWebController.tid result:^(BBSThread *thread, NSError *error) {
        if (!error && thread)
        {
            _threadModel = thread;
            [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
            [theWebController updateUI];
            NSDictionary * res = [theWebController dictionaryWithThread:thread];
            [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", @"details.getArticle", [MOBFJson jsonStringFromObject:res]]];
            
        }
        else
        {
            if (theWebController.isViewLoaded && theWebController.view.window)
            {
                BBSUIAlert(@"获取详情失败:%@",error.userInfo[@"description"]);
            }
        }
    }];
}

- (void)postCommentError:(NSError *)error
{
    BBSUIAlert(@"%@",error.userInfo[@"description"]);
    NSLog(@"发帖错误:%@", error.userInfo);
    self.replyView.state = BBSUIReplyStateFail;
    __weak typeof(self) theController = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        theController.replyView.state = BBSUIReplyStateNormal;
    });
    
    if (error.code == 9001200)
    {
//        [BBSUIDataService cacheThreadDraft:nil];
        [self presentLogin];
    }
}

#pragma mark - 回复成功
- (void)postCommentSuccess:(BBSPost *)post prePid:(NSInteger)pid comment:(NSString *)comment
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
    
    _threadModel.replies ++ ;
    [self updateUI];
}

- (NSDictionary *)dictionaryWithThread:(BBSThread *)thread
{
    NSMutableDictionary *threadDic = [NSMutableDictionary dictionary];
    
    threadDic[@"tid"] = @(thread.tid);
    threadDic[@"fid"] = @(thread.fid);
    threadDic[@"subject"] = thread.subject;
    threadDic[@"message"] = thread.message;
    threadDic[@"summary"] = thread.summary;
    threadDic[@"replies"] = @(thread.replies);
    threadDic[@"heats"] =  @(thread.heatLevel);
    threadDic[@"displayOrder"] = @(thread.displayOrder);
    threadDic[@"digest"] = @(thread.digest);
    threadDic[@"highLight"] = @(thread.highLight);
    threadDic[@"images"] = thread.images;
    threadDic[@"author"] = thread.author;
    threadDic[@"authorId"] = @(thread.authorId);
    threadDic[@"avatar"] = thread.avatar;
    threadDic[@"username"] = thread.username;
    threadDic[@"createdOn"] = @(thread.createdOn);
    threadDic[@"replies"] = @(thread.replies);
    threadDic[@"views"] = @(thread.views);
    threadDic[@"forumName"] = thread.forumName;
    threadDic[@"favid"] = @(thread.favid);
    threadDic[@"follow"] = @(thread.follow);
    threadDic[@"favtimes"] = @(thread.favtimes);
    threadDic[@"recommend_add"] = @(thread.recommend_add);
    threadDic[@"recommend_sub"] = @(thread.recommend_sub);
    threadDic[@"recommends"] = @(thread.recommends);
    threadDic[@"threadurl"] = thread.threadurl;
    threadDic[@"POITitle"] = thread.poiTitle;
    threadDic[@"lat"] = @(thread.latitude);
    threadDic[@"lon"] = @(thread.longitude);
    
    NSMutableArray *attachments = [NSMutableArray array];
    for (BBSThreadAttachment * obj in thread.attachments)
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        dic[@"fileName"] = obj.fileName;
        NSString *extension = [obj.fileName pathExtension];
        if (extension) {
            dic[@"extension"] = extension;
        }
        dic[@"createdOn"] = @(obj.createdOn);
        dic[@"fileSize"] = @(obj.fileSize);
        dic[@"readPerm"] = @(obj.readPerm);
        dic[@"isImage"] = @(obj.isImage);
        dic[@"width"] = @(obj.width);
        dic[@"uid"] = @(obj.uid);
        dic[@"url"] = obj.url;
        
        [attachments addObject:dic];
    }
    threadDic[@"attachments"] = attachments;
    
    return threadDic ;
}

- (NSMutableDictionary *)dictionaryWithPost:(BBSPost *)post
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    postDic[@"author"] = post.author;
    postDic[@"authorId"] = @(post.authorId);
    postDic[@"avatar"] = post.avatar;
    postDic[@"createdOn"] = @(post.createdOn);
    postDic[@"fid"] = @(post.fid);
    postDic[@"pid"] = @(post.pid);
    postDic[@"position"] = @(post.position);
    postDic[@"tid"] = @(post.tid);
    postDic[@"useIp"] = post.useIp;
    postDic[@"message"] = post.message;
    postDic[@"deviceName"] = post.deviceName;
    postDic[@"POITitle"] = post.poiTitle;
    postDic[@"lat"] = @(post.latitude);
    postDic[@"lon"] = @(post.longitude);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.mob.bbs.sdk.BBSNeedLogin" object:nil];
//    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:nil];
}


@end
