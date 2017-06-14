//
//  BBSUIUserInfoView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserInfoView.h"
#import "UIViewExt.h"
#import "Masonry.h"
#import "BBSUIUserInfoTableViewCell.h"
#import <MOBFoundation/MOBFViewController.h>
#import "BBSUIContext.h"
#import "BBSUIEmailSendViewController.h"

#define BBSUIAvatarImageViewWidth 100
#define BBSUIUserTableViewHeaderViewHeight 180
#define BBSUIUserInfoCellHeight 47
#define BBSUIUserLogoutButtonHeight 50

@interface BBSUIUserInfoView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *userInfoTableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *logoutButton;

@property (nonatomic, strong) UIImageView *testImageView;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@end

@implementation BBSUIUserInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.verifyImgObserver];
}

- (void)configureUI
{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, BBSUIUserTableViewHeaderViewHeight)];
    [self.headerView setBackgroundColor:[UIColor whiteColor]];
    self.avatarImageView = [UIImageView new];
     [self.headerView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerView.mas_centerX);
        make.top.equalTo(self.headerView.mas_top).with.offset(30);
        make.size.mas_equalTo(CGSizeMake(BBSUIAvatarImageViewWidth, BBSUIAvatarImageViewWidth));
    }];
    [self.avatarImageView.layer setCornerRadius:BBSUIAvatarImageViewWidth/2];
    [self.avatarImageView.layer setMasksToBounds:YES];
    [self.avatarImageView setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault.png"]];
   
    
    self.userInfoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self addSubview:self.userInfoTableView];
    [self.userInfoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.userInfoTableView setDelegate:self];
    [self.userInfoTableView setDataSource:self];
    [self.userInfoTableView setTableHeaderView:self.headerView];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.userInfoTableView.frame), DZSUIScreen_height - NavigationBar_Height - BBSUIUserTableViewHeaderViewHeight - 47 * 5 - 20 - 18)];
    [self.userInfoTableView setTableFooterView:self.footerView];
    [self.footerView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logoutButton setFrame:CGRectMake(15, CGRectGetHeight(self.footerView.frame) - BBSUIUserLogoutButtonHeight - 20, DZSUIScreen_width - 30, BBSUIUserLogoutButtonHeight)];
    [self.footerView addSubview:self.logoutButton];
    [self.logoutButton setTitle:@"退出" forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [self.logoutButton.layer setCornerRadius:3];
    [self.logoutButton.layer setMasksToBounds:YES];
    [self.logoutButton setBackgroundColor:DZSUIColorFromHex(0x50A3D3)];
    [self.logoutButton addTarget:self action:@selector(logoutButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    _testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self addSubview:_testImageView];
}

- (void)setCurrentUser:(BBSUser *)currentUser
{
    _currentUser = currentUser;
    
    if (_currentUser.avatar) {
        __weak typeof(self) theUserInfoView = self;
        MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
        [getter removeImageObserver:self.verifyImgObserver];
        self.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", _currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
        self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
            
            if (error) {
                theUserInfoView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
            }else{
                theUserInfoView.avatarImageView.image = image;
            }
            
        }];
//        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:_currentUser.avatar] result:^(UIImage *image, NSError *error) {
//            theUserInfoView.avatarImageView.image = image;
//        }];
    }else{
        self.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
    }
    
    [self.userInfoTableView reloadData];
    
}

#pragma mark - uitableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userInfoCellIdentifier = @"UserInfoCellIdentifier";
    BBSUIUserInfoTableViewCell *userInfoCell = [[BBSUIUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoCellIdentifier];
    
    switch (indexPath.row) {
        case 0:
        {
            UILabel *nickNamelabel = [UILabel new];
            [userInfoCell.contentView addSubview:nickNamelabel];
            [nickNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(-15);
            }];
            [nickNamelabel setFont:[UIFont systemFontOfSize:15]];
            [nickNamelabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [nickNamelabel setText:self.currentUser.userName];
            [userInfoCell setTitle:@"昵称"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 1:
        {
            UILabel *genderLabel = [UILabel new];
            [userInfoCell.contentView addSubview:genderLabel];
            [genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(-15);
            }];
            [genderLabel setFont:[UIFont systemFontOfSize:15]];
            [genderLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            NSString *gender = nil;
            if ([self.currentUser.gender integerValue] == 0) {
                gender = @"保密";
            }else if([self.currentUser.gender integerValue] == 1)
            {
                gender = @"男";
            }else if([self.currentUser.gender integerValue] == 2){
                gender = @"女";
            }
            [genderLabel setText:gender];
            [userInfoCell setTitle:@"性别"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 2:
        {
            UILabel *emailLabel = [UILabel new];
            [userInfoCell.contentView addSubview:emailLabel];
            [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(-15);
            }];
            [emailLabel setFont:[UIFont systemFontOfSize:15]];
            [emailLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [emailLabel setText:self.currentUser.email];
            [userInfoCell setTitle:@"邮箱"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 3:
        {
            UILabel *groupLabel = [UILabel new];
            [userInfoCell.contentView addSubview:groupLabel];
            [groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(-15);
            }];
            [groupLabel setFont:[UIFont systemFontOfSize:15]];
            [groupLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [groupLabel setText:self.currentUser.groupName];
            [userInfoCell setTitle:@"用户组"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 4:
        {
            UIButton *activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [userInfoCell.contentView addSubview:activeButton];
            [activeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(-15);
                make.height.mas_equalTo(25);
            }];
            [activeButton.layer setCornerRadius:3];
            [activeButton.layer setMasksToBounds:YES];
            [activeButton.layer setBorderWidth:0.5];
            if ([self.currentUser.emailStatus integerValue] == 1) {
                [activeButton setTitle:@"已激活" forState:UIControlStateNormal];
                [activeButton.layer setBorderColor:DZSUIColorFromHex(0x50A3D3).CGColor];
                [activeButton setTitleColor:DZSUIColorFromHex(0x50A3D3) forState:UIControlStateNormal];
                userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                [activeButton setTitle:@"未激活" forState:UIControlStateNormal];
                [activeButton.layer setBorderColor:DZSUIColorFromHex(0xFF6B70).CGColor];
                [activeButton setTitleColor:DZSUIColorFromHex(0xFF6B70) forState:UIControlStateNormal];
                userInfoCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            [activeButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [activeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [userInfoCell setTitle:@"状态"];
            break;
        }
        default:
            break;
    }
    
    return userInfoCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BBSUIUserInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.currentUser.emailStatus integerValue] && indexPath.row == 4) {
        BBSUIEmailSendViewController *emailSendVC = [[BBSUIEmailSendViewController alloc] initWithEmail:self.currentUser.email userName:self.currentUser.userName sendType:BBSUIEmailSendTypeNeedIdentity];
        [[MOBFViewController currentViewController].navigationController pushViewController:emailSendVC animated:YES];
    }
}

#pragma mark - ui handler
- (void)logoutButtonHandler:(UIButton *)button
{
    [BBSUIContext shareInstance].currentUser = nil;
//    [BBSUIDataService cacheThreadDraft:nil];
    
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
