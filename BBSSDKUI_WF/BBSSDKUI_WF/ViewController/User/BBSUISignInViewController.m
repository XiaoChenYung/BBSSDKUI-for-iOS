//
//  BBSUISignInViewController.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/2.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUISignInViewController.h"
#import "BBSUISignInTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <WebKit/WebKit.h>
#import <MOBFoundation/MOBFoundation.h>
#import "BBSUIContext.h"
#import "UIView+BBSUITipView.h"
#import "BBSThread+BBSUI.h"
#import "BBSUIBaseView.h"



@interface BBSUISignInViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *notSginInLab;

/**
 累计签到
 */
@property (nonatomic, strong) UILabel *cumulativeSignLab ;
/**
 今日688人已经签到
 */
@property (nonatomic, strong) UILabel *alreadyLab ;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UIImageView *noDataImageView;

@end

static NSString *cellIdentifier = @"SignInCell";

@implementation BBSUISignInViewController

#pragma mark - 懒加载 Lazy Load
- (UIView *)noDataView
{
    if (!_noDataView) {
            _noDataView = [[BBSUIBaseView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height)];
            _noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DZSUIScreen_width - 80) / 2, DZSUIScreen_height/4, 80, 80)];
            [_noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wnr@2x.png"]];
            [_noDataView addSubview:_noDataImageView];
            
            _noDataLabel = [UILabel new];
            [_noDataLabel setFrame:CGRectMake(0, BBS_BOTTOM(_noDataImageView), DZSUIScreen_width, 40)];
            [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
            [_noDataLabel setTextColor:[UIColor grayColor]];
            [_noDataLabel setText:@"暂无内容"];
            [_noDataView addSubview:_noDataLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
         tap.numberOfTapsRequired = 1;
        [_noDataView addGestureRecognizer:tap];
        
    }
    return _noDataView;
}

- (void)tapClick
{
    [self _updateWkWebView];
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签到";
    [self _createWKWebView];
    [self _updateWkWebView];
    self.noDataView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)_createWKWebView
{
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height)];
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView setOpaque:NO];
    [self.view addSubview:self.webView];
}

- (void)_updateWkWebView
{
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD show];
     __weak typeof(self) weakSelf = self;
    [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
        if (!error)
        {
            self.noDataView.hidden = YES;
            [BBSSDK getSginUrlWithType:@"2" userUid:user.uid enterSignUrl:user.signurl time:time Result:^(NSString *sginUrl, NSError *error) {
                NSURL * ubanAgreementUrl = [NSURL URLWithString:sginUrl];
                NSURLRequest * ubanAgreementRequest = [NSURLRequest requestWithURL:ubanAgreementUrl];
                [weakSelf.webView loadRequest:ubanAgreementRequest];
                weakSelf.webView.scrollView.showsVerticalScrollIndicator = NO;
                [SVProgressHUD dismissWithDelay:0.5];
            }];
        }
        else
        {
            self.noDataView.hidden = NO;
            [self.view addSubview:self.noDataView];
            [self.noDataImageView setImage:[UIImage BBSImageNamed:@"/Common/wwl@2x.png"]];
            [self.noDataLabel setText:@"网络不佳，请再次刷新"];
            
            [SVProgressHUD dismissWithDelay:0.5];
        }
    }];
}
#pragma mark - 获取随机数
- (NSString *)getRandomStringWithNum:(NSInteger)num
{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < num; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

#pragma mark - UI
- (void)_initUI
{
    self.title = @"签到";
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:signInBtn];
    [signInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.centerX.mas_equalTo(0);
        //make.top.left.mas_equalTo(50);
        make.size.mas_equalTo(CGSizeMake(104, 104));
    }];
    [signInBtn setBackgroundImage:[UIImage BBSImageNamed:@"User/bigSignIn.png"] forState:UIControlStateNormal];
    [signInBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //今日未签到
    UILabel * notSginInLab = [[UILabel alloc] init];
    [self.view addSubview:notSginInLab];
    [notSginInLab mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(signInBtn.mas_bottom).mas_equalTo(15);
        make.centerX.mas_equalTo(signInBtn.mas_centerX);
    }];
    notSginInLab.text = @"今日未签到";
    notSginInLab.textColor = DZSUIColorFromHex(0x29292F);
    notSginInLab.font = BBSFont(15);

    //累计签到
    UILabel *cumulativeSignLab = [[UILabel alloc] init];
    [self.view addSubview:cumulativeSignLab];
    [cumulativeSignLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(notSginInLab.mas_bottom).mas_equalTo(18);
        make.centerX.mas_equalTo(notSginInLab);
        make.size.mas_equalTo(CGSizeMake(104, 20));
    }];
    cumulativeSignLab.backgroundColor = DZSUIColorFromHex(0xEAEDF2);
    cumulativeSignLab.textColor = DZSUIColorFromHex(0x9A9CAA);
    cumulativeSignLab.text = @"累计签到233天";
    cumulativeSignLab.layer.cornerRadius = 10.0;
    cumulativeSignLab.layer.masksToBounds = YES;
    cumulativeSignLab.textAlignment = NSTextAlignmentCenter;
    cumulativeSignLab.font = BBSFont(10);
    _cumulativeSignLab = cumulativeSignLab;

    //今日688人已经签到
    UILabel *alreadyLab = [UILabel new];
    [self.view addSubview:alreadyLab];
    [alreadyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cumulativeSignLab.mas_bottom).mas_equalTo(16);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(32);
    }];
    alreadyLab.backgroundColor = DZSUIColorFromHex(0xEAEDF2);
    alreadyLab.textColor = DZSUIColorFromHex(0x4E4F57);
    alreadyLab.font = BBSFont(12);
    alreadyLab.text = @"    今日 66834 人已签到";
    _alreadyLab = alreadyLab;
    [self _createTableView];
}

- (void)_createTableView
{
    UITableView *tableView  = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_alreadyLab.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
    }];
    tableView.separatorColor = DZSUIColorFromHex(0xDDE1EB);
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [tableView registerClass:[BBSUISignInTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
}

#pragma mark - 签到
- (void)btnClicked:(UIButton *)sender
{
    //播放视频
   // NSURL *url1 = [ResourceUtil videoUrl:userInfo[@"url"]];
    //http://player.youku.com/embed/XMzUwNzY4MDAwNA==
    NSString *ss = @"http://tupian.51tniu.com/vedios/4B6AE638DE3297084B17FBFC83951033.mp4";
    NSURL *url = [NSURL URLWithString:ss];
    
    if (IOS_VERSION >= 9.0) {
        AVPlayer *player = [AVPlayer playerWithURL:url];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        [self presentViewController:playerViewController animated:YES completion:nil];
        [playerViewController.player play];
    }else{
        MPMoviePlayerViewController  * moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentViewController:moviePlayerController animated:YES completion:nil];
    }
    
}

#pragma mark - UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUISignInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUISignInTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
