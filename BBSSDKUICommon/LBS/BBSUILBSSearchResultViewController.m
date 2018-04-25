//
//  BBSUILBSSearchResultViewController.m
//  BBSLBSPro
//
//  Created by wukx on 2018/4/3.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUILBSSearchResultViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MJRefresh.h"
#import "BBSUILBSLocationCell.h"

@interface BBSUILBSSearchResultViewController ()<AMapSearchDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSMutableArray<AMapPOI *> *searchResultArray;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation BBSUILBSSearchResultViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setSeparatorColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1]];
    [self.tableView registerClass:[BBSUILBSLocationCell class] forCellReuseIdentifier:[BBSUILBSLocationCell getID]];
    self.page = 1;
    self.search = [[AMapSearchAPI alloc] init];
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadPastData)];
    self.tableView.mj_footer = footer;
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStatePulling];
    [footer setTitle:@"正在搜索数据" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"附近没有更多匹配数据" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    footer.stateLabel.textColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.search.delegate = self;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.search.delegate = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPastData{
    [self _searchlocation];
}

#pragma mark - Getter

- (NSMutableArray *)searchResultArray{
    if (!_searchResultArray) {
        _searchResultArray = @[].mutableCopy;
    }
    return _searchResultArray;
}

#pragma mark - Setter

- (void)setKeyword:(NSString *)keyword{
    _keyword = keyword;
    self.page = 1;
    [self _searchlocation];
}

#pragma mark - Private
- (void)_searchlocation{
    if (_search == nil) {
        return;
    }
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    // types 属性表示限定搜索 POI 的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为:
    // 汽车服务|汽车销售|汽车维修|摩托服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    request.keywords = self.keyword;
    request.types = @"风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息";//@"汽车服务|汽车销售|汽车维修|摩托服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    request.sortrule = 0;
    request.requireExtension = YES;
    request.offset = 20;
    request.page = self.page;
    
    [_search AMapPOIKeywordsSearch:request];
}

#pragma mark - AMapSearchDelegate
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.count == 0) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    if (self.page == 1) {
        [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
        [self.searchResultArray removeAllObjects];
    }
    self.page += 1;
    [self.searchResultArray addObjectsFromArray:response.pois];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource、UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    height = [BBSUILBSLocationCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BBSUILBSLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:[BBSUILBSLocationCell getID] forIndexPath:indexPath];
    AMapPOI *poi = (AMapPOI *)self.searchResultArray[indexPath.row];
    [cell configureForData:poi keyword:self.keyword];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poiInfo = (AMapPOI *)self.searchResultArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(BBSUILBSSearchResultViewController:didSelectPoiWithPoiInfo:keyword:)]) {
        [self.delegate BBSUILBSSearchResultViewController:self didSelectPoiWithPoiInfo:poiInfo keyword:self.keyword];
    }
}

@end
