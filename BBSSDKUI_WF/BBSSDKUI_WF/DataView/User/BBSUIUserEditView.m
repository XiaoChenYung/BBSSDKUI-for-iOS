//
//  BBSUIUserEditView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/19.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserEditView.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"
#import <MOBFoundation/MOBFViewController.h>
#import "BBSUIContext.h"
#import <BBSSDK/BBSUser.h>
#import "BBSUIProcessHUD.h"
#import <MOBFoundation/MOBFImage.h>
#import "UIImage+BBSFunction.h"

#define BBSUIAvatarImageViewWidth 100

#define BBSUIUserAvatarTmpPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BBSUIUserAvatar.JPEG"]

@interface BBSUIUserEditView ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView   *avagtarImageView;
@property (nonatomic, strong) UILabel       *nickNameLabel;
@property (nonatomic, strong) UIButton      *maleButton;
@property (nonatomic, strong) UIButton      *femaleButton;
@property (nonatomic, strong) UIButton      *secretButton;
@property (nonatomic, strong) UIButton      *commitButton;
@property (nonatomic, strong) UIButton      *cancelButton;
@property (nonatomic, strong) UIButton      *cameraButton;

@property (nonatomic, strong) UIButton      *currentGenderButton;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) NSInteger genderIndex;//0保密 1

@property (nonatomic, assign) BBSUIEditUserInfoType editType;

@property (nonatomic, strong) UIButton *lateSettingButton;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *verifyImgObserver;

@property (nonatomic, strong) UIActivityIndicatorView *activeityIndicatorView;

@end

@implementation BBSUIUserEditView

- (instancetype)initWithFrame:(CGRect)frame user:(BBSUser *)currentUser editType:(BBSUIEditUserInfoType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        if (_currentUser) {
            _currentUser = currentUser;
        }else{
            _currentUser = [BBSUIContext shareInstance].currentUser;
        }
        _editType = type;
        [self configureUI];
        [self setUser:_currentUser];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
        _currentUser = [BBSUIContext shareInstance].currentUser;
        [self setUser:[BBSUIContext shareInstance].currentUser];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
        _currentUser = [BBSUIContext shareInstance].currentUser;
        [self setUser:[BBSUIContext shareInstance].currentUser];
    }
    
    return self;
}

- (void)configureUI
{
    self.avagtarImageView = [UIImageView new];
    [self addSubview:self.avagtarImageView];
    [self.avagtarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).with.offset(168-NavigationBar_Height);
        make.size.mas_equalTo(CGSizeMake(BBSUIAvatarImageViewWidth, BBSUIAvatarImageViewWidth));
    }];
    [self.avagtarImageView.layer setCornerRadius:BBSUIAvatarImageViewWidth / 2];
    [self.avagtarImageView.layer setMasksToBounds:YES];

    self.nickNameLabel = [UILabel new];
    [self addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avagtarImageView.mas_bottom).with.offset(106 - 15);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.height.mas_equalTo(0);
    }];
    [self.nickNameLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
//    [self.nickNameLabel setFont:[UIFont systemFontOfSize:14]];
    [self.nickNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.nickNameLabel setText:@"刘先生"];
    
    UIView *horizontalSeperateView = [UIView new];
    [self addSubview:horizontalSeperateView];
    [horizontalSeperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.top.equalTo(self.nickNameLabel.mas_bottom).with.offset(0);
        make.height.mas_equalTo(0);
    }];
    [horizontalSeperateView setBackgroundColor:DZSUIColorFromHex(0xB4B4B4)];
    [horizontalSeperateView setAlpha:0.5];
    
    self.femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.femaleButton];
    [self.femaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_centerX).with.offset(-8);
        make.top.equalTo(horizontalSeperateView.mas_bottom).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    
    }];
    [self.femaleButton addTarget:self action:@selector(genderClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.femaleButton setImage:[UIImage BBSImageNamed:@"/Login&Register/GenderDeselected.png"] forState:UIControlStateNormal];
    
    UILabel *femaleLabel = [UILabel new];
    [self addSubview:femaleLabel];
    [femaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).with.offset(8);
        make.centerY.mas_equalTo(self.femaleButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 15));
    }];
    [femaleLabel setText:@"女"];
    [femaleLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
    
    UIView *leftSeperateView = [UIView new];
    [self addSubview:leftSeperateView];
    [leftSeperateView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.femaleButton.mas_left).with.offset(-25);
        make.right.equalTo(self.mas_centerX).with.offset(-55);
        make.top.mas_equalTo(horizontalSeperateView.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(0, 30));
    }];
    [leftSeperateView setBackgroundColor:DZSUIColorFromHex(0xB4B4B4)];
    [leftSeperateView setAlpha:0.5];
    
    UIView *rightSeperateView = [UIView new];
    [self addSubview:rightSeperateView];
    [rightSeperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).with.offset(55);
        make.centerY.mas_equalTo(leftSeperateView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(0, 30));
    }];
    [rightSeperateView setBackgroundColor:DZSUIColorFromHex(0xB4B4B4)];
    [rightSeperateView setAlpha:0.5];
    
    UILabel *maleLabel = [UILabel new];
    [self addSubview:maleLabel];
    [maleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.femaleButton.mas_left).with.offset(-51);
        make.centerY.mas_equalTo(self.femaleButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 15));
    }];
    [maleLabel setTextAlignment:NSTextAlignmentRight];
    [maleLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
    [maleLabel setText:@"男"];
    
    self.maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.maleButton];
    [self.maleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).with.offset(-115);
        make.centerY.mas_equalTo(self.femaleButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.maleButton setImage:[UIImage BBSImageNamed:@"/Login&Register/GenderDeselected.png"] forState:UIControlStateNormal];
    [self.maleButton addTarget:self action:@selector(genderClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    self.secretButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.secretButton];
    [self.secretButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(femaleLabel.mas_right).with.offset(51);
        make.centerY.mas_equalTo(self.femaleButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.secretButton addTarget:self action:@selector(genderClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.secretButton setImage:[UIImage BBSImageNamed:@"/Login&Register/GenderDeselected.png"] forState:UIControlStateNormal];
    
    UILabel *secretLabel = [UILabel new];
    [self addSubview:secretLabel];
    [secretLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secretButton.mas_right).with.offset(15);
        make.centerY.mas_equalTo(self.femaleButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 15));
    }];
    [secretLabel setText:@"保密"];
    [secretLabel setTextColor:DZSUIColorFromHex(0xB4B4B4)];
    [secretLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIView *horizontalSeperateButtonView = [UIView new];
    [self addSubview:horizontalSeperateButtonView];
    [horizontalSeperateButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftSeperateView.mas_bottom).with.offset(10);
        make.left.mas_equalTo(@15);
        make.right.mas_equalTo(@(-15));
        make.height.mas_equalTo(@0);
    }];
    [horizontalSeperateButtonView setBackgroundColor:DZSUIColorFromHex(0xB4B4B4)];
    [horizontalSeperateButtonView setAlpha:0.5];
    
    // 稍后设置
