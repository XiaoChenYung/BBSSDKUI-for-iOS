//
//  BBSUIUserInfoView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/21.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserInfoView.h"
#import "UIView+BBSUIExt.h"
#import "Masonry.h"
#import "BBSUIUserInfoTableViewCell.h"
#import <MOBFoundation/MOBFViewController.h>
#import "BBSUIContext.h"
#import "BBSUIEmailSendViewController.h"
#import "BBSUIFansViewController.h"
#import "BBSUICollectionViewController.h"
#import "BBSUIInformationViewController.h"
#import "BBSUIDarkBackView.h"
#import "BBSUIModifySignatureViewController.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIProcessHUD.h"
#import "BBSUIZoomImageView.h"
#import "BBSUIUserOtherInfoViewController.h"
#import "BBSUIPickerView.h"
#import "NSString+BBSUIParagraph.h"
#import "BBSUICoreDataManage.h"

#define BBSUIAvatarImageViewWidth 50
#define BBSUIUserTableViewHeaderViewHeight 180
#define BBSUIUserInfoCellHeight 47
#define BBSUIUserLogoutButtonHeight 50
#define BBSUIUserAvatarTmpPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BBSUIUserAvatar.JPEG"]

@interface BBSUIUserInfoView () <UITableViewDelegate,
                                 UITableViewDataSource,
                                 UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate,
                                 UIPickerViewDataSource,
                                 UIPickerViewDelegate,
                                 UIActionSheetDelegate,
                                 UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *userInfoTableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) BBSUIZoomImageView *avatarImageView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *logoutButton;

@property (nonatomic, strong) UIImageView *testImageView;

@property (nonatomic, strong) UILabel *genderLabel;

@property (nonatomic, strong) UILabel *birthdayLabel;

@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) UILabel *signatureLabel;

@property (nonatomic, strong) UILabel *clearCacheLabel;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *pickerView;


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
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bbs_width, BBSUIUserTableViewHeaderViewHeight)];
    [self.headerView setBackgroundColor:[UIColor whiteColor]];
    self.avatarImageView = [[BBSUIZoomImageView alloc] init];
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
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, NavigationBar_Height, 0));
    }];
    [self.userInfoTableView setDelegate:self];
    [self.userInfoTableView setDataSource:self];
//    [self.userInfoTableView setTableHeaderView:self.headerView];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.userInfoTableView.frame), DZSUIScreen_height - NavigationBar_Height - BBSUIUserTableViewHeaderViewHeight - 47 * 5 - 20 - 18)];
//    [self.userInfoTableView setTableFooterView:self.footerView];
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
    
    __weak typeof(self) theUserInfoView = self;
    [BBSSDK getUserInfoWithUserName:_currentUser.userName result:^(BBSUser *user, NSError *error) {
        if (!error) {
            _currentUser = user;
            [BBSUIContext shareInstance].currentUser = _currentUser;
            
            [theUserInfoView.userInfoTableView reloadData];
            
            if (_currentUser.avatar) {
                
                MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
                [getter removeImageObserver:self.verifyImgObserver];
                theUserInfoView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
                NSString *urlString = [NSString stringWithFormat:@"%@&timestamp=%f", _currentUser.avatar,[[NSDate date] timeIntervalSince1970]];
                
                NSLog(@"++++++++++ urlstring = %@",urlString);
                
                if (![_currentUser.avatar containsString:@"?"])
                {
                    urlString = _currentUser.avatar;
                }
                
                theUserInfoView.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:urlString] result:^(UIImage *image, NSError *error) {
                    
                    if (error) {
                        theUserInfoView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
                    }else{
                        theUserInfoView.avatarImageView.image = image;
                    }
                    
                }];
            }else{
                theUserInfoView.avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
            }
        }
    }];
    
}

