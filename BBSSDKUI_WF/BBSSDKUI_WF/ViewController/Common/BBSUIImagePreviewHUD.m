//
//  BBSUIImagePreviewHUD.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIImagePreviewHUD.h"
#import "BBSUIImageViewController.h"
#import "Masonry.h"

@interface BBSUIImagePreviewHUD()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) NSArray *urls;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray *imageVCs;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) UILabel *pageCount;

@end

@implementation BBSUIImagePreviewHUD

+ (void)showWithImageUrls:(NSArray *)urls index:(NSInteger)index
{
    static BBSUIImagePreviewHUD *hud = nil;
    hud = [[BBSUIImagePreviewHUD alloc] init];
    hud.urls = urls;
    hud.index = index;
    hud.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    hud.window.backgroundColor = [UIColor clearColor];
    hud.window.windowLevel = UIWindowLevelNormal ;
    UIView *backGroundView = [[UIView alloc] initWithFrame:hud.window.bounds];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0.75 ;
    [hud.window addSubview:backGroundView];
    
    [hud setupImageVCs];
    [hud configUI];
    [hud.window makeKeyAndVisible];
}

- (void)setupImageVCs
{
    _imageVCs = [NSMutableArray array];
    for (NSInteger i=0; i<_urls.count; i++)
    {
        BBSUIImageViewController *imageVc = [[BBSUIImageViewController alloc] initWithUrl:_urls[i]];
        imageVc.delegate = (id)self;
        [_imageVCs addObject:imageVc];
    }
}

- (void)configUI
{
    self.pageCount =
    ({
        UILabel *pageCount = [[UILabel alloc] init];
        pageCount.text = [NSString stringWithFormat:@"%zd/%zd",_index+1,_urls.count];
        pageCount.textColor = [UIColor whiteColor];
        [_window addSubview:pageCount];
        [pageCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_window);
            make.top.equalTo(_window).offset(35);
        }];
        
        pageCount ;
    });
    
    self.pageViewController =
    ({
        UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey:@0,UIPageViewControllerOptionInterPageSpacingKey:@10}];
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        
        [pageViewController setViewControllers:@[_imageVCs[_index]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        pageViewController.doubleSided = NO ;
        
        [_window addSubview:pageViewController.view];
        
        [pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_window).insets(UIEdgeInsetsMake(60, 0, 0, 0));
        }];
        
        pageViewController ;
    });
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_imageVCs indexOfObject:viewController];
    
    if (_imageVCs.count==1)
    {
        return nil;
    }
    
    if (index == 0)
    {
        return [_imageVCs lastObject];
    }
    else
    {
        return _imageVCs[index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_imageVCs indexOfObject:viewController];
    
    if (_imageVCs.count==1)
    {
        return nil;
    }
    
    if (index == _imageVCs.count-1)
    {
        return [_imageVCs firstObject];
    }
    else
    {
        return _imageVCs[index+1];
    }
}

- (void)didTapImage:(UIImage *)image
{
    [self.window resignKeyWindow];
    self.window = nil;
}



- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    if (!pendingViewControllers.count)
    {
        return;
    }
    self.pageCount.text = [NSString stringWithFormat:@"%zd/%zd",[_imageVCs indexOfObject:pendingViewControllers[0]]+1,_imageVCs.count];
}


@end
