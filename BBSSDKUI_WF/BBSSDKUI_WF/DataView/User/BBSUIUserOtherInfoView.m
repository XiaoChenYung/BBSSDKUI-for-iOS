//
//  BBSUIUserOtherInfoView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserOtherInfoView.h"
#import "BBSUIUserInfoViewController.h"
#import "BBSUIContext.h"
#import "Masonry.h"
#import "BBSUIHistoryViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUIProcessHUD.h"
#import "BBSUICollectionViewController.h"
#import "BBSUIFansViewController.h"
#import "BBSUICollectionView.h"
#import "BBSUILoginViewController.h"
#import "NSString+BBSUIParagraph.h"
#import "BBSUIAttentionDynamicViewController.h"
#import "SVProgressHUD.h"



#define BBSUIInformationCellHeight 65
#define BBSUIUserLogoutButtonHeight 50

@interface BBSUIUserOtherInfoView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BBSUICollectionView *threadTableView;

@property (nonatomic, strong) __block BBSUIUserOtherInfoTableHeaderView *tableHeaderView;

@property (nonatomic, assign) UserType userType;

@property (nonatomic, strong) BBSUser *currentUser;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@end

@implementation BBSUIUserOtherInfoView

- (instancetype)init:(UserType)userType{
    if (self = [super init]) {
        _userType = userType;
        [self configUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame :(UserType)userType{
    if (self = [super initWithFrame:frame]) {
        _userType = userType;
        [self configUI];
    }
    
    return self;
}

#pragma mark - initUI
- (void)configUI
{
    self.backgroundColor = DZSUIColorFromHex(0xeaedf2);
    _currentUser = [BBSUIContext shareInstance].currentUser;
    
    if (_userType == UserTypeMe) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = BBSUIInformationCellHeight;
        _tableView.backgroundColor = DZSUI_BackgroundColor;
        _tableView.tableHeaderView = self.tableHeaderView;
        [self addSubview: _tableView];
    }else{
        _threadTableView = [[BBSUICollectionView alloc] init:CollectionViewTypeOtherUserThreadList];
        __weak UIView *headView = self.tableHeaderView;
        _threadTableView.collectionTableView.tableHeaderView = headView;
        [self addSubview: _threadTableView];
    
    }
    
    if (_userType == UserTypeMe) {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(20, 0, 60, 0));
        }];
        
        /**
         退出
         */
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:logoutButton];
        [logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.bottom.right.equalTo(@-15);
            make.height.equalTo(@BBSUIUserLogoutButtonHeight);
        }];
        [logoutButton setTitle:@"退出" forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [logoutButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [logoutButton setBackgroundColor:[UIColor whiteColor]];
        [logoutButton.layer setCornerRadius:3];
        [logoutButton.layer setMasksToBounds:YES];
        [logoutButton addTarget:self action:@selector(logoutButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [_threadTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, NavigationBar_Height-20, 0));
        }];
    }
}

#pragma mark - 数据加载

- (void)requestData:(void(^)(NSInteger))informationCount
{
    //_currentUser = [BBSUIContext shareInstance].currentUser;
    __weak typeof (self) weakSelf = self;
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    
    if (_userType == UserTypeOther) {    // 查看他人
        [BBSSDK getProfileInfoWithAuthorid:self.authorid time:strTime result:^(BBSUser *user, NSError *error) {
            
            if (!error) {
                NSString *token = _currentUser.token;
                _currentUser = user;
                _currentUser.token = token;
                _currentUser.uid = @(self.authorid);
                _threadTableView.authorid = user.uid;
                [weakSelf setTableHeaderView];
            }
        }];
    }
    
    else if (_userType == UserTypeMe) {
        [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
            
            if (!error) {
                _currentUser.favorites  = user.favorites;
                _currentUser.followers  = user.followers;
                _currentUser.threads    = user.threads;
                _currentUser.firends    = user.firends;
                _currentUser.notices    = user.notices;
                if (informationCount) informationCount(user.notices.integerValue);
                
                [BBSUIContext shareInstance].currentUser = _currentUser;
                
                [weakSelf.tableView reloadData];
                [weakSelf setTableHeaderView];
                
            }else{
                
                if (error.code == 9001200) {

                    [BBSUIContext shareInstance].currentUser = nil;
                    BBSUILoginViewController *vc = [[BBSUILoginViewController alloc] init];
                    
                    vc.cancelLoginBlock = ^(){
                        [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:NO];
                    };
                    
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    
                    if ([MOBFViewController currentViewController].navigationController) {
                        [[MOBFViewController currentViewController].navigationController presentViewController:nav animated:YES completion:nil];
                    }
//                    [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
                }
                
            }
             return ;
        }];
    }
}