#pragma mark - uitableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    
    if (section == 1) {
        return 5;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userInfoCellIdentifier = @"UserInfoCellIdentifier";
    BBSUIUserInfoTableViewCell *userInfoCell = [[BBSUIUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoCellIdentifier];
    
    CGFloat right = - 15;
    if ([self isIpad])
    {
        right = - 50;
    }
    
    switch (indexPath.row) {
        // 头像、用户名
        case 0:
        {
            if (indexPath.section == 0) {
                self.avatarImageView = [BBSUIZoomImageView new];
                self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
                [userInfoCell.contentView addSubview:self.avatarImageView];
                [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(userInfoCell.contentView.mas_centerY);
                    make.left.equalTo(@15);
                    make.size.mas_equalTo(CGSizeMake(BBSUIAvatarImageViewWidth, BBSUIAvatarImageViewWidth));
                }];
                [self.avatarImageView.layer setCornerRadius:BBSUIAvatarImageViewWidth/2];
                [self.avatarImageView.layer setMasksToBounds:YES];
                [self.avatarImageView setImage:[UIImage BBSImageNamed:@"/User/AvatarDefault.png"]];
                userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                userInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else{
                UILabel *nickNamelabel = [UILabel new];
                nickNamelabel.textAlignment = NSTextAlignmentRight;
                nickNamelabel.lineBreakMode = NSLineBreakByTruncatingTail;
                [userInfoCell.contentView addSubview:nickNamelabel];
                [nickNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                    make.right.equalTo(userInfoCell.contentView).with.offset(right);
                    make.left.equalTo(@80);
                }];
                [nickNamelabel setFont:[UIFont systemFontOfSize:15]];
                [nickNamelabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
                [nickNamelabel setText:self.currentUser.userName];
                [userInfoCell setTitle:@"用户名"];
                userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            break;
        }
        // 性别
        case 1:
        {
            UILabel *genderLabel = [UILabel new];
            [userInfoCell.contentView addSubview:genderLabel];
            [genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(@0);
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
            userInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            self.genderLabel = genderLabel;
            
            break;
        }
        // 个性签名
        case 2:
        {
            UILabel *signatureLabel = [UILabel new];
            signatureLabel.textAlignment = NSTextAlignmentRight;
            signatureLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [userInfoCell.contentView addSubview:signatureLabel];
            [signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(@0);
                make.left.equalTo(@90);
            }];

            signatureLabel.attributedText = [NSString bbs_stringWithString:self.currentUser.sightml fontSize:15 defaultColorValue:@"3C3C3C" lineSpace:0 wordSpace:0];
            signatureLabel.textAlignment = NSTextAlignmentRight;
            [userInfoCell setTitle:@"个性签名"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            userInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            self.signatureLabel = signatureLabel;
            break;
        }
        // 地区
        case 3:
        {
            UILabel *addressLabel = [UILabel new];
            [userInfoCell.contentView addSubview:addressLabel];
            [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(0);
            }];
            [addressLabel setFont:[UIFont systemFontOfSize:15]];
            [addressLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [addressLabel setText:[NSString stringWithFormat:@"%@ %@ %@",_currentUser.resideprovince,_currentUser.residecity,_currentUser.residedist]];
            [userInfoCell setTitle:@"地区"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            userInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            self.addressLabel = addressLabel;
            break;
        }
        // 生日
        case 4:{
            UILabel *birthdayLabel = [UILabel new];
            [userInfoCell.contentView addSubview:birthdayLabel];
            [birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(0);
            }];
            [birthdayLabel setFont:[UIFont systemFontOfSize:15]];
            [birthdayLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            
            NSString *month = [NSString stringWithFormat:@"%@",self.currentUser.birthmonth];
            if (month.length == 1)
                month = [NSString stringWithFormat:@"0%@",month];
            
            NSString *day = [NSString stringWithFormat:@"%@",self.currentUser.birthday];
            if (day.length == 1)
                day = [NSString stringWithFormat:@"0%@",day];
            
            
            [birthdayLabel setText:[NSString stringWithFormat:@"%@-%@-%@",self.currentUser.birthyear,month,day]];
            [userInfoCell setTitle:@"生日"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            userInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            self.birthdayLabel = birthdayLabel;
            break;
        }
        // 邮箱
        case 5:
        {
            UILabel *emailLabel = [UILabel new];
            [userInfoCell.contentView addSubview:emailLabel];
            [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(right);
            }];
            [emailLabel setFont:[UIFont systemFontOfSize:15]];
            [emailLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [emailLabel setText:self.currentUser.email];
            [userInfoCell setTitle:@"邮箱"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        // 用户组
        case 6:
        {
            UILabel *groupLabel = [UILabel new];
            [userInfoCell.contentView addSubview:groupLabel];
            [groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(right);
            }];
            [groupLabel setFont:[UIFont systemFontOfSize:15]];
            [groupLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            [groupLabel setText:self.currentUser.groupName];
            [userInfoCell setTitle:@"用户组"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        // 状态
        case 7:
        {
            UIButton *activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [userInfoCell.contentView addSubview:activeButton];
            [activeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(right);
                make.height.mas_equalTo(25);
            }];
            [activeButton.layer setCornerRadius:3];
            [activeButton.layer setMasksToBounds:YES];
//            [activeButton.layer setBorderWidth:0.5];
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
            [activeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [activeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [userInfoCell setTitle:@"状态"];
            break;
        }
            
        // 清理缓存
        case 8:
        {
            UILabel *groupLabel = [UILabel new];
            self.clearCacheLabel = groupLabel;
            [userInfoCell.contentView addSubview:groupLabel];
            [groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(userInfoCell.mas_centerY);
                make.right.equalTo(userInfoCell.contentView).with.offset(right);
            }];
            [groupLabel setFont:[UIFont systemFontOfSize:15]];
            [groupLabel setTextColor:DZSUIColorFromHex(0x3C3C3C)];
            CGFloat dataSize = [[BBSUICoreDataManage shareManager] getDataSize];
            
            if (dataSize < 0)
            {
                dataSize = 0;
            }
            
            groupLabel.text = [NSString stringWithFormat:@"%fM",dataSize];
            
            if (dataSize < 1)
            {
                dataSize = dataSize *1024;
                groupLabel.text = [NSString stringWithFormat:@"%.2fK",dataSize];
            }
            
            [userInfoCell setTitle:@"清理缓存"];
            userInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        
        default:
            break;
    }
    
    return userInfoCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 75;
    }
    
    return BBSUIUserInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1  && indexPath.row == 0) {
        
    }
    
    // 头像
    if (indexPath.section == 0) {
        [self pickerWithTitles:@[@"相机",@"从相册选择"] selectors:@[@"takePhoto",@"pickImgInAlbum"]];
    }
    
    // 性别
    if (indexPath.row == 1) {
        [self pickerWithTitles:@[@"男",@"女"] selectors:@[@"setGender:",@"setGender:"]];
    }
    
    // 个性签名
    if (indexPath.row == 2) {
        BBSUIModifySignatureViewController *vc = [BBSUIModifySignatureViewController new];
        
        __weak typeof(self) weakSelf = self;
        vc.SightmlBlock = ^(NSString *sightml){
            [weakSelf editUserInfoWithGender:-1 birthday:nil residence:nil sightml:sightml token:_currentUser.token avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil success:^{
                weakSelf.signatureLabel.attributedText = [NSString bbs_stringWithString:sightml fontSize:15 defaultColorValue:@"3C3C3C" lineSpace:0 wordSpace:0];
                weakSelf.signatureLabel.textAlignment = NSTextAlignmentRight;
                
                _currentUser.sightml = sightml;
                [BBSUIContext shareInstance].currentUser = _currentUser;
            }];
        };
        [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
    }
    
    // 地区
    if (indexPath.row == 3) {
        BBSPickerView *picker = [BBSPickerView new];
        picker.confirmBlock = ^(NSString *province, NSString *city, NSString *region){
            [self setAddressWithProvince:province city:city region:region];
        };
    }
    
    // 生日
    if (indexPath.row == 4) {
        BBSDatePicker *picker = [BBSDatePicker new];
        picker.confirmBlock = ^(NSDate *date){
            [self setBirthday:date];
        };
    }
    
    // 邮箱
    if (indexPath.row == 5) {
        
    }
    
    // 用户组
    if (indexPath.row == 6) {
        
    }
    
    // 状态
    if (![self.currentUser.emailStatus integerValue] && indexPath.row == 7) {
        BBSUIEmailSendViewController *emailSendVC = [[BBSUIEmailSendViewController alloc] initWithEmail:self.currentUser.email userName:self.currentUser.userName sendType:BBSUIEmailSendTypeNeedIdentity];
        [[MOBFViewController currentViewController].navigationController pushViewController:emailSendVC animated:YES];
    }

    // 清理缓存
    if (indexPath.row == 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定清空缓存数据？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
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


/**
 picker 选择组件

 @param titles title数组
 @param selectorStrings title对应组件点击事件名
 */
- (void)pickerWithTitles:(NSArray <NSString *>*)titles selectors:(NSArray <NSString *>*)selectorStrings

{
    if (titles.count != selectorStrings.count) {
        return;
    }
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIPopoverPresentationController *popoverController = alertVC.popoverPresentationController;
        popoverController.sourceView = self;
        popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,DZSUIScreen_height,1.0,1.0);
        
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                SEL sel = NSSelectorFromString(selectorStrings[idx]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self respondsToSelector:sel]) {
                        [self performSelector:sel withObject:obj];
                    }
                });
//                SEL sel = NSSelectorFromString(selectorStrings[idx]);
//                IMP imp = [[MOBFViewController currentViewController] methodForSelector:sel];
//                void (*func)(id, SEL) = (void *)imp;
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([self respondsToSelector:sel]) {
//                        func([MOBFViewController currentViewController], sel);
//                    }
//                });
            }];
            
            [alertVC addAction:action];
        }];
        
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MOBFViewController currentViewController] presentViewController:alertVC animated:YES completion:nil];
        });
    }
    else {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: nil];
        for (NSString *title in titles) {
            [sheet addButtonWithTitle:title];
        }
        
        [sheet showInView:self];
    }
}

