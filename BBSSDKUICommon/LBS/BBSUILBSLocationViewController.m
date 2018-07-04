//
//  BBSUILBSLocationViewController.m
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUILBSLocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "BBSUILBSSearchResultViewController.h"
#import "MJRefresh.h"
#import "UIImage+BBSFunction.h"
#import "BBSUILBSLocationCell.h"
#import "BBSUILBSNotLocationCell.h"
#import "BBSUIAlertView.h"

@interface BBSUILBSLocationViewController ()<MAMapViewDelegate, AMapSearchDelegate,UISearchBarDelegate,UISearchResultsUpdating, UISearchControllerDelegate,BBSUILBSSearchResultViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)MAMapView *mapView;
@property (nonatomic, strong)AMapSearchAPI *search;
//@property (nonatomic, strong)AMapPOISearchBaseRequest *request;
@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, strong)BBSUILBSSearchResultViewController *searchResultController;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) UIButton *locationBtn;//定位按钮
@property (strong, nonatomic) UIButton *redPinBtn;//中心位置大头针

@property (nonatomic, strong)MAUserLocation *location;
@property (nonatomic, strong)NSMutableArray<AMapPOI *> *nearbylocations;
@property (nonatomic, assign, getter=isGeocode) BOOL geocode;
@property (nonatomic, assign, getter=isFirstlocation) BOOL firstlocation;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, assign) NSUInteger selectRow;

@end

@implementation BBSUILBSLocationViewController


- (instancetype)init{
    self = [super init];
    if (self) {
        _statusBarStyle = UIStatusBarStyleDefault;
        _geocode = YES;
        _firstlocation = YES;
        _page = 1;
    }
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self configAMapKey];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
    self.search.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
    self.search.delegate = nil;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat mapHeight = 240;
    CGFloat locationBtnToBottom = 20;
    CGFloat locationBtnToRight = 10;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screentHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mapY = 0.0f;
    if ([[UIDevice currentDevice].systemVersion floatValue] >=11.0){
        mapY = 0.0f;
    }
    else{
        mapY = CGRectGetHeight(self.searchController.searchBar.frame);
    }
    
    self.contentView.frame = CGRectMake(0, mapY, screenWidth, mapHeight);
    self.mapView.frame   = CGRectMake(0,0, screenWidth,mapHeight);
   // [self.mapView convertCoordinate:_mapView.centerCoordinate toPointToView:self.mapView];
    
    [self.redPinBtn setFrame:CGRectMake(0, 0, self.redPinBtn.currentImage.size.width, self.redPinBtn.currentImage.size.height)];
    [self.redPinBtn setCenter:self.mapView.center];
    
    [self.locationBtn setFrame:CGRectMake(CGRectGetWidth(self.contentView.frame)-locationBtnToRight-self.locationBtn.currentImage.size.width, CGRectGetMaxY(self.mapView.frame)-locationBtnToBottom-self.locationBtn.currentImage.size.height, self.locationBtn.currentImage.size.width, self.locationBtn.currentImage.size.height)];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.contentView.frame), screenWidth, screentHeight-CGRectGetMaxY(self.contentView.frame) - 64);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 配置

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.statusBarStyle;
}

/**
 *  配置AMapKey
 */
- (void)configAMapKey{
    if ([AMapServices sharedServices].apiKey == nil || [[AMapServices sharedServices].apiKey isEqualToString:@""])
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *AMapApiKey = [infoDictionary objectForKey:@"AMapApiKey"];
        if (AMapApiKey != nil && ![AMapApiKey isEqualToString:@""]) {
            [AMapServices sharedServices].apiKey = AMapApiKey;
        }
        else
        {
            BBSUIAlertView *alertView = [[BBSUIAlertView alloc] initWithMessage:@"你还未配置高德地图Key" cancelButtonTitle:@"确定" cancelBlock:^{
            }];
            [alertView show];
        }
    }
    [AMapServices sharedServices].enableHTTPS = YES;
}

