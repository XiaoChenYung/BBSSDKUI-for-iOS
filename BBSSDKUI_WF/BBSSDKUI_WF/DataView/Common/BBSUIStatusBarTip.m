//
//  BBSUIStatusBarTip.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/4.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIStatusBarTip.h"

@interface BBSUIStatusBarTip ()
{
    UILabel     * msgLab;         //消息标签
    UIImageView * logoImgV;       //logo图标对象
    UIImage     * logoImg;        //logo图标
    CGFloat       height;         //高度
    CGFloat       screenWidth;    //屏幕宽度
    CGFloat       screenHeight;   //屏幕高度
}
@property(nonatomic,retain)UILabel  * statusLab;
@property(nonatomic,retain)UIImageView  * logImgView;
@property(nonatomic,retain)NSTimer  * runTimer;           //停留时钟

@end

@implementation BBSUIStatusBarTip

static  BBSUIStatusBarTip  * msb;
//构建单例
+(BBSUIStatusBarTip *)shareStatusBar{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        msb = [[BBSUIStatusBarTip alloc]init];
    });
    return msb;
}

//初始化UI
-(id)init
{
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    height = statusFrame.size.height;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    self = [super initWithFrame:statusFrame];
    if(self){
        self.frame = statusFrame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.windowLevel = UIWindowLevelStatusBar + 1.0;
        self.backgroundColor = [UIColor blackColor];
//        logoImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"29x29" ofType:@"png"]];
//        logoImgV = [[UIImageView alloc]initWithFrame:CGRectMake(kPading, kPading / 2.0, kLogoWidth, kLogoWidth)];
//        logoImgV.backgroundColor = [UIColor clearColor];
//        [self addSubview:logoImgV];
//        msgLab = [[UILabel alloc]initWithFrame:CGRectMake(logoImgV.frame.origin.x + kPading + logoImgV.frame.size.width, 0.0, screenWidth - (logoImgV.frame.origin.x + kPading + logoImgV.frame.size.width), statusFrame.size.height)];
        if ([[UIDevice currentDevice] inner_isIphoneXOrLater]) {
            statusFrame.size.height = 14;
            statusFrame.origin.y = 30;
            msgLab = [[UILabel alloc] initWithFrame:statusFrame];
        } else {
            msgLab = [[UILabel alloc] initWithFrame:statusFrame];
        }
        [msgLab setTextAlignment:NSTextAlignmentCenter];
        msgLab.backgroundColor = [UIColor clearColor];
        msgLab.font = [UIFont systemFontOfSize:14.0];
        msgLab.textColor = [UIColor whiteColor];
        [self addSubview:msgLab];
        
        //注册单击事件
        UITapGestureRecognizer  * tapStatusBar = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTopBar:)];
        [self addGestureRecognizer:tapStatusBar];
        
        //注册状态栏方向监听事件
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenOrientationChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    
    return self;
}

- (void)postBegin
{
    self.backgroundColor = [UIColor blackColor];
//    [msgLab setText:@"帖子发布中"];
    [self showTextMessage:@"帖子发布中" delayTime:0];
}

- (void)postFailed:(NSString *)msg
{
    self.backgroundColor = DZSUIColorFromHex(0xF85050);
    if (msg) {
        [msgLab setText:msg];
    }else{
        [msgLab setText:@"帖子发布失败"];
    }
//    [self showTextMessage:@"帖子发布失败" delayTime:0];
    [self dismissStatusTip:5];

}

- (void)postSuccess
{
    self.backgroundColor = DZSUIColorFromHex(0x00AA49);
//    [self showTextMessage:@"帖子发布成功" delayTime:2];
    [msgLab setText:@"帖子发布成功"];
    [self dismissStatusTip:2];
    
}

//处理单击状态栏消息
- (void)tapTopBar:(UITapGestureRecognizer *)tapGesture{
//    if(_whcStatusBardelegate && [_whcStatusBardelegate respondsToSelector:@selector(didTapTouchWHCStatusBarMessageDoSomething)]){
//        [_whcStatusBardelegate didTapTouchWHCStatusBarMessageDoSomething];
//    }
}

- (void)dismissStatusTip:(NSInteger)delay
{
    [self.runTimer invalidate];
    self.runTimer = nil;
    if (delay > 0) {
        self.runTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(dismissTimer) userInfo:nil repeats:NO];
    }
}

//显示状态栏消息
-(void)showTextMessage:(NSString*)strMessage delayTime:(NSInteger)delay
{
    if(logoImg == nil){
        logoImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"29x29" ofType:@"png"]];
    }
    
    logoImgV.image = logoImg;
    msgLab.text = strMessage;
    __block CGRect  stateFrame = self.frame;
    stateFrame.origin.y = - ([[UIDevice currentDevice] inner_isIphoneXOrLater] ? 44 : 20);
    self.frame = stateFrame;
    [UIView animateWithDuration:0.2 animations:^{
        stateFrame.origin.y = 0.0;
        self.frame = stateFrame;
    }];
    [self makeKeyAndVisible];

    [self dismissStatusTip:delay];
//    if (delay > 0) {
//        self.runTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(dismissTimer) userInfo:nil repeats:NO];
//    }
}
-(void)showMessage:(NSString*)strMessage logImage:(UIImage *)logImage delayTime:(NSInteger)delay{
    logoImg = logImage;
    [self showTextMessage:strMessage delayTime:delay];
}
-(void)dismissTimer{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        msb.hidden = YES;
    });
}
#pragma mark - screenChange
-(void)screenOrientationChange:(NSNotification*)notif
{
    UIInterfaceOrientation  orientation = [[[notif userInfo] objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            self.transform = CGAffineTransformIdentity;
            self.frame = CGRectMake(0.0, 0.0, screenWidth, height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.transform = CGAffineTransformMakeRotation(M_PI);
            self.center = CGPointMake(screenWidth / 2.0, screenHeight - height / 2.0);
            self.bounds = CGRectMake(0.0, 0.0, screenWidth, height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.center = CGPointMake(height / 2.0, screenHeight / 2.0);
            self.bounds = CGRectMake(0.0, 0.0, screenHeight, height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.center = CGPointMake(screenWidth - height / 2.0, screenHeight / 2.0);
            self.bounds = CGRectMake(0.0, 0.0, screenHeight, height);
            break;
        default:
            break;
    }
}

@end
