//
//  BBSUIImageViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIImageViewController.h"
#import "Masonry.h"
#import "YYAnimatedImageView.h"
#import "YYImage.h"
#import "NSString+BBSUIMD5.h"

@interface BBSUIImageViewController ()<UIScrollViewDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@end

@implementation BBSUIImageViewController


- (instancetype)initWithUrl:(NSString *)url
{
    if (self = [super init])
    {
        _url = url;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView =
    ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scrollView];
        scrollView.delegate = self;
        scrollView ;
    });
    
    self.imageView =
    ({
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width-20, self.view.frame.size.height-60);
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:frame];
        imageView.center = CGPointMake(self.view.center.x, self.view.center.y-50);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:imageView];
        
        __weak typeof(self) weakSelf = self;
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:_url] result:^(NSData *imageData, NSError *error) {
            
            if (error)
            {
                if (weakSelf.isViewLoaded && weakSelf.view.window)
                {
                    BBSUIAlert(@"图片加载失败");
                }
                return ;
            }
            
            YYImage *image = [YYImage imageWithData:imageData];
            [weakSelf setImage:image];
            imageView.image = image;
        }];
        imageView ;
    });

    //双击事件
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBig:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    //tap手势
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(close)];
    [_scrollView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage:)];
    [_scrollView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)close
{
    if ([self.delegate respondsToSelector:@selector(didTapImage:)])
    {
        [self.delegate didTapImage:_imageView.image];
    }
}

#define ImagePath(fileURL) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileURL]

- (NSString *)setURL:(NSString *)urlStr imageData:(NSData *)imageData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = ImagePath([NSString bbs_md5:urlStr]);
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        [imageData writeToFile:filePath atomically:NO];
    }
    return filePath;
}

- (void)saveImage:(UILongPressGestureRecognizer *)ges
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIPopoverPresentationController *popoverController = vc.popoverPresentationController;
    popoverController.sourceView = self.view;
    popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,DZSUIScreen_height,1.0,1.0);
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存到手机相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }];
    
    [vc addAction:cancel];
    [vc addAction:save];
    
    [self presentViewController:vc animated:YES completion:nil];

}

/**
 根据双击手势位置进行放大
 
 @param tapGestureRecognizer 手势
 */
- (void)showBig:(UITapGestureRecognizer*)tapGestureRecognizer
{
    static BOOL isBig = NO;
    
    CGPoint location1 =[tapGestureRecognizer locationInView:_imageView];
    if (!isBig)
    {
        if (location1.y>0&&location1.y<CGRectGetHeight(_imageView.frame))

        {
            [_scrollView zoomToRect:CGRectMake(location1.x, location1.y, 1, 1) animated:YES];
            isBig=YES;
        }
    }
    else{
        [_scrollView setZoomScale:1.0 animated:YES];
        isBig=NO;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //当捏或移动时，需要对center重新定义以达到正确显示未知
    CGFloat xcenter = scrollView.center.x;
    CGFloat ycenter = scrollView.center.y;
    //    NSLog(@"adjust position,x:%f,y:%f",xcenter,ycenter);
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height/2 : ycenter;
    _imageView.center = CGPointMake(xcenter, ycenter);
    //   [_imgView setCenter:CGPointMake(xcenter, ycenter)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

/**
 根据图片进行ui大小设置
 
 @param image 图片
 */
- (void)setImage:(UIImage*)image
{
    CGFloat width = CGRectGetWidth(_scrollView.frame);
    CGFloat temp = 1;
    NSInteger height;
    if (image.size.width > width)
    {
        temp = image.size.width/width;
        if(temp < 1){
            temp = 1;
        }
        height = image.size.height/temp;
        _imageView.frame=CGRectMake(0, 0, width, height);
    }
    else
    {
        height = image.size.height/temp;
        _imageView.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    _scrollView.maximumZoomScale = 2.0;
    
    if (height < CGRectGetHeight([[UIScreen mainScreen] bounds]))
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        _imageView.center = CGPointMake(size.width/2, size.height/2);
    }
    else{
        _scrollView.contentSize = CGSizeMake(width, height);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
    if (error)
    {
        BBSUIAlert(@"保存失败:%@",error);
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD dismissWithDelay:2];
    }
}


@end
