//
//  BBSUILBSShowLocationViewController.m
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUILBSShowLocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "BBSUIActionSheet.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIAlertView.h"

@interface BBSUILBSShowLocationViewController ()<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong)MAMapView *mapView;
@property (nonatomic, strong)AMapSearchAPI *search;
@property (nonatomic, strong)UIButton *locationBtn;//定位按钮
@property (nonatomic, weak)UILabel *nameLabel;
@property (nonatomic, weak)UILabel *addressLabel;
@property (nonatomic, weak)UIButton *navigatorGPSButton;
@property (nonatomic, weak)UIButton *backButton;

@property (nonatomic)CLLocationCoordinate2D targetCoordinate;
@property (nonatomic, copy)NSString *titleStr;
@property (nonatomic, strong)MAUserLocation *location;
@property (nonatomic, strong)NSArray<MAOverlay> *pathPolylines;
@property (nonatomic, assign)BOOL isShowRoute;

@property (nonatomic, assign)BOOL navbarHidden;
@end

@implementation BBSUILBSShowLocationViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        _targetCoordinate = coordinate;
        _titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configAMapKey];
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navbarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.navbarHidden animated:YES];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat locationBtnToBottom = 20;
    CGFloat locationBtnToRight = 10;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screentHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.mapView.frame   = CGRectMake(0,0, screenWidth,screentHeight-90);
    
    [self.locationBtn setFrame:CGRectMake(CGRectGetWidth(self.view.frame)-locationBtnToRight-self.locationBtn.currentImage.size.width, CGRectGetMaxY(self.mapView.frame)-locationBtnToBottom-self.locationBtn.currentImage.size.height, self.locationBtn.currentImage.size.width, self.locationBtn.currentImage.size.height)];
}

- (BOOL)hidesBottomBarWhenPushed{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupView{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.locationBtn];
    [self initOtherView];
    [self initSearch];
    [self geocodeSearch];
    [self addCurrentAnnotation];
    [self.mapView setCenterCoordinate:_targetCoordinate animated:YES];
}

- (void)initOtherView{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(15, statusHeight + 15, 30, 30)];
    [backButton setImage:[UIImage BBSImageNamed:@"/LBS/squarBackIcon@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonOnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    UIView *otherView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-90, screenWidth, 90)];
    otherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:otherView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, screenWidth-15-20-49, 25)];
    nameLabel.font = [UIFont systemFontOfSize:20];
    nameLabel.textColor = [UIColor blackColor];
    [otherView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(nameLabel.frame), screenWidth-15-20-49, 15)];
    addressLabel.font = [UIFont systemFontOfSize:12];
    addressLabel.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0];
    [otherView addSubview:addressLabel];
    self.addressLabel = addressLabel;
    
    UIButton *navigatorGPSButton = [[UIButton alloc] initWithFrame:CGRectMake(otherView.frame.size.width - 20 - 49, (otherView.frame.size.height - 49) / 2.0, 49, 49)];
    [navigatorGPSButton setImage:[UIImage BBSImageNamed:@"/LBS/navigationIcon@2x.png"] forState:UIControlStateNormal];
    [navigatorGPSButton addTarget:self action:@selector(navigatorGPSButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
    [otherView addSubview:navigatorGPSButton];
    self.navigatorGPSButton = navigatorGPSButton;
    
    
}

- (void)initSearch{
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
}

#pragma mark - Getter

- (MAMapView *)mapView{
    if (!_mapView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 90)];
        _mapView.delegate = self;
        //设置地图语言  默认是中文
        _mapView.language = MAMapLanguageZhCN;
        //地图类型  默认是2D栅格地图
        _mapView.mapType = MAMapTypeStandard;
        [_mapView setZoomEnabled:YES];
        _mapView.zoomLevel = 13.1;
        //关闭指南针显示
        _mapView.showsCompass = NO;
        //关闭比例尺显示
        _mapView.showsScale = NO;
        //显示用户位置
        _mapView.showsUserLocation = YES;
        
        //设置跟踪模式
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        //后台定位
        //_mapView.pausesLocationUpdatesAutomatically = NO;
        //iOS9以上系统必须配置
        //_mapView.allowsBackgroundLocationUpdates = YES;
    }
    return _mapView;
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

- (NSArray<MAOverlay> *)pathPolylines
{
    if (!_pathPolylines) {
        _pathPolylines = [NSArray<MAOverlay> array];
    }
    return _pathPolylines;
}

#pragma mark - selector

- (void)backButtonOnClick{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)manuallocation:(UIButton *)sender{
    [self.mapView setCenterCoordinate:self.location.coordinate animated:YES];
    if (!sender.isSelected) {
        sender.selected = YES;
    }
}

- (void)navigatorGPSButtonOnClick{
    //[self showRoute];
    NSString *routeTitle = @"";
    if (self.isShowRoute == NO) {
        routeTitle = @"显示路线";
    }else{
        routeTitle = @"不显示路线";
    }
    __weak typeof(self) weakSelf = self;
   BBSUIActionSheet *actionSheet = [BBSUIActionSheet actionSheetWithTitleArray:@[routeTitle,@"百度地图",@"高德地图",@"Apple地图"] andTitleColorArray:@[[UIColor colorWithRed:14.0/255.0 green:134.0/255.0 blue:255.0/255.0 alpha:1.0],[UIColor blackColor],[UIColor blackColor],[UIColor blackColor]] block:^(int index) {
       if (index == 0) {
           if (weakSelf.isShowRoute == NO) {
               [weakSelf showRoute];
           } else {
               weakSelf.isShowRoute = NO;
               [weakSelf.mapView removeOverlays:weakSelf.mapView.overlays];
           }
           
       }else if (index == 1) {
           [weakSelf baiduMapNavigation];
       }else if (index == 2) {
           [weakSelf amapNavigation];
       }else if (index == 3) {
           [weakSelf appleMapNaviagation];
       }
    }];
    [actionSheet showActionSheet];
}

