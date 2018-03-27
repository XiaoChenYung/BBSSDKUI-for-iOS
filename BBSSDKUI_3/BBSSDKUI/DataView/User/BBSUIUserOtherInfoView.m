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
#import "BBSUICollectionView.h"
#import "BBSUILoginViewController.h"
#import "BBSUIUserOtherInfoTableHeaderView.h"
#import "BBSUINavHeaderView.h"

#define BBSUIInformationCellHeight 65
#define BBSUIUserLogoutButtonHeight 50

@interface BBSUIUserOtherInfoView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BBSUICollectionView *threadTableView;

@property (nonatomic, strong) BBSUIUserOtherInfoTableHeaderView *tableHeaderView;

@property (nonatomic, assign) UserType userType;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, strong) BBSUINavHeaderView *navHeaderView;

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

- (void)configUI{
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

        _threadTableView = [[BBSUICollectionView alloc] initWithFrame:self.bounds type:CollectionViewTypeOtherUserThreadList];
        __weak UIView *headView = self.tableHeaderView;
        _threadTableView.collectionTableView.tableHeaderView = headView;
        [self addSubview: _threadTableView];
    
    }
    
    if (_userType == UserTypeMe) {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, NavigationBar_Height-20, 0));
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
        if ([BBSUIContext shareInstance].isIphoneX)
        {
            [_threadTableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(50, 0, NavigationBar_Height-20, 0));
            }];
        }
        else
        {
            [_threadTableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, NavigationBar_Height-20, 0));
            }];
        }
    }

    [self setTableHeaderView];
    
    if (_userType == UserTypeOther)
    {
        self.navHeaderView.tableViews = @[_threadTableView.collectionTableView].mutableCopy;
        [self addSubview:self.navHeaderView];
    }
    
}

- (BBSUINavHeaderView *)navHeaderView {
    
    if (!_navHeaderView) {
        
        _navHeaderView = [[BBSUINavHeaderView alloc] initWithFrame:CGRectMake(0, 20, DZSUIScreen_width, 64)];
        _navHeaderView.backgroundColor = [UIColor clearColor];
        
    }
    return _navHeaderView;
}

- (void)requestData:(void(^)(NSInteger))informationCount {

    _currentUser = [BBSUIContext shareInstance].currentUser;
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
                
                _navHeaderView.title = _currentUser.userName;
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
                
                return ;
            }
        }];
    }
}

- (void)setTableHeaderView {
    [_tableHeaderView setHeaderWithUser:_currentUser];
}



- (BBSUIUserOtherInfoTableHeaderView *)tableHeaderView{
    if (_tableHeaderView == nil) {
        
        CGFloat height;
        if (_userType == UserTypeMe) {
            height = 360;
        }else{
            height = 360;
        }
        _tableHeaderView = [[BBSUIUserOtherInfoTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, height) :_userType];
        
        [_tableHeaderView setHeaderWithUser:_currentUser];
    }
    return _tableHeaderView;
}

- (void)refreshData:(void(^)(NSInteger))informationCount {
    [self requestData:informationCount];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_userType == UserTypeMe) {
        return 3;
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
    if (indexPath.row == 0) {
        BBSUICollectionViewController *VC = [BBSUICollectionViewController new];
        VC.collectionViewType = CollectionViewTypeThreadFavorites;
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row == 1) {
        BBSUICollectionViewController *VC = [BBSUICollectionViewController new];
        VC.collectionViewType = CollectionViewTypeThreadList;
        [[MOBFViewController currentViewController].navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row == 2) {
        BBSUIHistoryViewController *VC = [BBSUIHistoryViewController new];
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



@end











