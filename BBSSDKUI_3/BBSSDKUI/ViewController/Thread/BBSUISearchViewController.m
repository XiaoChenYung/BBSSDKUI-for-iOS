//
//  BBSUISearchViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUISearchViewController.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIThreadListTableViewController.h"
#import "BBSUICacheManager.h"
#import "BBSUIContext.h"
#import <BBSSDK/BBSUser.h>

#define BBSUIPageSize 10

@interface BBSUISearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BBSUIThreadListTableViewController *threadVC;

@property (nonatomic, strong) NSArray *searchHistory;

@property (nonatomic, strong) UIView *darkView;

@property (nonatomic, strong) BBSUser *currentUser;

@end

@implementation BBSUISearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)configUI {
    _currentUser = [BBSUIContext shareInstance].currentUser;
    _searchHistory = [[BBSUICacheManager sharedInstance] getSearchHistoriesWithUid:_currentUser.uid];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DZSUIScreen_width, 44)];
    [self.view addSubview:headerView];
    
    /**
     searchBar
     */
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.showsCancelButton = YES;
    _searchBar.placeholder = @"请输入搜索关键词";
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    [headerView addSubview:_searchBar];
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@-55);
        make.top.equalTo(@6);
        make.height.equalTo(@32);
    }];
    [_searchBar becomeFirstResponder];
    
    UIButton *cancleBtn = [[UIButton alloc] init];
    cancleBtn.backgroundColor = [UIColor clearColor];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:DZSUIColorFromHex(0xACADB8) forState:UIControlStateNormal];
    [cancleBtn setTitleColor:DZSUIColorFromHex(0xACADB8) forState:UIControlStateHighlighted];
    [headerView addSubview:cancleBtn];
    
    [cancleBtn addTarget:self action:@selector(cancleBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 20));
        make.right.equalTo(@-12);
        make.centerY.equalTo(_searchBar);
    }];
    
    
    /**
     横线
     */
    _darkView = [UIView new];
    _darkView.backgroundColor = DZSUIColorFromHex(0xEDEEF0);
    [self.view addSubview:_darkView];
    [_darkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchBar.mas_bottom).offset(5);
        make.left.right.equalTo(@0);
        make.height.equalTo(@5);
    }];
    
    
    /**
     tableView
     */
    _threadVC = [[BBSUIThreadListTableViewController alloc]initWithForum:nil selectType:BBSUIThreadSelectTypeLatest pageType:PageTypeSearch];
    _threadVC.view.frame = CGRectMake(0, 40, DZSUIScreen_width, DZSUIScreen_height - 40);
    [self.view addSubview:_threadVC.tableView];
    [self addChildViewController:_threadVC];
    
    [_threadVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_darkView.mas_bottom);
        make.left.right.bottom.equalTo(@0);
    }];
  
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_darkView.mas_bottom);
        make.left.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_darkView.mas_bottom);
        make.left.right.equalTo(@0);
        make.bottom.mas_equalTo(- height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_darkView.mas_bottom);
        make.left.right.equalTo(@0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SEARCHCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *icon = [UIImage BBSImageNamed:@"Common/SearchHistory.png"];
        CGSize imageSize = CGSizeMake(35, 35);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0);
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [icon drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage BBSImageNamed:@"Common/delete_history.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteHistory:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell);
        make.right.equalTo(cell).offset(-15);
        make.width.height.equalTo(@20);
    }];
    button.tag = indexPath.row;
    
    cell.textLabel.textColor = DZSUIColorFromHex(0xABAFBA);
    cell.textLabel.text = _searchHistory[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.searchBar.text = _searchHistory[indexPath.row];
    [self searchWithSearchValue:_searchHistory[indexPath.row]];
}

#pragma mark searchBar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchWithSearchValue:searchBar.text];
}

- (void)searchWithSearchValue:(NSString *)searchValue {
    [self.searchBar resignFirstResponder];
    if (searchValue.length == 0) return;
    
    NSLog(@"%@",searchValue);
    
    _tableView.hidden = YES;
    self.threadVC.keyword = searchValue;
    
    NSMutableArray *marr = [[BBSUICacheManager sharedInstance] getSearchHistoriesWithUid:_currentUser.uid].mutableCopy;
    if (!marr) {
        marr = [NSMutableArray new];
    }
    if ([marr containsObject:searchValue]) {
        [marr removeObject:searchValue];
    }
    [marr insertObject:searchValue atIndex:0];
    
    if (marr.count > 10) {
        [marr removeLastObject];
    }
    [[BBSUICacheManager sharedInstance] setSearchHistories:marr.copy Uid:_currentUser.uid];
    
    _searchHistory = [[BBSUICacheManager sharedInstance] getSearchHistoriesWithUid:_currentUser.uid];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.tableView.hidden = NO;
    
    return YES;
}

- (void)deleteHistory:(UIButton *)sender {
    NSMutableArray *marray = _searchHistory.mutableCopy;
    [marray removeObjectAtIndex:sender.tag];
    [[BBSUICacheManager sharedInstance] setSearchHistories:marray Uid:_currentUser.uid];
    _searchHistory = marray;
    
    [self.tableView reloadData];
    
    if (_searchHistory.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)cancleBtnTouched {
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end




