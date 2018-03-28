//
//  BBSUIPortalViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2018/1/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIPortalViewController.h"
#import "BBSUIThreadListViewController.h"
#import "LBSegmentControl.h"
#import "BBSUIThreadBanner.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSBanner.h>
#import <BBSSDK/BBSPortalCatefories.h>
#import "BBSUIBannerPreviewViewController.h"
#import "BBSUIThreadDetailViewController.h"
#import "BBSUIContext.h"

@interface BBSUIPortalViewController ()<CycleViewDelegate>

@property (nonatomic, strong) LBSegmentControl * segmentControl;
@property (nonatomic, strong) LBSegmentControl * segmentControl2;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic, strong) BBSUIThreadBanner *bannerView;
@property (nonatomic, strong) UIImageView       *maskImage;
@property (nonatomic, strong) NSArray           *bannerArray;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) CGFloat lastTableViewOffsetY;
@property (nonatomic, strong) NSMutableArray *categoriesList;

@property (nonatomic, assign) BOOL needBrint;

@property (nonatomic, assign) CGFloat iphoneXTopPadding;

@end

@implementation BBSUIPortalViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = false;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if ([BBSUIContext shareInstance].isIphoneX)
    {
        self.iphoneXTopPadding = 30;
    }
    
    [self _configureUI];
//    [self _requestBannerList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化UI
-(void)_configureUI
{
    [self _setupHeaderView];
    
    [self.view.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    
    [BBSSDK getPortalCategories:^(NSArray *categories, NSError *error) {
        
        if (!error)
        {
            NSMutableArray *vcs = [NSMutableArray new];
            NSMutableArray *titles = [NSMutableArray new];
            
            self.categoriesList = categories.mutableCopy;
            
            for (BBSPortalCatefories *obj in self.categoriesList) {
                BBSUIThreadListViewController *vc = [[BBSUIThreadListViewController alloc] initWithCatid:obj.catid allowcomment:obj.allowcomment];
                
                vc.viewType = BBSUIThreadListViewTypePortal;
                
                [vcs addObject:vc];
                [titles addObject:obj.catname];
                
                vc.offSetBlock = ^(CGFloat offSet){
//                    NSLog(@"==============  %f",offSet);
                    [self setContentOffSet:offSet];
                };
                vc.refreshBannerBlock = ^(NSArray *bannnerList, NSError *error) {
                    [self _refreshBannerWithBannnerList:bannnerList error:error];
                };
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (vcs.count)
                {
                    self.segmentControl = [[LBSegmentControl alloc] initScrollTitlesWithFrame:CGRectMake(0, 245+ _iphoneXTopPadding, DZSUIScreen_width, 40)];
                    self.segmentControl.tableViewY = 245 - 64 + _iphoneXTopPadding;
                    //    self.segmentControl.tableViewY = 0;
                    
                    self.segments = [self.segmentControl settingTitles:titles];
                    self.segmentControl.viewControllers = vcs;
                    self.segmentControl.backgroundColor = [UIColor whiteColor];
                    [self.segmentControl setBottomViewColor:[UIColor clearColor]];
                    [self.segmentControl setTitleNormalColor:DZSUIColorFromHex(0x2A2B30)];
                    [self.segmentControl setTitleSelectColor:DZSUIColorFromHex(0xFFAA42)];
                    self.segmentControl.isTitleScale = YES;
                    self.segmentControl.isIntegrated = YES;
                    
                    self.headerView = [self _obtainHeaderView];
                    _headerView.layer.zPosition = 1.0f;
                    //    [_headerView addSubview:self.segmentControl];
                    
                    [self.view addSubview:_headerView];
                    
                    self.segmentControl.layer.zPosition = 2.0f;
                    [self.view addSubview:self.segmentControl];
                }
                
            });
            
        }
    }];
    
    
    
//    self.segmentControl = [[LBSegmentControl alloc] initStaticTitlesWithFrame:CGRectMake((DZSUIScreen_width-160)/2, 15, 160, 42) titleFontSize:17 isIntegrated:YES];
    
}

