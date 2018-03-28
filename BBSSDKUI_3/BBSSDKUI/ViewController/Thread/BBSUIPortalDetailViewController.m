//
//  BBSUIThreadDetailViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIPortalDetailViewController.h"
#import <BBSSDK/BBSThread.h>
#import "Masonry.h"
#import "BBSUIMacro.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSThreadAttachment.h>
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

@interface BBSUIPortalDetailViewController ()

@property (nonatomic, strong) BBSThread             *threadModel;
@property (nonatomic, strong) UIView                *bottomBar; //底部操作栏
@property (nonatomic, strong) UIView                *replyView; //回复操作栏
@property (nonatomic, strong) BBSJSImageDownload    *imageDownload;
@property (nonatomic, assign) NSInteger aid;
@property (nonatomic, strong) UIButton              *commentButton;
@property (nonatomic, strong) UIButton              *likeButton;
@property (nonatomic, strong) UIButton              *favButton;
@property (nonatomic, assign) BOOL                  isFavirated;
@property (nonatomic, strong) BBSUICommentTextView  *commentTextView; //回复视图


@end

@implementation BBSUIPortalDetailViewController

+ (NSString *)MLSDKPath
{
    return @"/portal/detail";
}

- (instancetype)initWithMobLinkScene:(id<IMOBFScene>)scene;
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
//    self.navigationController.navigationBar.clipsToBounds = YES;
    
    [self setupJSNativeWithNativeExtPath:@"/HTML_Portal/assets/js/NativeExt"];
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
        make.bottom.mas_equalTo(self.view).with.offset(-50);
    }];
    
    self.bottomBar =
    ({
        UIView *bottomBar = [[UIView alloc] init];
        bottomBar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomBar];
        [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@0);
            make.width.equalTo(@140);
            make.bottom.equalTo(self.view);
            make.height.equalTo(@50);
        }];
        bottomBar ;
    });
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomBar addSubview:self.commentButton];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.mas_equalTo(@(140 / 2));
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
        make.right.top.bottom.equalTo(@0);
        make.width.mas_equalTo(@(140 / 2));
    }];
    [self.likeButton.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:10]];
    [self.likeButton setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage BBSImageNamed:@"/Thread/LikeItem@2x.png"] forState:UIControlStateNormal];
    [self.likeButton setTitle:@"0" forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(_likeButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton setContentMode:UIViewContentModeCenter];
    
//    self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.bottomBar addSubview:self.favButton];
//    [self.favButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.right.equalTo(self.bottomBar).with.offset(0);
//        make.width.mas_equalTo(@(DZSUIScreen_width / 3));
//    }];
//    [self.favButton.titleLabel setFont: [UIFont fontWithName:@".PingFangSC-Regular" size:10]];
//    [self.favButton setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:184/255.0 alpha:1/1.0] forState:UIControlStateNormal];
//    [self.favButton setImage:[MOBFImage scaleImage:[UIImage BBSImageNamed:@"/Thread/FavItem@2x.png"] withSize:CGSizeMake(17.5*2, 17.5*2)] forState:UIControlStateNormal];
//    [self.favButton setTitle:@"0" forState:UIControlStateNormal];
//    [self.favButton addTarget:self action:@selector(favButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
//    [self.favButton setContentMode:UIViewContentModeCenter];
    
    
    self.replyView = [UIView new];
    [self.view addSubview:self.replyView];
    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(@0);
        make.right.equalTo(self.bottomBar.mas_left);
        make.height.mas_equalTo(@50);
    }];
    [self.replyView setBackgroundColor:[UIColor whiteColor]];
    UITapGestureRecognizer *replyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyViewTap:)];
    replyViewTap.numberOfTouchesRequired = 1;
    
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
    [tipLabel setTextAlignment:NSTextAlignmentLeft];
    
    if ((self.allowcomment && self.allowcomment.integerValue == 0) || self.threadModel.allowcomment == 0)
    {
        [tipLabel setText:@"  禁止评论"];
    }
    else
    {
        [tipLabel setText:@"  写点评论..."];
        [self.replyView addGestureRecognizer:replyViewTap];
    }
    
}

- (BBSUICommentTextView *)commentTextView
{
    if (!_commentTextView) {
        _commentTextView =[BBSUICommentTextView portalTextView];
        [self.view addSubview:_commentTextView];
    }
    
    return _commentTextView;
}

- (void)updateUI
{
    //    if (_threadModel.replies > 0) {
    //        [_commentButton yee_MakeBadgeText:[NSString stringWithFormat:@"%zd", _threadModel.replies] textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont systemFontOfSize:12]];
    //    }
    [_commentButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.commentnum] forState:UIControlStateNormal];
    [_likeButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.click1] forState:UIControlStateNormal];
