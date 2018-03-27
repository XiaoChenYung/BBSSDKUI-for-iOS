
//
//  BBSUIDownloadView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/3/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIDownloadView.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"
#import <MOBFoundation/MOBFoundation.h>

@interface BBSUIDownloadView ()

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) UIImageView *fileTypeImageView;

@property (nonatomic, strong) UILabel *fileNameLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UIButton *controlButton;

@property (nonatomic, copy) void (^result)(NSString *fileURL, BOOL canOpen, BOOL isTxt);

@property (nonatomic, copy) void (^openInOther)();

@property (nonatomic) BOOL canOpen;

@property (nonatomic) BOOL isTxt;

@end

@implementation BBSUIDownloadView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self configureUI];
        [self setViewAutoLayout];
    }
    
    return self;
}

- (void)configureUI
{
    self.fileTypeImageView = [[UIImageView alloc] init];
    [self addSubview:self.fileTypeImageView];
    
    self.fileNameLabel = [[UILabel alloc] init];
    [self addSubview:self.fileNameLabel];
    [self.fileNameLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.progressView = [[UIProgressView alloc] init];
    [self addSubview:self.progressView];
    self.progressView.trackTintColor = DZSUIColorFromHex(0xE0E0E2);//底部背景颜色
    self.progressView.progressTintColor = DZSUIColorFromHex(0x89BD6A);//进度颜色
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.stopButton];
    [self.stopButton setImage:[UIImage BBSImageNamed:@"/Common/no@2x.png"] forState:UIControlStateNormal];
    
    self.progressLabel = [[UILabel alloc] init];
    [self addSubview:self.progressLabel];
    [self.progressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.progressLabel setTextColor:DZSUIColorFromHex(0xADADAD)];
    [self.progressLabel setFont:[UIFont systemFontOfSize:14]];
    
    self.controlButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.controlButton];
    [self.controlButton.layer setMasksToBounds:YES];
    [self.controlButton.layer setCornerRadius:20.0]; //设置矩形四个圆角半径
    [self.controlButton.layer setBorderWidth:1.0];//边框宽度
    [self.controlButton.layer setBorderColor:DZSUIColorFromHex(0x89BD6A).CGColor];
    [self.controlButton setTitleColor:DZSUIColorFromHex(0x89BD6A) forState:UIControlStateNormal];
    [self.controlButton setHidden:YES];
    [self.controlButton addTarget:self action:@selector(loadAttachment:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setViewAutoLayout
{
    [self.fileTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(120);
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileTypeImageView.mas_bottom).with.offset(30);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.height.mas_equalTo(30);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLabel.mas_bottom).with.offset(80);
        make.left.equalTo(self.mas_left).with.offset(60);
        make.right.equalTo(self.mas_right).with.offset(-60);
    }];
    
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressView.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.progressView.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressView.mas_top).with.offset(-10);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    
    [self.controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLabel.mas_bottom).with.offset(40);
        make.left.equalTo(self.mas_left).with.offset(100);
        make.right.equalTo(self.mas_right).with.offset(-100);
        make.height.mas_equalTo(40);
    }];
    
}

- (void)setAttachment:(NSDictionary *)attachment
{
    _attachment = attachment;
    
    self.canOpen = [self setFileTypeImame];
    [self.fileNameLabel setText:self.attachment[@"fileName"]];
    [self.progressLabel setText:@"下载中...(0MB/0MB)"];
    
    //创建文件路径
    NSString *caches=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    _filePath=[caches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", attachment[@"fileName"]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_filePath]){
        if (self.result) {
            [self changeState];
            self.result(_filePath, self.canOpen, self.isTxt);
        }
    }else{
        [self loadAttachment:self.controlButton];
    }
    
}

- (void)setFinishResult:(void (^)(NSString *, BOOL, BOOL))result openInOther:(void (^)())openInOhter
{
    _result = result;
    _openInOther = openInOhter;
}