- (void)setContentOffSet:(CGFloat)offSet
{
    CGRect frame = self.headerView.frame;
    frame.origin.y = -offSet + _iphoneXTopPadding;
    self.headerView.frame = frame;

    _lastTableViewOffsetY = offSet;
    
    if (offSet <= 245 - 64)
    {
        CGRect segmentFrame = self.segmentControl.frame;
        segmentFrame.origin.y = 245-offSet + _iphoneXTopPadding;

        self.segmentControl.frame = segmentFrame;
    }
    else
    {
        CGRect segmentFrame = self.segmentControl.frame;
        segmentFrame.origin.y = 64 + _iphoneXTopPadding;

        self.segmentControl.frame = segmentFrame;
    }
    
    if (self.offSetBlock)
    {
        self.offSetBlock(offSet);
    }
}

- (void)_refreshBannerWithBannnerList:(NSArray *)bannerList error:(NSError *)error
{
    if (bannerList.count > 0) {
        
        self.maskImage.hidden = YES;
        self.bannerArray = bannerList;
        
        NSMutableArray *titleArray = [NSMutableArray array];
        NSMutableArray *pictureArray = [NSMutableArray array];
        [bannerList enumerateObjectsUsingBlock:^(BBSBanner *  _Nonnull banner, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [pictureArray addObject:banner.picture ? banner.picture : @""];
            [titleArray addObject:banner.title ? banner.title : @""];
            
        }];
        
        self.bannerView.picDataArray = [pictureArray copy];
        self.bannerView.titleDataArray = [titleArray copy];
        
        if (pictureArray.count > 1) {
            self.bannerView.isAutomaticScroll = YES;
        }else{
            self.bannerView.isAutomaticScroll = NO;
            self.bannerView.scrollEnabled = NO;
        }
        
        self.bannerView.automaticScrollDelay = 5;
        self.bannerView.cycleViewStyle = CycleViewStyleBoth;
        self.bannerView.pageControlTintColor = [UIColor blackColor];
        self.bannerView.pageControlCurrentColor = [UIColor whiteColor];
        self.bannerView.delegate = self;
        self.bannerView.titleLabelTextColor = [UIColor whiteColor];
        
    }else{
        
        self.maskImage.hidden = NO;
        [self.maskImage setImage:[UIImage BBSImageNamed:@"/Home/bannerDefault@2x.png"]];
    }
}

- (void)_setOtherControllerContentOffSetY:(NSInteger)index
{
//    CGFloat tableViewOffsetY = _lastTableViewOffsetY;
//    MOBTabTableBaseContentViewController *vc = _contentViewControllers[index];
//
//    if (vc.contentView.contentSize.height - self.view.mob_height < _lastTableViewOffsetY)
//    {
//        tableViewOffsetY = vc.contentView.contentSize.height - self.view.mob_height;
//    }
//    vc.contentView.contentOffset = CGPointMake(0, tableViewOffsetY);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (_needBrint)
    {
        return;
    }
    
    NSLog(@"aaaaaaaa %@",self.view.subviews);
    
    if (self.view.subviews.count == 3)
    {
        _needBrint = YES;
        if (self.headerView)
        {
            [self.view bringSubviewToFront:self.headerView];
        }
        if (self.segmentControl)
        {
            [self.view bringSubviewToFront:self.segmentControl];
        }
    }

}

- (void)_setupHeaderView
{
    
}