//    [_favButton setTitle:[NSString stringWithFormat:@"%zd", _threadModel.favtimes] forState:UIControlStateNormal];
    
    if (_threadModel.favid != 0) {
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/favSelected@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = YES;
    }else{
        [_favButton setImage:[UIImage BBSImageNamed:@"/Thread/FavItem@2x.png"] forState:UIControlStateNormal];
        self.isFavirated = NO;
    }
    
    NSMutableDictionary *likedThreadDictionary = [[BBSUICacheManager sharedInstance] getLikedThreadDictionaryWithUid:[BBSUIContext shareInstance].currentUser.uid];
    if (likedThreadDictionary) {
        
        NSString *key = [NSString stringWithFormat:@"Portal%lu",self.threadModel.aid];
        if (likedThreadDictionary[key]) {
            BOOL isLiked = [likedThreadDictionary[key] boolValue];
            if (isLiked) {
                [_likeButton setImage:[UIImage BBSImageNamed:@"/Thread/LikeSelected@2x.png"] forState:UIControlStateNormal];
            }
        }
    }
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
    [self registRelated];
//    [self registFollowMethod];
    [self registOpenAuthor];
}

#pragma mark - 注册js方法
/**
 获取帖子详情
 */

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
        else
        {
            [BBSSDK getPortalDetailWithAid:self.aid result:^(BBSThread *thread, NSError *error)  {
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
                    // author和username长度截取
                    if (thread.author.length > 10) thread.author = [thread.author substringToIndex:10];
                    
                    if (thread.username.length > 10) thread.username = [thread.username substringToIndex:10];
                    
                    _threadModel = thread;
                    NSLog(@"=====%@",thread);
                    // 添加历史记录
                    [[BBSUICoreDataManage shareManager] addHistoryWithThread:thread];
                    
                    [theWebController updateUI];
                    
                    NSMutableDictionary * res = [theWebController dictionaryWithThread:thread].mutableCopy;
                    
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
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
        {
            aid = [arguments[0] integerValue];
        }
        
        if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
        {
            page = [arguments[2] integerValue];
        }
        
        if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSNumber class]])
        {
            pageSize = [arguments[3] integerValue];
        }
        
        if (arguments.count > 3 && [arguments[3] isKindOfClass:[NSString class]])
        {
            callback = arguments[3];
        }
        
        [BBSSDK getPortalCommentListWithAid:self.aid pageIndex:page pageSize:pageSize result:^(NSArray *postList, NSError *error) {

            NSLog(@"+++++++++ %@",postList);
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
                    
//                    postArray =@[@{@"cid":@(96),@"id":@(1905774),@"idtype":@"aid",@"username":@"作者",@"uid":@(280983),@"avatar":@"http://c.mob.com/images/icons/profilepics/default.png",@"dateline":@(1385983515),@"message":@"aaaaaaaaaaa",@"postip":@"119.130.33.27"}].mutableCopy; // 假数据
                    
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
            
            return;
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
    [self.jsContext registerJSMethod:@"addNewCommentHtml" block:^(NSArray *arguments) {
        
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
            portalDetail.allowcomment = self.allowcomment;
            [theWebController.navigationController pushViewController:portalDetail animated:YES];
        }
        
        //进入其他用户详情入口
    }];
    
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


/**
 赞

 @param button <#button description#>
 */
- (void)_likeButtonHandler:(UIButton *)button
{
    if (![BBSUIContext shareInstance].currentUser) {
        [self presentLogin];
        return;
    }
    // 鲜花+1
    NSInteger clickid = 1;
    
    __weak typeof(self) theController = self;
    [BBSSDK likePortalWithAid:self.aid clickid:@(clickid) result:^(NSError *error) {
        
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
            [self.webView stringByEvaluatingJavaScriptFromString:@"BBSSDKNative.likeArticle()"];
            
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
    [likedThreadDictionary setObject:@(YES) forKey:[NSString stringWithFormat:@"Portal%lu",self.threadModel.aid]];
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
    [[BBSUIShareView sharedInstance] createShareViewWithContent:self.threadModel flag:1 animation:YES];
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

    [BBSSDK postPortalCommentWithAid:_threadModel.aid uid:_threadModel.authorId message:html result:^(BBSComment *comment, NSError *error) {
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
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.label.text = error.userInfo[@"description"];
    
    NSString *code = error.userInfo[@"statusCode"];
    if ([code isEqualToString:@"-1009"])
    {
        HUD.label.text = @"似乎已断开网络连接";
    }
    NSLog(@"________  error%@",HUD.label.text);
    
    HUD.contentColor = [UIColor whiteColor];
    HUD.mode = MBProgressHUDModeText;
    HUD.bezelView.backgroundColor = [UIColor blackColor];
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:2];
}

- (void)postCommentSuccess:(BBSComment *)post prePid:(NSInteger)pid comment:(NSString *)comment
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