- (void)setupView
{
    self.navigationItem.title = @"我的位置";
    self.edgesForExtendedLayout = UIRectEdgeAll;
    //self.automaticallyAdjustsScrollViewInsets =NO;
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(saveLocationInfo)];
    sendItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage BBSImageNamed:@"/Common/return@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >=11.0 ){
        
        if ([self.navigationItem respondsToSelector:@selector(setSearchController:)]) {
            [self.navigationItem performSelector:@selector(setSearchController:) withObject:self.searchController];
        }
        //self.navigationItem.searchController = self.searchController;
    }
    else{
        [self.view addSubview:self.searchController.searchBar];
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 240)];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.mapView];
    [self initSearch];
    [self.contentView addSubview:self.redPinBtn];
    [self.contentView addSubview:self.locationBtn];
    [self.view addSubview:self.tableView];
}


- (void)initSearch
{
    _search = [[AMapSearchAPI alloc] init];
    //_search.delegate = self;
}

- (void)toAroundSearch:(CLLocationCoordinate2D)coordinate{
    if (_location == nil || _search == nil) {
        return;
    }
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    // types 属性表示限定搜索 POI 的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为:
    // 汽车服务|汽车销售|汽车维修|摩托服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    request.types = @"风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息";
    request.sortrule = 0;
    request.offset = 20;
    request.page = self.page;
    request.requireExtension = YES;
    NSLog(@"page:%ld",self.page);
    [_search AMapPOIAroundSearch:request];
}

- (void)setPreLocationDic:(NSDictionary *)preLocationDic
{
    _preLocationDic = preLocationDic;
    if (preLocationDic && _mapView) {//有值就显示之前的值
        CGFloat lat = 0;
        CGFloat lon = 0;
        NSArray *arr = [preLocationDic[@"location"] componentsSeparatedByString:@","];
        if ([arr count] == 2) {
            lat = [[preLocationDic[@"location"] componentsSeparatedByString:@","].firstObject floatValue];
            lon = [[preLocationDic[@"location"] componentsSeparatedByString:@","].lastObject floatValue];
        }
        
        CLLocationCoordinate2D coordinate = {lat,lon};
        self.page = 1;
        self.geocode = YES;
        _mapView.centerCoordinate = coordinate;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self toAroundSearch:coordinate];
        });
    }else if (preLocationDic == nil && _mapView){//没有值就回到原点
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self manuallocation:self.locationBtn];
        });
    }
}

#pragma mark - 懒加载 Lazy Load
- (MAMapView *)mapView{
    if (!_mapView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 240)];
        //_mapView.delegate = self;
        //设置地图语言  默认是中文
        _mapView.language = MAMapLanguageZhCN;
        //地图类型  默认是2D栅格地图
        _mapView.mapType = MAMapTypeStandard;
        [_mapView setZoomEnabled:YES];
        _mapView.zoomLevel = 15.1;
        //关闭指南针显示
        _mapView.showsCompass = NO;
        //关闭比例尺显示
        _mapView.showsScale = NO;
        //显示用户位置
        _mapView.showsUserLocation = YES;
        //设置跟踪模式
        _mapView.userTrackingMode = MAUserTrackingModeNone;
        
    }
    return _mapView;
}

- (UIButton *)redPinBtn{
    if (!_redPinBtn) {
        _redPinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *redPinImg = [UIImage BBSImageNamed:@"/LBS/redPinIcon@2x.png"];
        [_redPinBtn setImage:redPinImg forState:UIControlStateNormal];
        [_redPinBtn setImage:redPinImg forState:UIControlStateHighlighted];
        _redPinBtn.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    }
    return _redPinBtn;
}