- (UIView *)_obtainHeaderView
{
    //计算版块点击高度
    //    CGFloat forumViewHeight = DZSUIScreen_height / 7;
    CGFloat forumViewHeight = 45;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, _iphoneXTopPadding, DZSUIScreen_width, 245 + forumViewHeight)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    //banner图
    self.bannerView = [[BBSUIThreadBanner alloc]
                       initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                247)];
    [headerView addSubview:self.bannerView];
    
    //加载广告条
    self.maskImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BBS_WIDTH(self.bannerView), BBS_HEIGHT(self.bannerView))];
    
    [self.maskImage setImage:[UIImage BBSImageNamed:@"/Home/BannerMask.png"]];
    [headerView addSubview:self.maskImage];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 240 + forumViewHeight + _iphoneXTopPadding, DZSUIScreen_width, 5)];
    lineView.backgroundColor = DZSUIColorFromHex(0xACADB8);
    
    return headerView;
}

- (void)_requestBannerList
{
    __weak typeof(self) theHomeVC = self;
    [BBSSDK getPortalBannerList:^(NSArray *bannnerList, NSError *error) {
        
        if (bannnerList.count > 0) {
            
            theHomeVC.maskImage.hidden = YES;
            
            theHomeVC.bannerArray = bannnerList;
            
            NSMutableArray *titleArray = [NSMutableArray array];
            NSMutableArray *pictureArray = [NSMutableArray array];
            [bannnerList enumerateObjectsUsingBlock:^(BBSBanner *  _Nonnull banner, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [pictureArray addObject:banner.picture ? banner.picture : @""];
                [titleArray addObject:banner.title ? banner.title : @""];
                
            }];
            
            theHomeVC.bannerView.picDataArray = [pictureArray copy];
            theHomeVC.bannerView.titleDataArray = [titleArray copy];
            
            if (pictureArray.count > 1) {
                theHomeVC.bannerView.isAutomaticScroll = YES;
            }else{
                theHomeVC.bannerView.isAutomaticScroll = NO;
                theHomeVC.bannerView.scrollEnabled = NO;
            }
            
            theHomeVC.bannerView.automaticScrollDelay = 5;
            theHomeVC.bannerView.cycleViewStyle = CycleViewStyleBoth;
            theHomeVC.bannerView.pageControlTintColor = [UIColor blackColor];
            theHomeVC.bannerView.pageControlCurrentColor = [UIColor whiteColor];
            theHomeVC.bannerView.delegate = theHomeVC;
            theHomeVC.bannerView.titleLabelTextColor = [UIColor whiteColor];
            
        }else{
            
            theHomeVC.maskImage.hidden = NO;
            [theHomeVC.maskImage setImage:[UIImage BBSImageNamed:@"/Home/bannerDefault@2x.png"]];
        }
        
    }];
    
}

#pragma mark - cycleview delegate  广告条
-(void)bannerClick:(NSInteger)index
{
    BBSBanner *banner = self.bannerArray[index];
    NSLog(@"link = %@, banner.title = %@, banner.picture = %@", banner.link, banner.title, banner.picture);
    NSLog(@"bannner.btype = %@", banner.btype);
    if ([banner.btype isEqualToString:@"link"]) {
        BBSUIBannerPreviewViewController *previewVC = [[BBSUIBannerPreviewViewController alloc] initWithTitle:banner.title];
        [previewVC setUrlString:banner.link];
        
        id controller;
        if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
        {
            controller = ((UITabBarController *)controller).selectedViewController;
        }
        else if ([MOBFViewController currentViewController].navigationController)
        {
            controller = [MOBFViewController currentViewController];
        }
        else
        {
            return;
        }
        
        [((UIViewController *)controller).navigationController pushViewController:previewVC animated:YES];
        
    }else if ([banner.btype isEqualToString:@"thread"])
    {
        BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithFid:banner.fid tid:banner.tid];
        
        id controller;
        if ([controller isKindOfClass:[UITabBarController class]] && ((UITabBarController *)controller).selectedViewController)
        {
            controller = ((UITabBarController *)controller).selectedViewController;
        }
        else if ([MOBFViewController currentViewController].navigationController)
        {
            controller = [MOBFViewController currentViewController];
        }
        else
        {
            return;
        }
        
        [((UIViewController *)controller).navigationController pushViewController:detailVC animated:YES];
    }
}
@end