-(void)geocodeSearch{
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:_targetCoordinate.latitude longitude:_targetCoordinate.longitude];
    [_search AMapReGoecodeSearch:request];
}

- (void)addCurrentAnnotation{
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = _targetCoordinate;
    [self.mapView addAnnotation:annotation];
}

#pragma mark - ActionSheet Method
- (void)showRoute{
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.targetCoordinate.latitude longitude:self.targetCoordinate.longitude];
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    request.origin = startPoint;
    request.destination = endPoint;
    
    [_search AMapDrivingRouteSearch:request];
}


- (void)baiduMapNavigation{
    
    NSString *urlStr = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",self.targetCoordinate.latitude, self.targetCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
//        if (@available(iOS 9, *)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要下载百度地图" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            // 弹出对话框
            [self presentViewController:alert animated:true completion:nil];
//        }else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要下载百度地图" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
//
//        }
        
    }
}

- (void)amapNavigation{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    
    NSString *urlStr = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sname=我的位置&did=BGVIS2&dlat=%lf&dlon=%lf&dname=%@&dev=0&t=0",[appInfo objectForKey:@"CFBundleDisplayName"],self.targetCoordinate.latitude, self.targetCoordinate.longitude,@"目的地"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
//        if (@available(iOS 9, *)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要下载高德地图" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            // 弹出对话框
            [self presentViewController:alert animated:true completion:nil];
//        }else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要下载高德地图" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
//
//        }
    }
    
}

- (void)appleMapNaviagation{
    
    NSString *urlStr = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=Current+Location",self.targetCoordinate.latitude, self.targetCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - MAMapViewDelegate, AMapSearchDelegate
// 实时获取用户的经纬度
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation) {
        self.location = userLocation;
        self.locationBtn.selected = YES;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MAUserLocation class]]) {
//        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
//        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationStyleReuseIndetifier];
//        }
//        //annotationView.image = [UIImage imageNamed:@"userPosition"];
//        return annotationView;
//    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *customAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];//@"customAnnotation"
        if (customAnnotationView == nil){
            customAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        customAnnotationView.animatesDrop = YES;
        customAnnotationView.annotation = annotation;
        customAnnotationView.image = [UIImage BBSImageNamed:@"/LBS/redPinIcon@2x.png"];
        return customAnnotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polyline = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        CGFloat r = 116/255.0f;
        CGFloat g = 112/255.0f;
        CGFloat b = 246/255.0f;
        polyline.fillColor = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1];
        polyline.strokeColor = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1];
        polyline.lineCap = kCGLineCapRound;
        polyline.lineWidth = 6.0;
        return polyline;
    }else if([overlay isKindOfClass:[MAPolygon class]]){
        MAPolygonRenderer * polyGon = [[MAPolygonRenderer alloc]initWithPolygon:overlay];
        polyGon.fillColor = [UIColor redColor];
        polyGon.strokeColor = [UIColor yellowColor];
        polyGon.lineWidth = 8;
        return polyGon;
    } else if([overlay isKindOfClass:[MACircle class]]){
        MACircleRenderer * circle = [[MACircleRenderer alloc]initWithCircle:overlay];
        circle.fillColor = [UIColor blueColor];
        circle.strokeColor = [UIColor yellowColor];
        circle.lineWidth = 5;
        return circle;
    }
    return nil;
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    self.nameLabel.text = _titleStr;
    self.addressLabel.text = response.regeocode.formattedAddress;
    [_mapView setCenterCoordinate:_targetCoordinate animated:YES];
}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if (response.route == nil) {
        return;
    }
    self.isShowRoute = YES;
    //绘制线路
    [self.mapView removeOverlays:self.mapView.overlays];
    
    //AMapPath *path = response.route.paths[0]; //选择一条路径
    //AMapStep *step = path.steps[0]; // 这个路径上的导航路段数组
    if (response.count > 0) {
        [_mapView removeOverlay:self.pathPolylines];
        self.pathPolylines = nil;
        
        // 只显⽰示第⼀条 规划的路径
        self.pathPolylines = (NSArray<MAOverlay> *)[self polylinesForPath:response.route.paths[0]];
        
        //添加新的遮盖，然后会触发代理方法进行绘制
        [_mapView addOverlays:self.pathPolylines];
    }
}

//改变区域后
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D centerlocation= mapView.centerCoordinate;
    MAMapPoint centerPoint = MAMapPointForCoordinate(centerlocation);
    MAMapPoint userPoint   = MAMapPointForCoordinate(self.location.coordinate);
    CLLocationDistance distance =  MAMetersBetweenMapPoints(centerPoint,userPoint);
    if (distance <=100) {
        self.locationBtn.selected = YES;
    }else{
        self.locationBtn.selected = NO;
    }
}

//路线解析
- (NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count == 0)
    {
        return nil;
    }
    NSMutableArray *polylines = [NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline coordinateCount:&count parseToken:@";"];
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
    }];
    return polylines;
}

//解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil)
    {
        return NULL;
    }
    
    if (token == nil)
    {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    
    else
    {
        str = [NSString stringWithString:string];
    }
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    
    return coordinates;
}
@end
