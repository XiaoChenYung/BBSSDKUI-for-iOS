//
//  BBSUIShareView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/29.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIShareView.h"
#import <BBSSDK/BBSThread.h>
#import <ShareSDK/IMOBFShareComponent.h>
#import <MOBFoundation/MOBFComponentManager.h>

//分享item高度
#define  ItemWH                 48
#define  Row                    3
#define  Space                 14
#define ShareViewTag  1000 // 分享视图tag


@interface BBSUIShareView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *shareRegionView;
@property (nonatomic, strong) NSMutableArray  *titleArr;
@property (nonatomic, strong) NSMutableArray  *imageArr;
@property (nonatomic, assign) float  shareRegionHeight;
@property (nonatomic, strong) id shareContent;
@property (nonatomic, assign) NSInteger flag;

@end

@implementation BBSUIShareView

+ (instancetype)sharedInstance{
    static BBSUIShareView *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BBSUIShareView alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init:(id)content flag:(NSInteger)flag{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.flag = flag;
        self.shareContent = content;
        [self configure];
        [self loadShareRegion];
    }
    
    return self;
}


- (void)configure {
    self.tag = ShareViewTag;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];// 设置背景透明度
    self.imageArr = [NSMutableArray arrayWithArray:@[@"Share/weixin.png", @"Share/pengyouquan.png",@"Share/QQ.png",@"Share/QQzone.png"]];//,@"Share/weibo.png"
    self.titleArr=[NSMutableArray arrayWithArray:@[@"微信好友", @"微信朋友圈",@"QQ",@"QQ空间"]] ;//,@"微博"
    // 加载Tap手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
}

/**
 *  加载分享区域
 */
- (void)loadShareRegion {
    
    
    //控件行数
//    int    section=self.titleArr.count%Row==0 ? (int)(self.titleArr.count/Row):(int)(self.titleArr.count/Row+1);
    //NSLog(@"section=%d",section);
    
    CGFloat itemHeight = 62;
    
    self.shareRegionHeight = 304;
    
    // 加载分享区域
    self.shareRegionView = [[UIView alloc] initWithFrame:(CGRect){0, DZSUIScreen_height, DZSUIScreen_width,self.shareRegionHeight}];
    self.shareRegionView.backgroundColor = DZSUIColorFromHex(0xffffff);
    
    [self addSubview:self.shareRegionView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, DZSUIScreen_width, 16)];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = DZSUIColorFromHex(0x2D3037);
    title.font = [UIFont systemFontOfSize:16];
    title.text = @"分享至";
    [self.shareRegionView addSubview:title];
    
    /* 加载content区域 */
    UIView *contentView = [[UIView alloc] init];
    
    CGFloat contentViewWH = (ItemWH+72)*3;
    contentView.frame = CGRectMake((self.frame.size.width-contentViewWH)/2,CGRectGetMaxY(title.frame)+4,contentViewWH,self.shareRegionHeight);
    [self.shareRegionView addSubview:contentView];
    
    
    /* 加载分享组件 */
    CGFloat itemWidth = contentViewWH/3;
    NSInteger count = self.titleArr.count;
    
    for (int i = 0; i < count; i++) {
        CGRect itemFrame = CGRectMake(itemWidth * (i % Row),(Space+itemHeight+12+24) *(i/Row),itemWidth,Space+itemHeight+12+24);
        SSShareViewItem *item = [[SSShareViewItem alloc] initWithFrame:itemFrame];
        [item configureViewWithObject:@[self.imageArr[i],self.titleArr[i]]];

        [contentView addSubview:item];
        
        // target
        item.tag = i;
        
        [item addTarget:self action:@selector(clickShareViewItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 加载按钮
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(0,self.shareRegionHeight-50,self.frame.size.width,50);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DZSUIColorFromHex(0x2D3037) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.shareRegionView addSubview:cancelButton];
    
//    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self show];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /**
     *  shareRegionView及其子视图 touch事件不做处理
     */
    if (touch.view.tag != ShareViewTag) {
        return NO;
    }else {
        return YES;
    }
}

- (void)show
{
    if (!self.superview)
    {
        // 添加到window
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.shareRegionView.frame = (CGRect){0, DZSUIScreen_height - self.shareRegionHeight, DZSUIScreen_width,self.shareRegionHeight};
        } completion:^(BOOL finished) {
            
        }];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
}

