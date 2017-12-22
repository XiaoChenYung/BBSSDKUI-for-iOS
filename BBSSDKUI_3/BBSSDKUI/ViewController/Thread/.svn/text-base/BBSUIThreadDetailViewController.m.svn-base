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
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSThreadAttachment.h>
#import <BBSSDK/BBSPost.h>
#import "BBSUIModelToObject.h"
#import "BBSJSImageDownload.h"
#import "BBSUIImagePreviewHUD.h"
#import "BBSUICheckAttachmentWebViewController.h"
#import "BBSUILoadUrlViewController.h"
#import "BBSUIContext.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "BBSUILoginViewController.h"
#import "BBSUIProcessHUD.h"
#import "UIImage+BBSFunction.h"
#import "UIView+Badge.h"
#import "BBSUIUserOtherInfoViewController.h"
#import "PopoverView.h"
#import "BBSUIAccusationViewController.h"
#import "BBSUIProcessHUD.h"
#import "MBProgressHUD.h"
#import "BBSUICoreDataManage.h"
#import "BBSUIShareView.h"
#import "BBSUICommentTextView.h"
#import <MOBFoundation/MOBFImage.h>
#import "BBSUICacheManager.h"
#import <MobLink/IMOBFLinkComponent.h>
#import <MOBFoundation/MOBFComponentManager.h>

@interface BBSUIThreadDetailViewController ()

@property (nonatomic, strong) BBSThread             *threadModel;
@property (nonatomic, strong) UIView                *bottomBar; //底部操作栏
@property (nonatomic, strong) UIView                *replyView; //回复操作栏
@property (nonatomic, strong) BBSJSImageDownload    *imageDownload;
@property (nonatomic, assign) NSInteger             fid;
@property (nonatomic, assign) NSInteger             tid;
@property (nonatomic, strong) UIButton              *commentButton;
@property (nonatomic, strong) UIButton              *likeButton;
@property (nonatomic, strong) UIButton              *favButton;
@property (nonatomic, assign) BOOL                  isFavirated;
@property (nonatomic, strong) BBSUICommentTextView  *commentTextView; //回复视图


@end

@implementation BBSUIThreadDetailViewController

+ (NSString *)MLSDKPath
{
    return @"/thread/detail";
}

- (instancetype)initWithMobLinkScene:(id<IMOBFScene>)scene;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNativeMethods];//注册本地native方法
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)setup
{
    self.webView.delegate = self ;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self setBarButtonItem];
//    self.replyEditor = [[BBSUIReplyEditor alloc] init];
    [self configBottomBar];
    [self loadWeb];
}

- (void)setBarButtonItem
{
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setFrame:CGRectMake(0, 0, 44, 44)];
    [shareButton setImage:[UIImage BBSImageNamed:@"/Thread/share@2x.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage BBSImageNamed:@"/Thread/more@2x.png"] forState:UIControlStateNormal];
    [moreButton setFrame:CGRectMake(0, 0, 44, 44)];
    [moreButton addTarget:self action:@selector(moreButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItems = @[rightBarButtonItem, shareButtonItem];
    
}

- (void)configBottomBar
{
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).with.offset(-100);
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
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:self.commentButton];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.bottomBar).with.offset(0);
        make.width.mas_equalTo(@(DZSUIScreen_width / 3));
    }];
    [self.commentButton.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:10]];
    [self.commentButton setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self.commentButton setImage:[UIImage BBSImageNamed:@"/Thread/CommentItem@2x.png"] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setTitle:@"0" forState:UIControlStateNormal];
    [self.commentButton setContentMode:UIViewContentModeCenter];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:self.likeButton];
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomBar).with.offset(0);
        make.left.equalTo(self.commentButton.mas_right);
        make.width.mas_equalTo(@(DZSUIScreen_width / 3));
    }];
    [self.likeButton.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:10]];
    [self.likeButton setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage BBSImageNamed:@"/Thread/LikeItem@2x.png"] forState:UIControlStateNormal];
    [self.likeButton setTitle:@"0" forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(_likeButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton setContentMode:UIViewContentModeCenter];
    
    self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:self.favButton];
    [self.favButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.bottomBar).with.offset(0);
        make.width.mas_equalTo(@(DZSUIScreen_width / 3));
    }];
    [self.favButton.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:10]];
    [self.favButton setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self.favButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Thread/FavItem@2x.png"] withSize:CGSizeMake(17.5*2, 17.5*2)] forState:UIControlStateNormal];
    [self.favButton setTitle:@"0" forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.favButton setContentMode:UIViewContentModeCenter];

    
    self.replyView = [UIView new];
    [self.view addSubview:self.replyView];
    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.bottomBar.mas_top).with.offset(0);
        make.height.mas_equalTo(@50);
    }];
    [self.replyView setBackgroundColor:[UIColor whiteColor]];
    UITapGestureRecognizer *replyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyViewTap:)];
    replyViewTap.numberOfTouchesRequired = 1;
    [self.replyView addGestureRecognizer:replyViewTap];
    
    UILabel *tipLabel = [UILabel new];
    [self.replyView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.replyView).with.offset(15);
        make.right.equalTo(self.replyView).with.offset(-15);
        make.centerY.equalTo(self.replyView.mas_centerY);
        make.height.mas_equalTo(@31);
    }];
    [tipLabel setFont:[UIFont fontWithName:@".PingFangSC-Regular" size:12]];
    [tipLabel setTextColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0]];
    tipLabel.layer.borderColor = [[UIColor grayColor] CGColor];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat boarderWidth = scale > 0.0 ? 1.0 / scale : 1.0;
    tipLabel.layer.borderWidth = boarderWidth;
    tipLabel.layer.cornerRadius = 2;
    [tipLabel setText:@"写点评论..."];
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    
}