#pragma mark - createTab 表格头
- (void)setTableHeaderView
{
    [self setCountButtonTitle];
    
    [self.tableHeaderView.addressButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",_currentUser.resideprovince,_currentUser.residecity,_currentUser.residedist] forState:UIControlStateNormal];
    self.tableHeaderView.nameLabel.text = _currentUser.userName;
    
    if (self.userType == UserTypeMe)
    {
        _tableHeaderView.originLabel.attributedText = [NSString bbs_stringWithString:_currentUser.sightml fontSize:12 defaultColorValue:@"6A7081" lineSpace:0 wordSpace:0];
    }
    else
    {
        _tableHeaderView.originLabel.attributedText = [NSString bbs_stringWithString:_currentUser.sightml fontSize:12 defaultColorValue:@"FFFFFF" lineSpace:0 wordSpace:0];
        _tableHeaderView.originLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (_currentUser.avatar) {
        MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
        [getter removeImageObserver:self.verifyImgObserver];
        NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", _currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
        if (![_currentUser.avatar containsString:@"?"])
        {
            urlString = _currentUser.avatar;
        }
        
        self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
            
            if (error) {
                _tableHeaderView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
            }else{
                _tableHeaderView.avatarImageView.image = image;
            }
        }];
    }
    
    if ([_currentUser.follow integerValue] == 0) {
        [_tableHeaderView.noticeButton setImage:[UIImage BBSImageNamed:@"/User/AttentionDark.png"] forState:UIControlStateNormal];
    }else{
        [_tableHeaderView.noticeButton setImage:[UIImage BBSImageNamed:@"/User/AlreadyAttention.png"] forState:UIControlStateNormal];
    }
}