- (void)setGender:(NSString *)gender{

    NSInteger genderIndex = 0;
    if ([gender isEqualToString:@"保密"]) genderIndex = 0;
    if ([gender isEqualToString:@"男"]) genderIndex = 1;
    if ([gender isEqualToString:@"女"]) genderIndex = 2;
    
    __weak typeof(self) weakSelf = self;
    [self editUserInfoWithGender:genderIndex birthday:nil residence:nil sightml:nil token:_currentUser.token avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil success:^{
        weakSelf.genderLabel.text = gender;
    }];
}

- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //        [SVProgressHUD showInfoWithStatus:@"相机不可用.=_="];
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self;
    [[MOBFViewController currentViewController] presentViewController:cameraVc animated:YES completion:nil];
}

- (void)pickImgInAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        //        [SVProgressHUD showInfoWithStatus:@"图库不可用.=_="];
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self;
    [[MOBFViewController currentViewController] presentViewController:cameraVc animated:YES completion:nil];
}

- (void)setBirthday:(NSDate *)date{
    if (!date)
    {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MM"];
    NSString *month = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd"];
    NSString *day = [dateFormatter stringFromDate:date];
    
    if (month.length == 1) {
        month = [NSString stringWithFormat:@"0%@",month];
    }
    if (day.length == 1) {
        day = [NSString stringWithFormat:@"0%@",day];
    }
    
    NSString  *string = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    
    __weak typeof(self) weakSelf = self;
    [self editUserInfoWithGender:-1 birthday:string residence:nil sightml:nil token:_currentUser.token avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil success:^{
        weakSelf.birthdayLabel.text = string;
    }];
}

- (void)setAddressWithProvince:(NSString *)province
                          city:(NSString *)city
                        region:(NSString *)region
{
    NSString *residence = [NSString stringWithFormat:@"%@-%@-%@",province, city, region];
    
    __weak typeof(self) weakSelf = self;
    [self editUserInfoWithGender:-1 birthday:nil residence:residence sightml:nil token:_currentUser.token avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil success:^{
        weakSelf.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@",province, city, region];
    }];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //Dismiss the Image Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage *scaleImage = [selectedImage scaleImage];
    
    CGFloat min = scaleImage.size.height < scaleImage.size.width ? scaleImage.size.height : scaleImage.size.width;
    
    CGFloat x = 0;
    if (min == scaleImage.size.height) {
        x = (scaleImage.size.width - scaleImage.size.height)/2;
    }
    CGFloat y = 0;
    if (min == scaleImage.size.width) {
        y = (scaleImage.size.height - scaleImage.size.width)/2;
    }
    
    UIImage *cropImage = [scaleImage cropImageWithX:x y:0 width:min height:min];
    
    [self pathOfSavedImage:cropImage];
    
//    [self.avatarImageView setImage:selectedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self upLoadAvatar:selectedImage];
}

- (void)upLoadAvatar:(UIImage *)image {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:BBSUIUserAvatarTmpPath]) {
        __weak typeof(self) weakSelf = self;
        [BBSSDK uploadAvatarWithContentPath:BBSUIUserAvatarTmpPath scales:@[@48, @120, @200] result:^(NSArray *urls, NSError *error) {
            
            if (!error) {
                
                NSMutableDictionary *avatarUrlDic = [NSMutableDictionary dictionary];
                
                if (urls.count >= 1) {
                    NSDictionary *avatarDic = urls[0];
                    avatarUrlDic[@"avatarSmall"] = avatarDic[@"48"];
                    avatarUrlDic[@"avatarMiddle"] = avatarDic[@"120"];
                    avatarUrlDic[@"avatarBig"] = avatarDic[@"200"];
                    
                }
                [weakSelf editUserInfoWithGender:-1 birthday:nil residence:nil sightml:nil token:_currentUser.token avatarBigUrl:avatarUrlDic[@"avatarBig"] avatarMiddleUrl:avatarUrlDic[@"avatarMiddle"] avatarSmallUrl:avatarUrlDic[@"avatarSmall"] success:^{
                    
                    //[[MOBFImageGetter sharedInstance] removeImageForURL:[NSURL URLWithString:avatarUrlDic[@"avatarSmall"]]];
                    //[[MOBFImageGetter sharedInstance] removeImageForURL:[NSURL URLWithString:avatarUrlDic[@"avatarMiddle"]]];
                    //[[MOBFImageGetter sharedInstance] removeImageForURL:[NSURL URLWithString:avatarUrlDic[@"avatarBig"]]];
                    
                    [weakSelf.avatarImageView setImage:image];
                }];
                
                
                
                
                return ;
                
            }else{
                
                [BBSUIProcessHUD showFailInfo:@"上传头像失败" delay:3];
            }
            
        }];
    }else{
        
    }
}