- (BBSUICommentTextView *)commentTextView
{
    if (!_commentTextView) {
        _commentTextView =[BBSUICommentTextView topTextView];
        [self.view addSubview:_commentTextView];
    }
    
    return _commentTextView;
}

- (void)updateUI
{
//    if (_threadModel.replies > 0) {
//        [_commentButton yee_MakeBadgeText:[NSString stringWithFormat:@"%zd", _threadModel.replies] textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont systemFontOfSize:12]];
//    }
    [_commentButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.replies] forState:UIControlStateNormal];
    [_likeButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.recommend_add] forState:UIControlStateNormal];
    [_favButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.favtimes] forState:UIControlStateNormal];
    
    if (_threadModel.favid != 0) {
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favSelected@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = YES;
    }else{
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/FavItem@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = NO;
    }
    
    NSMutableDictionary *likedThreadDictionary = [[BBSUICacheManager sharedInstance] getLikedThreadDictionaryWithUid:[BBSUIContext shareInstance].currentUser.uid];
    if (likedThreadDictionary) {
        if (likedThreadDictionary[@(_threadModel.tid)]) {
            BOOL isLiked = [likedThreadDictionary[@(_threadModel.tid)] boolValue];
            if (isLiked) {
                [_likeButton setImage:[UIImage BBSImageNamed:@"/Thread/LikeSelected@2x.png"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)loadWeb
{
    NSString *path = [[NSBundle bbsLoadBundle] pathForResource:@"/HTML/html/index" ofType:@"html"];
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
}

#pragma mark - 注册js方法
/**
 获取帖子详情
 */

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
                
                // 添加历史记录
                [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
                
                [theWebController updateUI];
                NSMutableDictionary * res = [theWebController dictionaryWithThread:thread].mutableCopy;
                
                if (!res[@"forumPic"] || !((NSString *)res[@"forumPic"]).length)
                {
                    NSString *forumPic = [[NSBundle mainBundle] pathForResource:@"BBSSDKUI.bundle/Forum/forumList3" ofType:@"png"];
                    
                    res[@"forumPic"] = forumPic;
                }
                
                if (callback)
                {
                    [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:res]]];
                }
            }
            else
            {
                NSLog(@"getDetail error: %@",error);
                
                if (self.isViewLoaded && self.view.window)
                {
                    if (error.code == 99999) {
                        BBSUIAlert(@"未连接网络");
                    }else{
                        BBSUIAlert(@"获取详情失败:%@,code:%zd",error.userInfo[@"description"],error.code);
                    }
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
                if ([obj isKindOfClass:[BBSPost class]])
                {
                    NSDictionary *postDic = [BBSUIModelToObject objectFromPostModel:obj];
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
                BBSUIAlert(@"获取详情失败:%@,code:%zd",error.userInfo[@"description"],error.code);
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
 打开附件、下载附件
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
        
        [theController.commentTextView.countNumTextView becomeFirstResponder];
        NSString *placeHolder = [NSString stringWithFormat:@"回复 %@ 的评论", name];
        [theController.commentTextView.countNumTextView setPlaceholder:placeHolder];
        [theController.commentTextView setSendHandler:^(NSArray<UIImage *> *images, NSString *content) {
            
            [theController uploadCommentWithImages:images content:content prePid:pid];
            
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
        popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,DZSUIScreen_height,1.0,1.0);
        
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
                HUD.label.text = error.userInfo[@"description"];
                HUD.mode = MBProgressHUDModeText;
                HUD.bezelView.backgroundColor = [UIColor blackColor];
                [HUD showAnimated:YES];
                [HUD hideAnimated:YES afterDelay:2];
                
            }
        }];
        
    }];
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
                [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/FavItem@2x.png"] forState:UIControlStateNormal];
                theController.isFavirated = !theController.isFavirated;
                //更新界面
                NSInteger favCount = [_favButton.titleLabel.text integerValue];
                [_favButton setTitle:[NSString stringWithFormat:@"%zd", (favCount - 1 >= 0 ? (favCount - 1) : 0)] forState:UIControlStateNormal];
            }else{
                
                if (error.code == 9001200) {
                    [theController presentLogin];
                    return ;
                }
                
                BBSUIAlert(@"取消收藏失败:%@",error);
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
                
                //更新界面
                NSInteger favCount = [_favButton.titleLabel.text integerValue];
                [_favButton setTitle:[NSString stringWithFormat:@"%zd", favCount + 1] forState:UIControlStateNormal];
            }else{
                
                if (error.code == 9001200) {
                    [theController presentLogin];
                }else{
                    BBSUIAlert(@"收藏失败:%@",error);
                }
                
            }
            button.enabled = YES;
            
            
        }];
        
    };
}

