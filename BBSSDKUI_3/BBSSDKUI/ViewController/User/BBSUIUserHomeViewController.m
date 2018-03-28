//
//  BBSUIUserHomeViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserHomeViewController.h"
#import "BBSUICollectionViewController.h"
#import "BBSUIHistoryViewController.h"
#import "BBSUINavHeaderView.h"
#import "BBSUIUserOtherInfoTableHeaderView.h"
#import "NSObject+SimpleKVONotification.h"
#import "BBSUIContext.h"
#import "BBSUILoginViewController.h"
#import "BBSUICoreDataManage.h"
#import "BBSUIInformationViewController.h"
#import "BBSUISettingViewController.h"
#import "MJRefresh.h"
#define NAVBARHEIGHT 64.0f
#define FONTMAX 15.0
#define FONTMIN 14.0
#define PADDING 15.0
#define CATEGORY  @[@"收藏",@"帖子",@"历史"]

const CGFloat HeaderHeight = 360;

@interface BBSUIUserHomeViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *currentTableView;

@property (nonatomic, strong) BBSUINavHeaderView *navHeaderView;

@property (nonatomic, strong) UIView *headerView;
/**
 滑动事件相关
 */
@property (nonatomic, strong) UIScrollView *segmentScrollView;
@property (nonatomic, strong) UIView *currentSelectedItemView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;

// 存放button
@property(nonatomic,strong) NSMutableArray *titleButtons;
// 记录上一个button
@property (nonatomic, strong) UIButton *previousButton;
// 记录上一个button的index
@property (nonatomic, assign) NSInteger previousIndex;
// 存放控制器
@property(nonatomic,strong) NSMutableArray *controlleres;


// 存放TableView
@property(nonatomic,strong)NSMutableArray *tableViews;

// 记录上一个偏移量
@property (nonatomic, assign) CGFloat lastTableViewOffsetY;

@property (nonatomic, strong) BBSUIUserOtherInfoTableHeaderView *tableHeaderView;


@property (nonatomic, assign) BOOL needRequestData;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, strong) UIView *redView;

@end

@implementation BBSUIUserHomeViewController

- (instancetype)initWithUser:(BBSUser *)user
{
    self = [super init];
    if (self) {
        self.currentUser = user;
    }
    
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (_needRequestData)
    {
        [self requestData];
    }
    else
    {
        _needRequestData = YES;
    }

    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _currentUser = [BBSUIContext shareInstance].currentUser;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.titleButtons = [[NSMutableArray alloc] initWithCapacity:CATEGORY.count];
        self.controlleres = [[NSMutableArray alloc] initWithCapacity:CATEGORY.count];
        self.tableViews = [[NSMutableArray alloc] initWithCapacity:CATEGORY.count];
        
        [self.view addSubview:self.bottomScrollView];
        
        self.navHeaderView.tableViews = [NSMutableArray arrayWithArray:self.tableViews];
        self.headerView = self.tableHeaderView;
        
        [self.view addSubview:self.headerView];
        [self.view addSubview:self.segmentScrollView];
        [self.view addSubview:self.navHeaderView];
        self.bottomScrollView.contentOffset = CGPointMake(DZSUIScreen_width, 0);

        //self.headerView.backgroundColor = [UIColor orangeColor];
        //self.segmentScrollView.backgroundColor = [UIColor greenColor];
        //self.navHeaderView.backgroundColor = [UIColor blueColor];
        
    }
    return self;
}

