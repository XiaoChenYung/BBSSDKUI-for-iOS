//
//  BBSUIJSNative.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIJSNative.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSPost.h>
#import "BBSUICheckAttachmentWebViewController.h"
#import <MOBFoundation/MOBFImageGetter.h>
#import "NSString+md5.h"
#import "BBSUIImagePreviewWebController.h"
#import "BBSUIModelToObject.h"

#define ImagePath(fileURL) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileURL]

#define BBSSDKJSNATIVE @"BBSUIJSNative"

@interface BBSUIJSNative ()

@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic, strong) BBSThread *model;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) NSMutableArray *observerArray;

@property (nonatomic, strong) NSMutableDictionary *urlDictionary;

@property (nonatomic, strong) NSArray *urlsArray;

@property (nonatomic) NSInteger index;

@property (nonatomic) BOOL isImageViewer;


@end

@implementation BBSUIJSNative

- (instancetype)initWithJSContext:(JSContext *)context threadModel:(BBSThread *)model viewController:(id)viewController
{
    self = [super init];
    if (self) {
        _model = model;
        _jsContext = context;
        _viewController = viewController;
        [self addMethods];
        
        _observerArray = [[NSMutableArray alloc] init];
        _urlDictionary = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}

- (instancetype)initWithJSContext:(JSContext *)context urlsArray:(NSArray *)urlsArray index:(NSInteger)index viewController:(id)viewController
{
    self = [super init];
    if (self) {
        _jsContext = context;
        _urlsArray = urlsArray;
        _index = index;
        _viewController = viewController;
        _urlDictionary = [[NSMutableDictionary alloc] init];
        _isImageViewer = YES;
        
        [self addMethods];
    }
    
    return self;
}

- (void)addMethods
{
    __weak typeof(self) weakSelf = self;
    [_jsContext evaluateScript:@"BBSUIJSNative = {}"];
    //获取帖子详情
    _jsContext[BBSSDKJSNATIVE][@"getForumThreadDetails"] = ^JSValue * {
        
        JSValue *threadDetailValue = [weakSelf nativeGetForumThreadDetails:weakSelf.jsContext];
        return threadDetailValue;
        
    };
    
    //获取帖子评论列表
    _jsContext[BBSSDKJSNATIVE][@"getPosts"] = ^{
        
        [weakSelf nativeGetPosts];
        
    };
    
    //打开附件
    _jsContext[BBSSDKJSNATIVE][@"openAttachment"] = ^{
        
        [weakSelf nativeOpenAttachment];
        
    };
    
    //打开图片
    _jsContext[BBSSDKJSNATIVE][@"openImage"] = ^{
        
        [weakSelf nativeOpenImage];
        
    };
    
    _jsContext[BBSSDKJSNATIVE][@"openHref"] = ^{
        
        [weakSelf nativeOpenHref];
    };
    
    _jsContext[BBSSDKJSNATIVE][@"getImageUrlsAndIndex"] = ^JSValue *{
        
        return [weakSelf nativeGetImageUrlsAndIndex];
        
    };
    
    _jsContext[BBSSDKJSNATIVE][@"setCurrentImageSrc"] = ^{
        
        [weakSelf nativeSetCurrentImageSrc];
        
    };
    
    _jsContext[BBSSDKJSNATIVE][@"downloadImages"] = ^{
        
        NSArray *arguments = [JSContext currentArguments];
        if ([arguments isKindOfClass:[NSArray class]] && arguments.count > 0) {
            NSString *urlsString = [arguments[0] toString];
            NSArray *urlStringArray = [urlsString componentsSeparatedByString:@","];
            [weakSelf nativeDownloadImages:urlStringArray];
        }
        
    };
    
    _jsContext[BBSSDKJSNATIVE][@"showImage"] = ^{
        
        NSLog(@"show show ++++++++++++++");
        
    };
}

- (void)dealloc
{
    
}


#pragma mark - native methods
/**
 *  获取详情
 *
 @return 帖子详情
 */
- (JSValue *)nativeGetForumThreadDetails:(JSContext *)context
{
    JSValue *threadValue = [JSValue valueWithNewObjectInContext:context];
    [threadValue setObject:@(self.model.tid) forKeyedSubscript:@"tid"];
    [threadValue setObject:@(self.model.fid) forKeyedSubscript:@"fid"];
    [threadValue setObject:self.model.subject forKeyedSubscript:@"subject"];
    [threadValue setObject:self.model.summary forKeyedSubscript:@"summary"];
    [threadValue setObject:self.model.message forKeyedSubscript:@"message"];
    [threadValue setObject:self.model.images forKeyedSubscript:@"images"];
    [threadValue setObject:self.model.attachments forKeyedSubscript:@"attachments"];
    [threadValue setObject:self.model.author forKeyedSubscript:@"author"];
    [threadValue setObject:@(self.model.authorId) forKeyedSubscript:@"authorId"];
    [threadValue setObject:self.model.avatar forKeyedSubscript:@"avatar"];
    [threadValue setObject:@(self.model.createdOn) forKeyedSubscript:@"createdOn"];
    [threadValue setObject:@(self.model.replies) forKeyedSubscript:@"replies"];
    [threadValue setObject:@(self.model.views) forKeyedSubscript:@"views"];
    
    return threadValue;
}

/**
 获取评论列表
 */
- (void)nativeGetPosts
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSArray *arguments = [JSContext currentArguments];
    if (arguments.count >= 4) {
        
        
            NSInteger fid = [arguments[0] toInt32];
            NSInteger tid = [arguments[1] toInt32];
            NSInteger pageIndex = [arguments[2] toInt32];
            NSInteger pageSize = [arguments[3] toInt32];
            
            
            [BBSSDK getPostListWithFid:fid tid:tid pageIndex:pageIndex pageSize:pageSize result:^(NSArray *postList, NSError *error) {
                
                //回调
                //            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *postArray = [NSMutableArray array];
                [postList enumerateObjectsUsingBlock:^(BBSPost *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[BBSPost class]]) {
                        NSDictionary *postDic = [BBSUIModelToObject objectFromPostModel:obj];
                        [postArray addObject:postDic];
                    }
                }];
                
                JSValue *callBack = arguments[4];
                NSArray *paramArray = nil;
                if (postArray.count > 0) {
                    paramArray = [NSArray arrayWithObject:postArray];
                }else{
                    paramArray = [NSArray arrayWithObject:[NSNumber numberWithBool:false]];
                }
                NSLog(@"callback = %@", callBack);
                [callBack callWithArguments:paramArray];
                //            });
                
            }];
        
        
        
    }
        });
}