//    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.cancelButton setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
//    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [self addSubview:self.cancelButton];
//    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self).offset(-31-NavigationBar_Height);
//        make.centerX.equalTo(self);
//        make.width.equalTo(@100);
//        make.height.equalTo(@20);
//    }];
//    [self.cancelButton setTitle:@"稍后设置" forState:UIControlStateNormal];
//    [self.cancelButton addTarget:self action:@selector(cancelClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.editType == BBSUIEditUserInfoTypeRegister) {
        self.lateSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.lateSettingButton];
        [self.lateSettingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-65);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(@80);
        }];
        [self.lateSettingButton setTitle:@"稍后设置" forState:UIControlStateNormal];
        [self.lateSettingButton setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
        [self.lateSettingButton addTarget:self action:@selector(lateSettingButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.commitButton];
    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.lateSettingButton.mas_top).with.offset(-44);
        make.left.mas_equalTo(@15);
        make.right.mas_equalTo(@(-15));
        make.height.mas_equalTo(@42);
    }];
    [self.commitButton setBackgroundColor:DZSUIColorFromHex(0x5B7EF0)];
    [self.commitButton.layer setCornerRadius:4];
    [self.commitButton.layer masksToBounds];
    [self.commitButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commitButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [self.commitButton addTarget:self action:@selector(commitClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.cameraButton];
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avagtarImageView).with.offset(70);
        make.left.equalTo(self.mas_centerX).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.cameraButton setImage:[UIImage BBSImageNamed:@"/User/Camera.png"] forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(cameraButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    //删除头像地址
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:BBSUIUserAvatarTmpPath]) {
        [manager removeItemAtPath:BBSUIUserAvatarTmpPath error:nil];
    }
    
}