#pragma mark - 加载数据
- (void)requestData {
    _currentUser = [BBSUIContext shareInstance].currentUser;
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    
    // 仅刷新当前界面
//    BBSUICollectionViewController *vc = (BBSUICollectionViewController *)self.controlleres[_previousIndex];
//    [vc.collectionView refreshData];
    
    // 全部刷新
    [self.controlleres enumerateObjectsUsingBlock:^(BBSUICollectionViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.collectionView refreshData];
    }];
    
    
    __weak typeof (self) weakSelf = self;
    [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
        
        if (!error) {
            _currentUser.favorites  = user.favorites;
            _currentUser.followers  = user.followers;
            _currentUser.threads    = user.threads;
            _currentUser.firends    = user.firends;
            _currentUser.notices    = user.notices;
            
            // 设置消息红点
            if ([_currentUser.notices integerValue])
            {
                self.redView.hidden = NO;
            }
            else
            {
                self.redView.hidden = YES;
            }
            
            [BBSUIContext shareInstance].currentUser = _currentUser;
            
            [_tableHeaderView setHeaderWithUser:_currentUser];
            
            [weakSelf setSegmentButton];
            
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
    
    self.bottomScrollView.contentOffset = CGPointMake(DZSUIScreen_width *_previousIndex, 0);
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView !=self.bottomScrollView) {
        return ;
    }
    
    int index =  scrollView.contentOffset.x/scrollView.frame.size.width;
    
    UIButton *currentButton = self.titleButtons[index];
    //     for (UIButton *button in self.titleButtons) {
    //         button.selected = NO;
    //     }
    _previousButton.selected = NO;
    currentButton.selected = YES;
    _previousButton = currentButton;
    
    
//    NSLog(@"lastOffsetY = %f",self.lastTableViewOffsetY);
    
    self.currentTableView  = self.tableViews[index];
    for (UITableView *tableView in self.tableViews) {
        
        if ( self.lastTableViewOffsetY>=0 &&  self.lastTableViewOffsetY <= HeaderHeight - 63) {
            
            tableView.contentOffset = CGPointMake(0,  self.lastTableViewOffsetY);
            
        }else if(  self.lastTableViewOffsetY < 0){
            
            tableView.contentOffset = CGPointMake(0, 0);
            
        }else if ( self.lastTableViewOffsetY > HeaderHeight - 63){
            
            tableView.contentOffset = CGPointMake(0, HeaderHeight - 63);
        }
        
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        if (index != 0) {
            UIButton *preButton = self.titleButtons[index - 1];
            
            float offsetX = CGRectGetMinX(preButton.frame)-PADDING*2;
            
            [self.segmentScrollView scrollRectToVisible:CGRectMake(offsetX, 0, self.segmentScrollView.frame.size.width, self.segmentScrollView.frame.size.height) animated:YES];
        }
        
        self.currentSelectedItemView.frame = CGRectMake(CGRectGetMinX(currentButton.frame) + currentButton.frame.size.width/2 - 18, self.segmentScrollView.frame.size.height-1, 40, 1);
        
    }];
    
    
}


#pragma  mark - 选项卡点击事件

-(void)changeSelectedItem:(UIButton *)currentButton{
    _previousButton.selected = NO;
    currentButton.selected = YES;
    _previousButton = currentButton;
    
//    [self _setController];
    
    NSInteger index = [self.titleButtons indexOfObject:currentButton];
    _previousIndex = index;
    
    self.currentTableView  = self.tableViews[index];
    for (UITableView *tableView in self.tableViews) {
        
        if ( self.lastTableViewOffsetY>=0 &&  self.lastTableViewOffsetY <= HeaderHeight - 63) {
            
            tableView.contentOffset = CGPointMake(0,  0);
//            tableView.contentOffset = CGPointMake(0,  self.lastTableViewOffsetY);
            
        }else if(self.lastTableViewOffsetY < 0){
            
            tableView.contentOffset = CGPointMake(0, 0);
            
        }else if ( self.lastTableViewOffsetY > HeaderHeight - 63){
            
            tableView.contentOffset = CGPointMake(0, 0);
//            tableView.contentOffset = CGPointMake(0,  HeaderHeight - 63);
        }
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (index != 0) {
            
            UIButton *preButton = self.titleButtons[index - 1];
            
            float offsetX = CGRectGetMinX(preButton.frame)-PADDING*2;
            
            [self.segmentScrollView scrollRectToVisible:CGRectMake(offsetX, 0, self.segmentScrollView.frame.size.width, self.segmentScrollView.frame.size.height) animated:YES];
            
        }
        self.bottomScrollView.contentOffset = CGPointMake(DZSUIScreen_width *index, 0);
        
        self.currentSelectedItemView.frame = CGRectMake(CGRectGetMinX(currentButton.frame) + currentButton.frame.size.width/2 - 18, self.segmentScrollView.frame.size.height-1, 40, 1);
    }];
    
    [self.tableViews enumerateObjectsUsingBlock:^(UITableView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"fffffffff %zu",obj.mj_footer.state);
    }];
}