/**
 *  隐藏分享视图
 */
- (void) hide {
    if (self.superview) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.shareRegionView.frame = (CGRect){0, DZSUIScreen_height, DZSUIScreen_width, self.shareRegionHeight};
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}


#pragma mark - event response

- (void)clickShareViewItem:(SSShareViewItem *)sender
{
    BBSThread *thread;
    if ([self.shareContent isKindOfClass:[BBSThread class]]) {
        thread = (BBSThread *)self.shareContent;
    }
    
    NSLog(@"%@",thread.images);
    NSLog(@"%@",thread.subject);
    NSLog(@"%@",thread.summary);
    NSLog(@"%@",thread.threadurl);
    
    id images = nil;
    NSString *title = nil;
    NSString *url = nil;
    
    if (self.flag == 0)// 论坛
    {
        if (thread.images.count == 0) {
            
            if (thread.forumPic)
            {
                thread.images = @[thread.forumPic];
            }
            else
            {
                thread.images = @[[UIImage BBSImageNamed:@"Forum/ForumNormalIcon.png"]];
            }
            
        }
        
        images = thread.images;
        title = thread.subject;
        url = thread.threadurl;
    }
    else
    {
        if (thread.pic && thread.pic.length > 0)
        {
            images = @[thread.pic];
        }
        else
        {
            images = @[[UIImage BBSImageNamed:@"Forum/ForumNormalIcon.png"]];
        }
        
        title = thread.title;
        url = thread.shareurl;
    }
    
    
    //分享操作
    NSArray *components = [[MOBFComponentManager defaultManager] getComponents:@protocol(IMOBFShareComponent)];
    if (components.count > 0) {
        id<IMOBFShareComponent>  ShareComponent = components[0];
        //分享操作
        //1、创建分享参数
        NSMutableDictionary *shareParams = [ShareComponent SSDKSetupShareParamsByText:thread.summary
                                                                               images:images
                                                                                  url:[NSURL URLWithString:url]
                                                                                title:title
                                                                                 type:3
                                                                       dataDictionary:nil];
        
        //有的平台要客户端分享需要加此方法，例如微博
        //        [shareParams SSDKEnableUseClientShare];
        
        NSUInteger platformType;
        switch (sender.tag) {
            case 0:
                platformType = 22;
                break;
            case 1:
                platformType = 23;
                break;
            case 2:
                platformType = 24;
                break;
                //            case 3:
                //                platformType = SSDKPlatformTypeSinaWeibo;
                //                break;
            case 3:
                platformType = 6;
                break;
            default:
                platformType = 0;
                break;
        }
        
        if (ShareComponent && [ShareComponent conformsToProtocol:@protocol(IMOBFShareComponent)])
        {
            [ShareComponent share:platformType parameters:shareParams onStateChanged:nil];
        }
    }
    
    [self hide];
}

- (UIViewController *)viewController {
    /// Finds the view's view controller.
    
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = self.superview;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    // If the view controller isn't found, return nil.
    return nil;
}

@end


#pragma mark - SSShareViewItem

@interface SSShareViewItem ()
@property (nonatomic, strong)UIImageView *iconView;
@property (nonatomic, strong)UILabel *titleLabel;
@end


@implementation SSShareViewItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
    {
        return nil;
    }
    [self loadContentView];
    return self;
}

- (void)loadContentView {
    //加载iconView
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;

    CGFloat iconWH = 48;
    CGFloat padding = 72;
    self.iconView.frame = CGRectMake(padding/2,24,iconWH,iconWH);
    [self addSubview:self.iconView];
    
    //加载titleLabel
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.titleLabel.textColor = DZSUIColorFromHex(0x6A7081);
    self.titleLabel.frame = CGRectMake(0,CGRectGetMaxY(self.iconView.frame)+14,self.frame.size.width,12);
    [self addSubview:self.titleLabel];
}

- (void)configureViewWithObject:(id)obj {
    NSArray *array = obj;
    self.iconView.image = [UIImage BBSImageNamed:array[0]];
    self.titleLabel.text = array[1];
}
@end