- (void)lateSettingButtonHandler:(UIButton *)button
{
    [[MOBFViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUser:(BBSUser *)user
{
    _currentUser = user;
    
    if (self.currentUser.avatar) {
        __weak typeof(self) theEidtView = self;
        MOBFImageGetter *getter = [MOBFImageGetter sharedInstance];
        [getter removeImageObserver:self.verifyImgObserver];
        self.avagtarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        NSString *avatarURL = [self.currentUser.avatar stringByAppendingFormat:@"&timestamp=%f", [NSDate date].timeIntervalSince1970];
        self.verifyImgObserver = [getter getImageWithURL:[NSURL URLWithString:avatarURL] result:^(UIImage *image, NSError *error) {
            if (error) {
                theEidtView.avagtarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
            }else{
                theEidtView.avagtarImageView.image = image;
            }
            
        }];
    }else{
        self.avagtarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
    }

    [self.nickNameLabel setText:_currentUser.userName];
    
    if ([_currentUser.gender integerValue] == 1){
        [self genderClickHandler:self.maleButton];
    }else if ([_currentUser.gender integerValue] == 2){
        [self genderClickHandler:self.femaleButton];
    }else{
        [self genderClickHandler:self.secretButton];
    }
}

- (void)cameraButtonHandler:(UIButton *)cameraButton
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popoverController = alertVC.popoverPresentationController;
    popoverController.sourceView = self;
    popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,self.frame.size.height,1.0,1.0);
    
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction * pickImg = [UIAlertAction actionWithTitle:@"从手机相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImgInAlbum];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:takePhoto];
    [alertVC addAction:pickImg];
    [alertVC addAction:cancel];
    [[MOBFViewController currentViewController] presentViewController:alertVC animated:YES completion:nil];
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
    //    cameraVc.allowsEditing = YES ;
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
    //    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self;
    [[MOBFViewController currentViewController] presentViewController:cameraVc animated:YES completion:nil];
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
    
    [self.avagtarImageView setImage:selectedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ui handler
- (void)genderClickHandler:(UIButton *)button
{
    if (button == self.currentGenderButton) {
        return;
    }
    
    [self.currentGenderButton setImage:[UIImage BBSImageNamed:@"/Login&Register/GenderDeselected.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage BBSImageNamed:@"/Login&Register/GenderSelected.png"] forState:UIControlStateNormal];
    
    self.currentGenderButton = button;
}

- (void)commitClickHandler:(UIButton *)button
{
    if (!_activeityIndicatorView) {
        _activeityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activeityIndicatorView];
        [_activeityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(255);
            make.centerX.equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        [_activeityIndicatorView startAnimating];
    }
    
    if (self.currentGenderButton == self.maleButton) {
        _genderIndex = 1;
    }else if (self.currentGenderButton == self.femaleButton){
        _genderIndex = 2;
    }else{
        _genderIndex = 0;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:BBSUIUserAvatarTmpPath]) {
        __weak typeof(self) theEditView = self;
        [BBSSDK uploadAvatarWithContentPath:BBSUIUserAvatarTmpPath scales:@[@48, @120, @200] result:^(NSArray *urls, NSError *error) {
            
            if (!error) {
                
                NSMutableDictionary *avatarUrlDic = [NSMutableDictionary dictionary];
                
                if (urls.count >= 1) {
                    NSDictionary *avatarDic = urls[0];
                    avatarUrlDic[@"avatarSmall"] = avatarDic[@"48"];
                    avatarUrlDic[@"avatarMiddle"] = avatarDic[@"120"];
                    avatarUrlDic[@"avatarBig"] = avatarDic[@"200"];
                }
                
                [theEditView editUserInfo:avatarUrlDic];
                
                return ;
                
            }else{
                
                [_activeityIndicatorView removeFromSuperview];
                _activeityIndicatorView = nil;
                [BBSUIProcessHUD showFailInfo:@"上传头像失败" delay:3];
            }
            
        }];
    }else{
        if (self.genderIndex != [self.currentUser.gender integerValue]) {
            [self editUserInfo:nil];
        }else{
            
            [self.activeityIndicatorView removeFromSuperview];
            self.activeityIndicatorView = nil;
            if (self.editType == BBSUIEditUserInfoTypeRegister) {
                [[MOBFViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
            }else{
                [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];

            }
        }
    }
    
    
}

- (void)cancelClickHandler:(UIButton *)button{
    [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
}

- (void)editUserInfo:(NSDictionary *)avatarUrlDic
{
    //修改用户信息
    __weak typeof(self) theEidtView = self;
    [BBSSDK editUserInfoWithGender:self.genderIndex birthday:nil residence:nil sightml:nil avatarBigUrl:avatarUrlDic[@"avatarBig"] avatarMiddleUrl:avatarUrlDic[@"avatarMiddle"] avatarSmallUrl:avatarUrlDic[@"avatarSmall"] result:^(BBSUser *user, NSError *error) {
        
        [theEidtView.activeityIndicatorView removeFromSuperview];
        theEidtView.activeityIndicatorView = nil;
        
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
            
        }else{
            
            if (error.code == 900111) {
                [BBSUIProcessHUD showFailInfo:@"登录信息过期，请重新登录后设置" delay:3];
            }else{
                [BBSUIProcessHUD showFailInfo:@"更新用户信息失败" delay:3];
            }
            
            return ;
        }
        
        if (theEidtView.editType == BBSUIEditUserInfoTypeRegister) {
            [[MOBFViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
            
        }
        
        
    }];
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





@end