#pragma -mark Lazy Load
//TODO: 加载所有的tableview
- (UIScrollView *)bottomScrollView {
    
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height)];
        _bottomScrollView.delegate = self;
        _bottomScrollView.pagingEnabled = YES;
        
        for (int index = 0; index < CATEGORY.count; index ++)
        {
            BBSUICollectionViewController *collectionVC = [[BBSUICollectionViewController alloc] init];
            
            // cell删除操作
            __weak typeof (self) weakSelf = self;
            collectionVC.deleteCellBlock = ^(){
                [weakSelf _deleteCellAction];
            };
            
            
            if (index == 0)
            {
                collectionVC.collectionViewType = CollectionViewTypeThreadFavorites;
            }
            else if (index == 1)
            {
                collectionVC.collectionViewType = CollectionViewTypeThreadList;
            }
            else
            {
                collectionVC.collectionViewType = CollectionViewTypeHistory;
            }
            
            collectionVC.view.frame = CGRectMake(DZSUIScreen_width *index, 0, DZSUIScreen_width, DZSUIScreen_height);
            
            [self.bottomScrollView addSubview:collectionVC.view];
            [self.controlleres addObject:collectionVC];
            [self.tableViews addObject:collectionVC.collectionView.collectionTableView];
            
            [collectionVC.collectionView.collectionTableView addObserverForKeyPath:NSStringFromSelector(@selector(contentOffset)) block:^(__weak id obj, id oldValue, id newValue) {
                //
                UITableView *tableView = (UITableView *)obj;
                
                
                if (!(self.currentTableView == tableView)) {
                    return;
                }
                
                
                CGFloat tableViewoffsetY = tableView.contentOffset.y;
                
//                                NSLog(@"tableViewoffsetY = %f",tableViewoffsetY);
                
                self.lastTableViewOffsetY = tableViewoffsetY;
                
                if ( tableViewoffsetY>=0 && tableViewoffsetY <= HeaderHeight - 63) {
                    
                    self.segmentScrollView.frame = CGRectMake(0, HeaderHeight-tableViewoffsetY, DZSUIScreen_width, 45);
                    self.headerView.frame = CGRectMake(0, 0-tableViewoffsetY, DZSUIScreen_width, HeaderHeight);
                    
                }else if( tableViewoffsetY < 0){
                    
                    self.segmentScrollView.frame = CGRectMake(0, HeaderHeight-tableViewoffsetY, DZSUIScreen_width, 45);
                    self.headerView.frame = CGRectMake(0, -tableViewoffsetY, DZSUIScreen_width, HeaderHeight);
                    
                }else if (tableViewoffsetY > HeaderHeight - 63){
                    
                    self.segmentScrollView.frame = CGRectMake(0, 64, DZSUIScreen_width, 45);
                    self.headerView.frame = CGRectMake(0, -(HeaderHeight - 63), DZSUIScreen_width, HeaderHeight);
                }
                
            }];
        }
        
        // 首个展示页
        self.currentTableView = self.tableViews[1];
        self.bottomScrollView.contentSize = CGSizeMake(DZSUIScreen_width, 0);
        
        
    }
    return _bottomScrollView;
}