- (void)_likeButtonHandler:(UIButton *)button
{
    if (![BBSUIContext shareInstance].currentUser) {
        [self presentLogin];
        return;
    }
    
    __weak typeof(self) theController = self;
    [BBSSDK likeThreadWithFid:self.fid tid:self.tid result:^(NSError *error) {
        
        if (error.code == 9001200) {
            [self presentLogin];
            return ;
        }
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.contentColor = [UIColor whiteColor];
        HUD.mode = MBProgressHUDModeText;
        HUD.bezelView.backgroundColor = [UIColor blackColor];
        [HUD showAnimated:YES];
        [HUD hideAnimated:YES afterDelay:2];
        if (!error) {
            [self.webView stringByEvaluatingJavaScriptFromString:@"BBSSDKNative.likeThread()"];
            
            NSLog(@"————————————————————");
            
            HUD.label.text = @"赞成功";
            NSInteger likeCount = [_likeButton.titleLabel.text integerValue];
            [_likeButton setTitle:[NSString stringWithFormat:@"%zd", likeCount + 1] forState:UIControlStateNormal];
            [self _saveLikedThread];
            
        }else{
            HUD.label.text = error.userInfo[@"description"];
            
            if ([[BBSUIContext shareInstance].currentUser.uid integerValue] == theController.threadModel.authorId) {
                return;
            }
            
            if (!error.code) {
                [self _saveLikedThread];
            }
        }
    }];
}

- (void)_saveLikedThread
{
    [_likeButton setImage:[UIImage BBSImageNamed:@"/Thread/LikeSelected@2x.png"] forState:UIControlStateNormal];
    
    NSMutableDictionary *likedThreadDictionary = [[BBSUICacheManager sharedInstance] getLikedThreadDictionaryWithUid:[BBSUIContext shareInstance].currentUser.uid];
    [likedThreadDictionary setObject:@(YES) forKey:@(self.threadModel.tid)];
    [[BBSUICacheManager sharedInstance] setLikedThreadDictionary:likedThreadDictionary uid:[BBSUIContext shareInstance].currentUser.uid];
}