- (UIButton *)locationBtn{
    if (!_locationBtn) {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *locationImgNor = [UIImage BBSImageNamed:@"/LBS/locationBtnIcon@2x.png"];
        UIImage *locationImgSelected = [UIImage BBSImageNamed:@"/LBS/locationBtnSelectedIcon@2x.png"];
        [_locationBtn setImage:locationImgNor forState:UIControlStateNormal];
        [_locationBtn setImage:locationImgSelected forState:UIControlStateSelected];
        [_locationBtn addTarget:self action:@selector(manuallocation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationBtn;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1]];
        [_tableView registerClass:[BBSUILBSLocationCell class] forCellReuseIdentifier:[BBSUILBSLocationCell getID]];
        [_tableView registerClass:[BBSUILBSNotLocationCell class] forCellReuseIdentifier:[BBSUILBSNotLocationCell getID]];
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadPastData)];
        _tableView.mj_footer = footer;
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"" forState:MJRefreshStatePulling];
        [footer setTitle:@"正在加载数据" forState:MJRefreshStateRefreshing];
        footer.stateLabel.font = [UIFont systemFontOfSize:14];
        footer.stateLabel.textColor = [UIColor blackColor];
    }
    return _tableView;
}

#pragma mark - -----------load data-------
- (void)loadPastData
{
    NSLog(@"loadPastData");
    if (_mapView) {
        CLLocationCoordinate2D centerlocation= self.mapView.centerCoordinate;
        self.page += 1;
        [self toAroundSearch:centerlocation];
    }
}


- (UISearchController *)searchController{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
        _searchController.searchBar.barTintColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1];
        _searchController.searchBar.placeholder = @"搜索附近位置";
        _searchController.searchBar.subviews.firstObject.subviews.firstObject.layer.borderColor = [UIColor colorWithRed:198/255.0f green:198/255.0f blue:198/255.0f alpha:1].CGColor;
        _searchController.searchBar.subviews.firstObject.subviews.firstObject.layer.borderWidth = .5;
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
    }
    return _searchController;
}

- (BBSUILBSSearchResultViewController *)searchResultController{
    if (!_searchResultController) {
        _searchResultController = [[BBSUILBSSearchResultViewController alloc] init];
        _searchResultController.delegate = self;
    }
    return _searchResultController;
}

- (NSMutableArray<AMapPOI *> *)nearbylocations{
    if (!_nearbylocations) {
        _nearbylocations = @[].mutableCopy;
    }
    return _nearbylocations;
}

#pragma mark - selector
#pragma mark --------------保存地图信息-------------
- (void)saveLocationInfo
{
    //取选中的地址
    
    NSMutableDictionary *locationDic = nil;
    if (self.selectRow == 0 || self.selectRow > self.nearbylocations.count) {
        locationDic = nil;
    }
    if (self.selectRow > 0) {
        locationDic = [NSMutableDictionary dictionary];
        AMapPOI *info = [self.nearbylocations objectAtIndex:self.selectRow-1];
        [locationDic setObject:info.name forKey:@"name"];
        if ([info.province isEqualToString:info.city]) {
            [locationDic setObject:[NSString stringWithFormat:@"%@%@%@",info.city,info.district,info.address] forKey:@"address"];
        }else{
            [locationDic setObject:[NSString stringWithFormat:@"%@%@%@%@",info.province,info.city,info.district,info.address] forKey:@"address"];
        }
        [locationDic setObject:[NSString stringWithFormat:@"%f,%f",info.location.latitude,info.location.longitude] forKey:@"location"];
    }
    if (self.locationSelectBlock) {
        self.locationSelectBlock(locationDic);
    }
    [self backButtonHandler];
}