- (BBSUIUserOtherInfoTableHeaderView *)tableHeaderView{
    if (_tableHeaderView == nil) {
        
        CGFloat height = 360;
        _tableHeaderView = [[BBSUIUserOtherInfoTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height) :UserTypeMe];
        
        [_tableHeaderView setHeaderWithUser:_currentUser];
    }
    return _tableHeaderView;
}

- (UIScrollView *)segmentScrollView {
    
    if (!_segmentScrollView) {
        
        _segmentScrollView =  [[UIScrollView alloc]initWithFrame:CGRectMake(0, HeaderHeight, DZSUIScreen_width, 45)];
        
        _segmentScrollView.showsHorizontalScrollIndicator = NO;
        _segmentScrollView.showsVerticalScrollIndicator = NO;
        _segmentScrollView.backgroundColor = [UIColor whiteColor];
        NSInteger btnoffset = 0;
        
        NSArray *arrayImageNames = @[@"/User/Collect@2x.png",
                                     @"/User/Thread@2x.png",
                                     @"/User/History@2x.png"];
        NSArray *arraySelectImageNames = @[@"/User/Collect_select@2x.png",
                                           @"/User/Thread_select@2x.png",
                                           @"/User/History_select@2x.png"];
        
        for (int i = 0; i<CATEGORY.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [btn setTitle:CATEGORY[i] forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btn setTitleColor:DZSUIColorFromHex(0x2A2B30) forState:UIControlStateSelected];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [btn setImage:[UIImage BBSImageNamed:arrayImageNames[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage BBSImageNamed:arraySelectImageNames[i]] forState:UIControlStateSelected];
            
            
            btn.titleLabel.font = [UIFont systemFontOfSize:FONTMIN];

            CGFloat btnW = DZSUIScreen_width / 3;
            
            float originX =  btnW * i;
            
            btn.frame = CGRectMake(originX, 2, btnW, 41);
            btnoffset = CGRectGetMaxX(btn.frame);
            
            
            btn.titleLabel.textAlignment = NSTextAlignmentLeft;
            [btn addTarget:self action:@selector(changeSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
            [_segmentScrollView addSubview:btn];
            
            [self.titleButtons addObject:btn];
            
            
            [_segmentScrollView addSubview:self.currentSelectedItemView];
            //contentSize 等于按钮长度叠加
            //默认选中第二个按钮
            if (i == 1) {
                
                btn.selected = YES;
                _previousButton = btn;
                
                self.currentSelectedItemView.frame = CGRectMake(CGRectGetMinX(btn.frame) + btn.frame.size.width/2 - 18, self.segmentScrollView.frame.size.height-1, 40, 1);
            }
        }
        
        [self setSegmentButton];
        
        _segmentScrollView.contentSize = CGSizeMake(DZSUIScreen_width, 25);
    }
    
    return _segmentScrollView;
}

- (void)setSegmentButton
{
    NSString *favorites = [NSString stringWithFormat:@"收藏 %@",_currentUser.favorites];
    NSString *threads = [NSString stringWithFormat:@"帖子 %@",_currentUser.threads];
    NSString *histories = [NSString stringWithFormat:@"历史 %lu",(long)[[BBSUICoreDataManage shareManager] historyCount]];
    
    NSArray *buttonCount = @[favorites, threads, histories];
    
    for (int i = 0; i < self.titleButtons.count; i ++)
    {
        UIButton *button = self.titleButtons[i];
        
        [button setAttributedTitle:[self stringWithString:buttonCount[i] defaultColor:[UIColor darkGrayColor] countColor:DZSUIColorFromHex(0xACADB8)] forState:UIControlStateNormal];
        
        [button setAttributedTitle:[self stringWithString:buttonCount[i] defaultColor:DZSUIColorFromHex(0x2A2B30) countColor:DZSUIColorFromHex(0xACADB8)] forState:UIControlStateSelected];
    }

}

- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str
{
    //    创建一个label
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    //    label 的文字
    label.text = str;
    //    label 的行数
    label.numberOfLines = 0;
    //    label的字体大小
    label.font = [UIFont systemFontOfSize:fontSize];
    //    让label通过文字设置size
    [label sizeToFit];
    //    获取label 的size
    CGSize size = label.frame.size;
    //    返回出去
    return size;
    
}

- (UIView *)currentSelectedItemView {
    if (!_currentSelectedItemView) {
        _currentSelectedItemView = [[UIView alloc] init];
        _currentSelectedItemView.backgroundColor = DZSUIColorFromHex(0xFFC700);
    }
    return _currentSelectedItemView;
}


//- (SDCycleScrollView *)cycleScrollView {
//
//    if (!_cycleScrollView) {
//
//        NSMutableArray *imageMutableArray = [NSMutableArray array];
//        for (int i = 1; i<9; i++) {
//            NSString *imageName = [NSString stringWithFormat:@"cycle_%02d.jpg",i];
//            [imageMutableArray addObject:imageName];
//        }
//
//        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, DZSUIScreen_width, HeaderHeight) imageNamesGroup:imageMutableArray];
//
//
//    }
//    return _cycleScrollView;
//}

- (BBSUINavHeaderView *)navHeaderView {
    
    if (!_navHeaderView) {
        
        _navHeaderView = [[BBSUINavHeaderView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 64)];
        _navHeaderView.backgroundColor = [UIColor clearColor];
        _navHeaderView.title = _currentUser.userName;
        
        
        UIButton *setting = [UIButton new];
        [setting setImage:[UIImage BBSImageNamed:@"/User/Setting@2x.png"] forState:UIControlStateNormal];
        [setting addTarget:self action:@selector(_settingAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *notification = [UIButton new];
        [notification setImage:[UIImage BBSImageNamed:@"/User/information3@2x.png"] forState:UIControlStateNormal];
        [notification addTarget:self action:@selector(_notificationAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.redView = [[UIView alloc] initWithFrame:CGRectMake(20, 5, 7, 7)];
        self.redView.backgroundColor = [UIColor redColor];
        self.redView.layer.cornerRadius = 3.5;
        self.redView.clipsToBounds = YES;
        
        [notification addSubview:self.redView];
        
        if ([_currentUser.notices integerValue])
        {
            self.redView.hidden = NO;
        }
        else
        {
            self.redView.hidden = YES;
        }

        _navHeaderView.rightButotnArray = @[setting, notification];
    }
    return _navHeaderView;
}

- (NSMutableAttributedString *)stringWithString:(NSString *)string defaultColor:(UIColor *)defaultColor countColor:(UIColor *)countColor
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:defaultColor,NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, 2)];
    [attr addAttributes:@{NSForegroundColorAttributeName:countColor,NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange(2, string.length - 2)];
    
    return attr;
}

#pragma mark - Action

- (void)_settingAction
{
    BBSUISettingViewController *vc = [[BBSUISettingViewController alloc] init];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)_notificationAction
{
    BBSUIInformationViewController *vc = [[BBSUIInformationViewController alloc] init];
    [[MOBFViewController currentViewController].navigationController pushViewController:vc animated:YES];
}

- (void)_deleteCellAction
{
    NSInteger index = [self.tableViews indexOfObject:self.currentTableView];
    if (index == 0)
    {
        _currentUser.favorites = [NSNumber numberWithInt:_currentUser.favorites.intValue - 1];
        [BBSUIContext shareInstance].currentUser = _currentUser;
        [self setSegmentButton];
    }
    if (index == 1)
    {
        _currentUser.threads = [NSNumber numberWithInt:_currentUser.threads.intValue - 1];
        [BBSUIContext shareInstance].currentUser = _currentUser;
        [self setSegmentButton];
    }
}

@end