- (void)shareButtonHandler:(UIButton *)button
{
//    if (![BBSUIContext shareInstance].currentUser)
//    {
//        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//    }
//    else if(self.threadModel)
//    {
        [[BBSUIShareView sharedInstance] createShareViewWithContent:self.threadModel animation:YES];
//    }
    
    return;
}

- (void)moreButtonHandler:(UIButton *)button
{
    
    PopoverView *orderPopoverView = [PopoverView popoverView];
    [orderPopoverView showToView:button withActions:[self moreActions] button:nil];
}

- (NSArray<PopoverAction *> *)moreActions {
    
    __weak typeof(self) theController = self;
    PopoverAction *createdOnOrderAction = [PopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"举报" handler:^(PopoverAction *action) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            [theController presentLogin];
            return ;
        }
        
        if ([[BBSUIContext shareInstance].currentUser.uid integerValue] == theController.threadModel.authorId) {
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = @"Discuz论坛错误：无法举报自己";
            
            HUD.contentColor = [UIColor whiteColor];
            HUD.mode = MBProgressHUDModeText;
            HUD.bezelView.backgroundColor = [UIColor blackColor];
            [HUD showAnimated:YES];
            [HUD hideAnimated:YES afterDelay:2];
            
            return;
        }
        
        BBSUIAccusationViewController *accusationVC = [[BBSUIAccusationViewController alloc] initWithThread:theController.threadModel];
        [theController.navigationController pushViewController:accusationVC animated:YES];
        
        
    }];
    
    return @[createdOnOrderAction];
}

- (void)replyViewTap:(UITapGestureRecognizer *)tap
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        [self presentLogin];
        return ;
    }
    
    __weak typeof(self) weakSelf = self ;
    [self.commentTextView.countNumTextView setPlaceholder:@"回复楼主"];
    [self.commentTextView.countNumTextView becomeFirstResponder];
    [self.commentTextView setSendHandler:^(NSArray<UIImage *> *images, NSString *content) {
        [weakSelf uploadCommentWithImages:images content:content prePid:0];
    }];
}

- (void)uploadCommentWithImages:(NSArray *)images content:(NSString *)content prePid:(NSInteger)pid
{
    if (!(content.length || images.count))
    {
        [BBSUIProcessHUD showFailInfo:@"请输入回复内容" delay:3];
        return;
    }
    
//    self.replyView.state = BBSUIReplyStateUploading;
    
    NSArray *imagesArray = images.copy;
    
    NSMutableString *comment = content.mutableCopy;
    
    if (!images.count)
    {
        [self postCommentWithHTML:content pid:pid];
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
                        NSLog(@"_____________ %@",comment);
                        
                        [self postCommentWithHTML:comment pid:pid];
                    }
                }
                
                dispatch_semaphore_signal(seamphore);
            }];
        });
    }
}
//
- (void)postCommentWithHTML:(NSString *)html pid:(NSInteger)pid
{
    [BBSSDK postCommentWithFid:_threadModel.fid tid:_threadModel.tid reppid:pid message:html result:^(BBSPost *post,NSError *error) {
        if (!error)
        {
            [self postCommentSuccess:post prePid:pid comment:html];
        }
        else
        {
            [self postCommentError:error];
        }
    }];
}

- (void)postCommentError:(NSError *)error
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = error.userInfo[@"description"];
    HUD.contentColor = [UIColor whiteColor];
    HUD.mode = MBProgressHUDModeText;
    HUD.bezelView.backgroundColor = [UIColor blackColor];
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
}

- (void)postCommentSuccess:(BBSPost *)post prePid:(NSInteger)pid comment:(NSString *)comment
{
    //更新评论数量
    NSInteger commentCount = [self.commentButton.titleLabel.text integerValue];
    [self.commentButton setTitle:[NSString stringWithFormat:@"%zd", commentCount + 1] forState:UIControlStateNormal];
    
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"评论成功";
    HUD.contentColor = [UIColor whiteColor];
    HUD.mode = MBProgressHUDModeText;
    HUD.bezelView.backgroundColor = [UIColor blackColor];
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
    
//    post.message = comment;
    [self updateComment:post prePid:pid];
    if (self.commentTextView) {
        if (self.commentTextView.superview) {
            [self.commentTextView removeFromSuperview];
        }
        self.commentTextView = nil;
    }
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
    threadDic[@"forumPic"] = thread.forumPic;
    
    
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