- (NSString *)pathOfSavedImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:BBSUIUserAvatarTmpPath]) {
        [fileManager removeItemAtPath:BBSUIUserAvatarTmpPath error:nil];
    }
    
    [fileManager createFileAtPath:BBSUIUserAvatarTmpPath contents:nil attributes:nil];
    [data writeToFile:BBSUIUserAvatarTmpPath atomically:NO];
    
    return BBSUIUserAvatarTmpPath ;
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
}

- (void)editUserInfoWithGender:(NSInteger)genderIndex
                      birthday:(nullable NSString *)birthday
                     residence:(nullable NSString *)residence
                       sightml:(nullable NSString *)sightml
                         token:(nonnull NSString *)token
                  avatarBigUrl:(nullable NSString *)avatarBigUrl
               avatarMiddleUrl:(nullable NSString *)avatarMiddleUrl
                avatarSmallUrl:(nullable NSString *)avatarSmallUrl
                       success:(void (^)())success;
{
    //修改用户信息
    [BBSSDK editUserInfoWithGender:genderIndex birthday:birthday residence:residence sightml:sightml avatarBigUrl:avatarBigUrl avatarMiddleUrl:avatarMiddleUrl avatarSmallUrl:avatarSmallUrl result:^(BBSUser *user, NSError *error) {
        
        if (!error) {
            if (user.gender)            _currentUser.gender             = user.gender;
            if (user.birthday)          _currentUser.birthday           = user.birthday;
            if (user.resideprovince)    _currentUser.resideprovince     = user.resideprovince;
            if (user.residecity)        _currentUser.residecity         = user.residecity;
            if (user.residedist)        _currentUser.residedist         = user.residedist;
            if (user.residecommunity)   _currentUser.residecommunity    = user.residecommunity;
            if (user.residesuite)       _currentUser.residesuite        = user.residesuite;
            if (user.sightml)           _currentUser.sightml            = user.sightml;
            if (user.avatar)            _currentUser.avatar             = user.avatar;
            [BBSUIContext shareInstance].currentUser = _currentUser;
            
            success();
            
        }else{
            
            if (error.code == 900111) {
                [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
            }else{
                NSLog(@"%lu  %@",error.code,error);
                
                [BBSUIProcessHUD showFailInfo:@"更新用户信息失败" delay:3];
            }
            
            return ;
        }
        
    }];

}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[BBSUICoreDataManage shareManager] clearCache];
        self.clearCacheLabel.text = @"0K";
    }
}

#pragma mark - tool

- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
@end
