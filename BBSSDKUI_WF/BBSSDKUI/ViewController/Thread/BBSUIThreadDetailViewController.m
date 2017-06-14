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

@interface BBSUIThreadDetailViewController ()

@property (nonatomic, strong) BBSThread *threadModel;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) BBSUIReplyEditor *replyEditor;
@property (nonatomic, strong) BBSJSImageDownload *imageDownload;
@property (nonatomic, strong) BBSUIReplyStateView *replyView;

@end

@implementation BBSUIThreadDetailViewController

- (instancetype)initWithThreadModel:(BBSThread *)model
{
    if (self = [super init])
    {
        self.threadModel = model;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNativeMethods];//注册本地native方法
    [self setup];
}

- (void)setup
{
    self.title = @"帖子详情";
    self.webView.delegate = self ;
    self.replyEditor = [[BBSUIReplyEditor alloc] init];
    [self configBottomBar];
    [self loadWeb];
    
}

- (void)configBottomBar
{
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
    
    UIView *topLine = [[UIView alloc] init];
    topLine.alpha  = 0.1;
    topLine.backgroundColor = [UIColor darkGrayColor];
    [_bottomBar addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_bottomBar);
        make.height.equalTo(@1);
    }];
    
    UIButton *onlyLookAtBuilding = [UIButton buttonWithType:UIButtonTypeCustom];
    onlyLookAtBuilding.titleLabel.font = [UIFont systemFontOfSize:14];
    [onlyLookAtBuilding setTitle:@"只看楼主" forState:UIControlStateNormal];
    [onlyLookAtBuilding setTitle:@"查看全部" forState:UIControlStateSelected];
    [onlyLookAtBuilding setTitleColor:DZSUIColorFromHex(0x007dfc) forState:UIControlStateNormal];
    [onlyLookAtBuilding addTarget:self action:@selector(seeThreadOwnerOnly:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:onlyLookAtBuilding];
    [onlyLookAtBuilding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomBar.mas_right).offset(-15);
        make.centerY.equalTo(_bottomBar);
    }];
    
    UIView *midLine = [[UIView alloc] init];
    midLine.alpha  = 0.0;
    midLine.backgroundColor = [UIColor lightGrayColor];
    [_bottomBar addSubview:midLine];
    [midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(onlyLookAtBuilding.mas_left).offset(-15);
        make.centerY.equalTo(onlyLookAtBuilding);
        make.width.equalTo(@0.7);
        make.height.equalTo(onlyLookAtBuilding).offset(6);
    }];
    
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

- (void)loadWeb
{
    NSString *path = [[NSBundle bbsLoadBundle] pathForResource:@"/HTML/mobforum/index" ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:[NSURL URLWithString:path]];
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
}

#pragma mark - 注册js方法
- (void)registerGetForumThreadDetails
{
    __weak typeof(self) theWebController = self;
    [self.jsContext registerJSMethod:@"getForumThreadDetails" block:^(NSArray *arguments) {
        
        NSString *callback = nil;
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]]) {
            callback = arguments[0];
        }
        
        [BBSSDK getThreadDetailWithFid:_threadModel.fid tid:_threadModel.tid result:^(BBSThread *thread, NSError *error) {
            if (!error && thread)
            {
                _threadModel = thread;
                NSDictionary * res = [self dictionaryWithThread:thread];

                if (callback)
                {
                    [theWebController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:res]]];
                }
            }
            else
            {
                BBSUILog(@"getDetail error: %@",error);
                
                if (self.isViewLoaded && self.view.window)
                {
                    BBSUIAlert(@"获取详情失败:%@,code:%zd",error.userInfo[@"description"],error.code);
                }
            }
        }];
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

- (void)registReplyComment
{
    __weak typeof(self) weakSelf = self;
    [self.jsContext registerJSMethod:@"replyComment" block:^(NSArray *arguments) {
        
        if (![BBSUIContext shareInstance].currentUser)
        {
            BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            return ;
        }
        
        NSDictionary *comment = nil;
        
        if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSDictionary class]])
        {
            comment = arguments[0];
        }
        
        NSString *name = comment[@"author"];
        NSInteger pid = [comment[@"pid"] integerValue];
        
        [self.replyEditor showWithUserName:name finishEdit:^(BOOL cancelled, NSArray<UIImage *> *images, NSString *content) {
            if (cancelled)
            {
                return ;
            }
            
            [weakSelf uploadCommentWithImages:images content:content prePid:pid];
        }];
    }];
}

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

#pragma mark - click event

- (void)seeThreadOwnerOnly:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    
    NSString *js = [NSString stringWithFormat:@"BBSSDKNative.updateCommentHtml(%zd,%zd)",_threadModel.authorId,sender.selected];
    BBSUILog(@"excute js:%@",js);
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

- (void)reply:(id)sender
{
    if (![BBSUIContext shareInstance].currentUser)
    {
        BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        return ;
    }
    
    if(self.replyView.state != BBSUIReplyStateNormal)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self ;
    
    
    [self.replyEditor showWithUserName:_threadModel.author finishEdit:^(BOOL cancelled, NSArray<UIImage *> *images, NSString *content) {
        
        if (cancelled)
        {
            return ;
        }
        
        [weakSelf uploadCommentWithImages:images content:content prePid:0];
    }];
}

- (void)uploadCommentWithImages:(NSArray *)images content:(NSString *)content prePid:(NSInteger)pid
{
    if (!(content.length || images.count))
    {
        [BBSUIProcessHUD showFailInfo:@"请输入回复内容"];
        return;
    }
    
    self.replyView.state = BBSUIReplyStateUploading;
    
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
                        BBSUILog(@"%@",comment);
                        
                        [self postCommentWithHTML:comment pid:pid];
                    }
                }
                
                dispatch_semaphore_signal(seamphore);
            }];
        });
    }
}

- (void)postCommentWithHTML:(NSString *)html pid:(NSInteger)pid
{
    [BBSSDK postCommentWithFid:_threadModel.fid tid:_threadModel.tid reppid:pid message:html token:[BBSUIContext shareInstance].currentUser.token result:^(BBSPost *post,NSError *error) {
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
    BBSUIAlert(@"%@,code:%zd",error.userInfo[@"description"],error.code);
    
    if (error.code == 9001200)
    {
        [BBSUIContext shareInstance].currentUser = nil;
//        [BBSUIDataService cacheThreadDraft:nil];
    }
    
    self.replyView.state = BBSUIReplyStateFail;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.replyView.state = BBSUIReplyStateNormal;
    });
}

- (void)postCommentSuccess:(BBSPost *)post prePid:(NSInteger)pid comment:(NSString *)comment
{
    post.message = comment;
    [self updateComment:post prePid:pid];
    self.replyEditor = nil;
    
    self.replyView.state = BBSUIReplyStateSuccess;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.replyView.state = BBSUIReplyStateNormal;
    });
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


- (BBSUIReplyEditor *)replyEditor
{
    if (!_replyEditor)
    {
        _replyEditor = [[BBSUIReplyEditor alloc] init];
    }
    
    return _replyEditor;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    BBSUILog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
    if (error)
    {
        BBSUIAlert(@"保存失败:%@",error);
    }
}


@end