- (BBSUIUserOtherInfoTableHeaderView *)tableHeaderView
{
    if (_tableHeaderView == nil) {
        
        CGFloat height;
        
        //MARK:=====修改头部高度=====
        if (_userType == UserTypeMe) {
            height = 180;
        }else{
            height = 339;
        }
        _tableHeaderView = [[BBSUIUserOtherInfoTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, height) :_userType];
        //_tableHeaderView = [[BBSUIUserOtherInfoTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 200)];
        
        _tableHeaderView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        if (_currentUser.avatar &&_userType == UserTypeMe) {
            MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
            [getter removeImageObserver:self.verifyImgObserver];
            NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", _currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
            if (![_currentUser.avatar containsString:@"?"])
            {
                urlString = _currentUser.avatar;
            }
            
            self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
                
                if (error) {
                    _tableHeaderView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
                }else{
                    _tableHeaderView.avatarImageView.image = image;
                }
            }];
        }
        
        _tableHeaderView.nameLabel.text = _currentUser.userName;
        if (self.userType == UserTypeMe)
        {
            _tableHeaderView.originLabel.attributedText = [NSString bbs_stringWithString:_currentUser.sightml fontSize:12 defaultColorValue:@"6A7081" lineSpace:0 wordSpace:0];
        }else
        {
            _tableHeaderView.originLabel.attributedText = [NSString bbs_stringWithString:_currentUser.sightml fontSize:12 defaultColorValue:@"FFFFFF" lineSpace:0 wordSpace:0];
            _tableHeaderView.originLabel.textAlignment = NSTextAlignmentCenter;
        }
        [_tableHeaderView.addressButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",_currentUser.resideprovince,_currentUser.residecity,_currentUser.residedist] forState:UIControlStateNormal];
        
        [_tableHeaderView.attentionCountButton addTarget:self action:@selector(attenTionBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_tableHeaderView.fansCountButton addTarget:self action:@selector(fansBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_tableHeaderView.noticeButton addTarget:self action:@selector(noticeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self setCountButtonTitle];
        
    }
    return _tableHeaderView;
}

- (void)showBigImage {
    NSLog(@"ddddddddddddd");
}

#pragma mark -
- (void)setCountButtonTitle {

    UIColor *colorDefault;
    UIColor *colorCount;
    
    NSString *strAttention;
    NSString *strFansCount;
    
    if (self.userType == UserTypeMe) {
        colorDefault = DZSUIColorFromHex(0x6A7081);
        colorCount = DZSUIColorFromHex(0x3C3C3C);
        
        strAttention = [NSString stringWithFormat:@"关注 %@",_currentUser.firends];
        strFansCount = [NSString stringWithFormat:@"粉丝 %@",_currentUser.followers];
    }else{
        colorDefault = [UIColor whiteColor];
        colorCount = [UIColor whiteColor];
        
        strAttention = [NSString stringWithFormat:@"关注 %@",_currentUser.firends];
        strFansCount = [NSString stringWithFormat:@"粉丝 %@",_currentUser.followers];
    }
    
    [_tableHeaderView.attentionCountButton setAttributedTitle:[self stringWithString:strAttention defaultColor:colorDefault countColor:colorCount] forState:UIControlStateNormal];

    [_tableHeaderView.fansCountButton setAttributedTitle:[self stringWithString:strFansCount defaultColor:colorDefault countColor:colorCount] forState:UIControlStateNormal];
}


- (NSMutableAttributedString *)stringWithString:(NSString *)string defaultColor:(UIColor *)defaultColor countColor:(UIColor *)countColor
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];

    [attr addAttributes:@{NSForegroundColorAttributeName:defaultColor,NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, 2)];
    [attr addAttributes:@{NSForegroundColorAttributeName:countColor,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(2, string.length - 2)];
    
    return attr;
}

- (void)attenTionBtnAction {
    BBSUIFansViewController *vc = [BBSUIFansViewController new];
    if (_userType == UserTypeMe) {
        vc.fansViewType = BBSUIFansTypeFirendsMe;
    }else{
        vc.fansViewType = BBSUIFansTypeFirendsOther;
        vc.currentUser = _currentUser;
    }
    
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)fansBtnAction {
    BBSUIFansViewController *vc = [BBSUIFansViewController new];
    if (_userType == UserTypeMe) {
        vc.fansViewType = BBSUIFansTypeFollowersMe;
    }else{
        vc.fansViewType = BBSUIFansTypeFollowersOther;
        vc.currentUser = _currentUser;
    }
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)noticeBtnAction {
    __weak typeof (self) weakSelf = self;
    
    if ([_currentUser.follow integerValue] == 0) {
        [BBSSDK followWithFollowuid:[_currentUser.uid integerValue] result:^(NSError *error) {
            if (! error) {
                NSLog(@"关注成功！");
                [weakSelf.tableHeaderView.noticeButton setImage:[UIImage BBSImageNamed:@"/User/AlreadyAttention.png"] forState:UIControlStateNormal];
                _currentUser.follow = @(1);
            }
        }];
    }
    else{
        [BBSSDK unfollowWithFollowuid:[_currentUser.uid integerValue] result:^(NSError *error) {
            if (! error) {
                NSLog(@"取消关注成功");
                [weakSelf.tableHeaderView.noticeButton setImage:[UIImage BBSImageNamed:@"/User/AttentionDark.png"] forState:UIControlStateNormal];
                _currentUser.follow = @(0);
            }
        }];
    }
}

- (void)refreshData:(void(^)(NSInteger))informationCount
{
    [self requestData:informationCount];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_userType == UserTypeMe) {
        return 4;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FansCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *text;
    NSString *detailText;
    NSString *imageName;
    switch (indexPath.row) {
        case 0:
            text = @"文章收藏";
            detailText = [NSString stringWithFormat:@"%@",_currentUser.favorites];
            imageName = @"/User/Attention_user.png";
            break;
            
        case 1:
            if (_userType == UserTypeMe) text = @"我的帖子";
            else text = @"他的帖子";
            detailText = [NSString stringWithFormat:@"%@",_currentUser.threads];
            imageName = @"/User/Thread_user.png";
            break;
            
        case 2:
            text = @"浏览记录";
            detailText = [NSString stringWithFormat:@"%lu",(long)[[BBSUICoreDataManage shareManager] historyCount]];
            imageName = @"/User/History.png";
            break;
        case 3:
            text = @"关注动态";
            //==============
            //detailText = [NSString stringWithFormat:@"%lu",(long)[[BBSUICoreDataManage shareManager] historyCount]];
            imageName = @"/User/icon_UserAttion.png";
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImage *icon = [UIImage BBSImageNamed:imageName];
    CGSize imageSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0); //获得用来处理图片的图形上下文。利用该上下文，你就可以在其上进行绘图，并生成图片 ,三个参数含义是设置大小、透明度 （NO为不透明）、缩放（0代表不缩放）
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_userType == UserTypeMe) {
        return 5;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {//文章收藏
        BBSUICollectionViewController *VC = [BBSUICollectionViewController new];
        VC.collectionViewType = CollectionViewTypeThreadFavorites;
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row == 1) {//我的帖子
        BBSUICollectionViewController *VC = [BBSUICollectionViewController new];
        VC.collectionViewType = CollectionViewTypeThreadList;
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row == 2) {//浏览记录
        BBSUIHistoryViewController *VC = [BBSUIHistoryViewController new];
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row == 3) {//关注动态
        BBSUIAttentionDynamicViewController *VC = [BBSUIAttentionDynamicViewController new];
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark Action
- (void)logoutButtonHandler:(UIButton *)button
{
    [BBSUIContext shareInstance].currentUser = nil;
    //    [BBSUIDataService cacheThreadDraft:nil];
    [BBSSDK logout:^(NSError *error) {
        NSLog(@"error = %@", error);
    }];
    
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}

@end


#define THEMEBACKGROUNDCOLOR DZSUIColorFromHex(0x6285F6)

@interface BBSUIUserOtherInfoTableHeaderView ()

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView *divViewLine;

@property (nonatomic, strong) UIView *horizontalViewLine;

@end

@implementation BBSUIUserOtherInfoTableHeaderView

- (instancetype)init :(UserType)userType{
    if (self = [super init]) {
        [self configUI];
        
        if (userType == UserTypeMe) {
            [self settingFrame_me];
        }else{
            [self settingFrame_other];
        }
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame :(UserType)userType{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
        
        if (userType == UserTypeMe) {
            [self settingFrame_me];
        }else{
            [self settingFrame_other];
        }
    }
    
    return self;
}

#pragma mark - 头像 名称 关注 粉丝
- (void)configUI {
    // 头像
    self.avatarImageView =
    ({
        BBSUIZoomImageView *avatar = [[BBSUIZoomImageView alloc] init];
        avatar.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:avatar];
        avatar.clipsToBounds = YES;
        avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        avatar.layer.borderWidth = 1.0f;

        avatar;
    });
    
    // 名称
    self.nameLabel =
    ({
        UILabel *name = [UILabel new];
        name.preferredMaxLayoutWidth = 100;
        [name setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        name.textColor = DZSUIColorFromHex(0xFFFFFF);
        name.font = [UIFont systemFontOfSize:16];
        name.textAlignment = NSTextAlignmentCenter;
        [self addSubview:name];
    
        name;
    });
    
    // 来源
    self.originLabel =
    ({
        UILabel *origin = [UILabel new];
        origin.textColor = DZSUIColorFromHex(0xFFFFFF);
        origin.font = [UIFont systemFontOfSize:12];
        origin.alpha = 0.5;
        origin.textAlignment = NSTextAlignmentCenter;
        [self addSubview:origin];
        
        origin;
    });
    
    // 地址
    self.addressButton =
    ({
        UIButton *address = [UIButton new];
        [address setTintColor:DZSUIColorFromHex(0xFFFFFF)];
        address.titleLabel.font = [UIFont systemFontOfSize:10];
        [address setImage:[UIImage BBSImageNamed:@"/User/Address.png"] forState:UIControlStateNormal];
        address.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:address];
        
        address;
    });
    
    // 关注和粉丝按钮
    self.divViewLine =
    ({
        UIView *viewLine = [UIView new];
        viewLine.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
        [self addSubview:viewLine];
        viewLine;
    });
    
    self.attentionCountButton =
    ({
        UIButton *attentCount = [UIButton new];
        [self addSubview:attentCount];
        
        attentCount;
    });
    
    self.fansCountButton =
    ({
        UIButton *fansCount = [UIButton new];
        [self addSubview:fansCount];

        fansCount;
    });
    
    
}

- (void)backAction:(UIButton *)button {
    [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
}

#pragma mark - 布局其他人
- (void)settingFrame_other{
    self.backgroundColor = THEMEBACKGROUNDCOLOR;
    
    CGFloat avatarWH = 86;
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(avatarWH, avatarWH));
        make.centerX.equalTo(self);
        make.top.equalTo(@57);
    }];
    self.avatarImageView.layer.cornerRadius = avatarWH/2;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self.avatarImageView.mas_bottom).offset(19);
        make.height.equalTo(@18);
    }];
    
    [self.originLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(13);
        make.centerX.equalTo(self);
        make.left.equalTo(@20);
    }];
    
    [self.addressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self.originLabel.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(200, 12));
    }];
    
    //======
    [self.divViewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-21);
        make.width.equalTo(@1).priorityHigh();
        make.height.equalTo(@10);
        make.centerX.equalTo(self);
        
    }];
    
    //关注
    [self.attentionCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-5);
        make.left.equalTo(@0);
        make.right.mas_equalTo(self.divViewLine.mas_left);
        make.height.equalTo(@46);
    }];
    
    //粉丝
    [self.fansCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@0);
        make.left.mas_equalTo(self.divViewLine.mas_right);
        make.bottom.height.equalTo(self.attentionCountButton);
    }];
    
    //MARK:=====分割线====
    UIView *lineView = [UIView new];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.mas_equalTo(self.fansCountButton.mas_bottom).offset(0);
        make.size.height.equalTo(@5);
    }];
    lineView.backgroundColor = [UIColor clearColor];
    
    self.noticeButton =
    ({
        UIButton *notice = [UIButton new];
        [notice setImage:[UIImage BBSImageNamed:@"/User/AttentionDark.png"] forState:UIControlStateNormal];
        [self addSubview:notice];
        [notice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(86, 30));
            make.top.mas_equalTo(self.addressButton.mas_bottom).offset(20);
        }];
        notice;
    });
    
    self.backButton =
    ({
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage BBSImageNamed:@"/Common/BackButton@2x.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self addSubview:back];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).with.offset(27);
            make.width.mas_equalTo(@44);
        }];
        back;
    });
}