- (void)loadAttachment:(UIButton *)controlButton
{
    if ([controlButton.titleLabel.text isEqualToString:@"其他应用打开"]) {
        if (self.openInOther) {
            self.openInOther();
        }

    }else{
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_filePath]) {
            [fileManager removeItemAtPath:_filePath error:nil];
        }
        
        [self.progressView setProgress:0];
        [self.stopButton setHidden:NO];
        [self.progressView setHidden:NO];
        [self.progressLabel setHidden:NO];
        [self.controlButton setHidden:YES];
        
        NSString *attachmentUrl = self.attachment[@"url"];
        if (attachmentUrl) {
            NSURL *targetURL =[NSURL URLWithString:attachmentUrl];
            NSMutableURLRequest*request =[NSMutableURLRequest requestWithURL:targetURL];
            
            //网页直接加载
            //        [self.webView loadRequest:request];
            __weak typeof(self) theView = self;
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithRequest:request];
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                if (response.statusCode == 200) {
                    NSFileManager *fileManager=[NSFileManager defaultManager];
                    if ([fileManager createFileAtPath:theView.filePath contents:nil attributes:nil]) {
                        
                        [responseData writeToFile:theView.filePath atomically:NO];
                        if (theView.result) {
                            theView.result(theView.filePath, theView.canOpen, self.isTxt);
                        }
                        
                    }
                }
                
            } onFault:^(NSError *error) {
                NSLog(@"fault");
            } onUploadProgress:^(int64_t totalBytes, int64_t loadedBytes) {
                NSLog(@"upload");
            } onDownloadProgress:^(int64_t totalBytes, int64_t loadedBytes) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [theView setDownloadProgressWithTotalBytes:totalBytes loadedBytes:loadedBytes];
                });
                
            }];
        }
    }
    
//    }
//    else{
//        if (self.openInOther) {
//            self.openInOther();
//        }
//    }
}

- (BOOL)setFileTypeImame
{
    NSString *fileName = self.attachment[@"fileName"];
    BOOL canOpen = YES;
    if ([fileName isKindOfClass:[NSString class]]) {
        NSString *suffix = [fileName pathExtension];
        if ([suffix isEqualToString:@"excel"] || [suffix isEqualToString:@"xlsx"]) {
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/excel@2x.png"]];
        }else if ([suffix isEqualToString:@"mp4"]){
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/mp4@2x.png"]];
        }else if ([suffix isEqualToString:@"pdf"]){
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/pdf@2x.png"]];
        }else if ([suffix isEqualToString:@"ppt"] || [suffix isEqualToString:@"pptx"]){
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/ppt@2x.png"]];
        }else if ([suffix isEqualToString:@"txt"]){
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/txt@2x.png"]];
            self.isTxt = YES;
        }else if ([suffix isEqualToString:@"word"] || [suffix isEqualToString:@"doc"] || [suffix isEqualToString:@"docx"]){
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/word@2x.png"]];
        }else if ([suffix isEqualToString:@"md"])
        {
            self.isTxt = YES;
        }
        else {
            [self.fileTypeImageView setImage:[UIImage BBSImageNamed:@"Common/wz@2x.png"]];
            canOpen = NO;
        }
    }
    
    return canOpen;
}

- (void)setDownloadProgressWithTotalBytes:(int64_t)totalBytes loadedBytes:(int64_t)loadedBytes
{
    __weak typeof(self) theDownloadView = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float totalMB = (float)totalBytes/1024/1024;
        float loadedMB = (float)loadedBytes/1024/1024;
        NSString *loadStatusString = [NSString stringWithFormat:@"下载中...(%.2fMB/%.2fMB)", loadedMB, totalMB];
        [self.progressLabel setText:loadStatusString];
        
        double progress=(double)loadedBytes/totalBytes;
        [self.progressView setProgress:progress];
        
        if (totalBytes != 0 && totalBytes == loadedBytes) {
            [theDownloadView changeState];
        }
        
    });
}

- (void)changeState
{
    [self.stopButton setHidden:YES];
    [self.progressLabel setHidden:YES];
    [self.progressView setHidden:YES];
    
    //            NSString *controlStr = [NSString stringWithFormat:@"重新下载 (%.2fMB)", totalMB];
    [self.controlButton setHidden:NO];
    NSString *controlStr = nil;
    if (self.canOpen) {
        controlStr = @"正在打开文件...";
    }else{
        controlStr = @"其他应用打开";
    }
    [self.controlButton setTitle:controlStr forState:UIControlStateNormal];

}

@end