/**
 打开附件
 */
- (void)nativeOpenAttachment
{
    NSArray *arguments = [JSContext currentArguments];
    NSDictionary *attachmentDic = nil;
    if (arguments.count > 0) {
        attachmentDic = [arguments[0] toDictionary];
    }
    BBSUICheckAttachmentWebViewController *checkVC = [[BBSUICheckAttachmentWebViewController alloc] initWithAttachment:attachmentDic];
    if (self.viewController.navigationController) {
        [self.viewController.navigationController pushViewController:checkVC animated:YES];
    }
    
}

/**
 打开图片
 */
- (void)nativeOpenImage
{
    NSArray *arguments = [JSContext currentArguments];
    if (arguments.count >= 2) {
        NSString *urlsString = [arguments[0] toString]; //url列表字符串
        NSInteger index = [arguments[1] toUInt32];
        
        NSArray *urlsArray = [urlsString componentsSeparatedByString:@","];
        BBSUIImagePreviewWebController *imagePreviewVC = [[BBSUIImagePreviewWebController alloc] initWithUrls:urlsArray index:index];
        [_viewController.navigationController pushViewController:imagePreviewVC animated:YES];
    }
    
}

/**
 打开超链接
 */
- (void)nativeOpenHref
{
    NSLog(@"open href");
}

/**
 获取打开的图片数组和索引值
 */
- (JSValue *)nativeGetImageUrlsAndIndex
{
    NSArray *arguments = [JSContext currentArguments];
    NSLog(@"getImageUrlsAndIndex = %@", arguments);
    JSValue *value = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    [value setObject:self.urlsArray forKeyedSubscript:@"imageUrls"];
    [value setObject:@(self.index) forKeyedSubscript:@"index"];
    
    return value;
}

/**
 设置当前显示图片
 */
- (void)nativeSetCurrentImageSrc
{
    NSArray *arguments = [JSContext currentArguments];
    NSInteger index = [arguments[1] toInt32];
    self.index = index;
}

/**
 网络加载图片
 */
- (void)nativeDownloadImages:(NSArray *)urlArray
{
    __weak typeof(self) theJSNative = self;
    
    MOBFImageGetter *imgGetter = [MOBFImageGetter sharedInstance];
    
    if ([urlArray isKindOfClass:[NSArray class]]) {
        [urlArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [theJSNative.urlDictionary setObject:@(idx) forKey:obj];
            
            MOBFImageObserver *observer = [imgGetter getImageDataWithURL:[NSURL URLWithString:obj] result:^(NSData *imageData, NSError *error) {
                
                [theJSNative setURL:obj imageData:imageData isImageViewer:theJSNative.isImageViewer];
                
            }];
            
            
            [theJSNative.observerArray addObject:observer];
        }];
    }
}

/**
 展示图片
 */
- (void)nativeShowImage:(NSInteger)idx url:(NSString *)url imgSrc:(NSString *)path isImageViewer:(BOOL)isImageViewer
{
    NSString *showImageCall = [NSString stringWithFormat:@"BBSSDKNative.showImage('%zd', '%@', '%@', %@);", idx, url, path, [NSNumber numberWithBool:isImageViewer]];
    [_jsContext evaluateScript:showImageCall];
}

#pragma mark - private methods
- (void)setURL:(NSString *)urlStr imageData:(NSData *)imageData isImageViewer:(BOOL)isImageViewer
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = ImagePath([NSString md5:urlStr]);
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        [imageData writeToFile:filePath atomically:NO];
    }
    
    NSInteger index = [self.urlDictionary[urlStr] integerValue];
    [self nativeShowImage:index url:[NSString md5:urlStr] imgSrc:filePath isImageViewer:isImageViewer];
}

-(void)saveImageWithUrl:(NSString *)imageURL{
    // 读取沙盒路径图片
//    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),@"test"];
    // 拿到沙盒路径图片
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:ImagePath([NSString md5:imageURL])];
    // 图片保存相册
    UIImageWriteToSavedPhotosAlbum(imgFromUrl3, self, nil, nil);
//    return imgFromUrl3;
}

- (void)saveImage
{
    [self saveImageWithUrl:self.urlsArray[self.index]];
}

@end