- (void)backButtonHandler
{
    if (_isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//MARK:==回到当前位置
- (void)manuallocation:(UIButton *)sender{
    [self.mapView setCenterCoordinate:self.location.coordinate animated:YES];
    if (!sender.isSelected) {
        sender.selected = YES;
    }
}

#pragma mark - MAMapViewDelegate, AMapSearchDelegate

-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (self.firstlocation) {
        self.firstlocation = NO;
    }
    NSLog(@"onPOISearchDone count:%ld",response.count);
    NSLog(@"onPOISearchDone page:%ld",self.page);
    if (response.count == 0) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    //MARK:-----添加地址数据---------
    if (self.page == 1) {
        [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
        [self.nearbylocations removeAllObjects];
        [self.nearbylocations addObjectsFromArray:response.pois];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        self.selectRow = 1;
        return;
    }
    [self.nearbylocations addObjectsFromArray:response.pois];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}

//改变区域后
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChangeAnimated");
    CLLocationCoordinate2D centerlocation= mapView.centerCoordinate;//[mapView convertPoint:mapView.center toCoordinateFromView:mapView];
    
    MAMapPoint centerPoint = MAMapPointForCoordinate(centerlocation);
    MAMapPoint userPoint   = MAMapPointForCoordinate(self.location.coordinate);
    CLLocationDistance distance =  MAMetersBetweenMapPoints(centerPoint,userPoint);
    
    MACoordinateRegion region;
    region.center = centerlocation;
    
    if (distance <=300) {
        self.locationBtn.selected = YES;
    }else{
        self.locationBtn.selected = NO;
    }
    if (self.isGeocode) {
        self.page = 1;
        [self toAroundSearch:centerlocation];
    }

    self.geocode = YES;
}

// 实时获取用户的经纬度
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation) {
        if (self.isFirstlocation) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
            //self.mapView.centerCoordinate = coordinate;
            [self.mapView setCenterCoordinate:coordinate animated:YES];
            self.location = userLocation;
            //[self toAroundSearch:coordinate];
            self.locationBtn.selected = YES;
        }
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self initAction];
    }
}

- (void)initAction{
    if (_location) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:_location.coordinate.latitude longitude:_location.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
    }
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSString *str1 = response.regeocode.addressComponent.city;
    if (str1.length == 0) {
        str1 = response.regeocode.addressComponent.province;
    }
    _mapView.userLocation.title = str1;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
}


#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    if (_mapView) {
        self.searchResultController.coordinate = _mapView.centerCoordinate;
    }
    self.searchResultController.keyword = searchString;
    
}
#pragma mark - UISearchControllerDelegate

//切换状态栏颜色
- (void)willPresentSearchController:(UISearchController *)searchController{
    self.statusBarStyle = UIStatusBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
    self.redPinBtn.hidden = YES;

}

- (void)willDismissSearchController:(UISearchController *)searchController{
    if ([[UIDevice currentDevice].systemVersion floatValue] >=11.0 ){
        self.statusBarStyle = UIStatusBarStyleDefault;
    }
    else{
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    self.redPinBtn.hidden = NO;
}

#pragma mark - BBSUILBSSearchResultViewControllerDelegate

- (void)BBSUILBSSearchResultViewController:(BBSUILBSSearchResultViewController *)searchResultController didSelectPoiWithPoiInfo:(AMapPOI *)poiInfo keyword:(NSString *)keyword{
    [self.searchController setActive:NO];
    self.keyword = keyword;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poiInfo.location.latitude, poiInfo.location.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nearbylocations.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (indexPath.row == 0) {
        height = [BBSUILBSNotLocationCell cellHeight];
    }else{
        height = [BBSUILBSLocationCell cellHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        BBSUILBSNotLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:[BBSUILBSNotLocationCell getID] forIndexPath:indexPath];
        [cell configureForTitle:@"不显示位置"];
        [cell setCheck:(self.selectRow==indexPath.row)];
        return cell;
    }else{
        BBSUILBSLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:[BBSUILBSLocationCell getID] forIndexPath:indexPath];
        AMapPOI *poi = (AMapPOI *)self.nearbylocations[indexPath.row-1];
        [cell configureForData:poi keyword:self.keyword];
        [cell setCheck:(self.selectRow==indexPath.row)];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0) {
        AMapPOI *poi = (AMapPOI *)self.nearbylocations[indexPath.row-1];
        //刷信地图位置
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    }
    self.geocode = NO;
    self.selectRow = indexPath.row;
    [self.tableView reloadData];
}

@end