#pragma mark - 布局我
- (void)settingFrame_me{
    CGFloat avatarWH = 72;
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(avatarWH, avatarWH));
        make.left.equalTo(@15).priorityHigh();
        make.top.equalTo(@20).priorityHigh();
    }];
    self.avatarImageView.layer.cornerRadius = avatarWH/2;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@32);
        make.left.mas_equalTo(self.avatarImageView.mas_right).offset(18);
        make.height.equalTo(@18);
    }];
    self.nameLabel.textColor = DZSUIColorFromHex(0x2D3037);
    
    UIView *viewLine = [UIView new];
    viewLine.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
    [self addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(@10);
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(9).priorityHigh();
        make.centerY.equalTo(self.nameLabel);
    }];
    

    [self.originLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@34);
        make.left.mas_equalTo(viewLine.mas_right).offset(9).priorityHigh();
        make.right.equalTo(@-30).priorityHigh();
        make.height.equalTo(@12);
    }];
    self.originLabel.textAlignment = NSTextAlignmentLeft;
    self.originLabel.textColor = DZSUIColorFromHex(0x6A7081);
    
    [self.addressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(17);
        make.left.mas_equalTo(self.avatarImageView.mas_right).offset(10);
        make.right.equalTo(@-15);
        make.height.equalTo(@12);
    }];
    self.addressButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.addressButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.addressButton setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
    
    [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(86, 30));
        make.top.mas_equalTo(self.addressButton.mas_bottom).offset(20);
    }];
    
    //竖线
    [self.divViewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-19);
        make.width.equalTo(@1).priorityHigh();
        make.height.equalTo(@15);
        make.centerX.equalTo(self);
    }];
    
    //关注
    [self.attentionCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.equalTo(@-14);
        make.left.equalTo(@0);
        make.right.mas_equalTo(self.divViewLine.mas_left);
        //make.height.equalTo(@15);
        make.bottom.equalTo(@-5);
        make.height.equalTo(@46);
        
    }];
    
    //粉丝
    [self.fansCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@0);
        make.left.mas_equalTo(self.divViewLine.mas_right);
        make.bottom.height.equalTo(self.attentionCountButton);
    }];
    
    // next
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage BBSImageNamed:@"Common/next.png"] forState:UIControlStateNormal];
    [self addSubview:nextButton];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(self.avatarImageView);
        make.right.equalTo(@-5);
    }];
    
    //MARK:============ 白线===========
    self.horizontalViewLine =
    ({
        UIView *viewLine = [UIView new];
        viewLine.backgroundColor = DZSUIColorFromHex(0xEAEDF2);
        [self addSubview:viewLine];
        
        [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.bottom.mas_equalTo(self.divViewLine.mas_top).offset(-14-9);
            make.height.equalTo(@1);
        }];
        viewLine;
    });
    
    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonNext addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonNext];
    
    [buttonNext mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.mas_equalTo(self.horizontalViewLine.mas_top);
    }];
    
    UIView *viewLine2 = [[UIView alloc] init];
    [self addSubview:viewLine2];
    [viewLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.mas_equalTo(@-1);
        make.height.equalTo(@5);
    }];
    
    viewLine2.backgroundColor = DZSUIColorFromHex(0xffffff);
    
    //viewLine2.hidden = YES;
    [self bringSubviewToFront:self.avatarImageView];
}


- (void)nextAction:(UIButton *)button {
    BBSUIUserInfoViewController *vc = [BBSUIUserInfoViewController new];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}


@end









