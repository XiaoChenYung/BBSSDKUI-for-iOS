//
//  BBSUICollectionView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICollectionView.h"
//#import "BBSUICollectionTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import "MJRefresh.h"
#import "BBSUIContext.h"
#import "BBSUIThreadDetailViewController.h"
#import "UIView+BBSUITipView.h"
#import "BBSUILBSShowLocationViewController.h"
#import "BBSUIThreadSummaryCell.h"
#define BBSUIPageSize       20
#import "UITableView+FDTemplateLayoutCell.h"

@interface BBSUICollectionView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *marrData;

@property (nonatomic, assign) BBSUICollectionViewType type;

@property (nonatomic, copy) NSString *token;

/**
 正在进行删除操作
 */
@property (nonatomic, assign) BOOL isDeleting;

@end

static NSString *cellIdentifier = @"CollectionCell";

@implementation BBSUICollectionView

- (instancetype)init:(BBSUICollectionViewType)type{
    if (self = [super init]) {
        [self data:type];
        [self configureUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(BBSUICollectionViewType)type{
    if (self = [super initWithFrame:frame]) {
        [self data:type];
        [self configureUI];
    }
    
    return self;
}

- (void)data:(BBSUICollectionViewType)type{
    _type = type;
    _currentUser = [BBSUIContext shareInstance].currentUser;
    _currentIndex = 1;
}

- (void)configureUI
{
    self.collectionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.collectionTableView registerClass:[BBSUIThreadSummaryCell class] forCellReuseIdentifier:cellIdentifier];
    [self addSubview:self.collectionTableView];
    
    [self.collectionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.collectionTableView.contentInset = UIEdgeInsetsMake(0, 0, [[UIDevice currentDevice] inner_isIphoneXOrLater] ? 34 : 0, 0);
    self.collectionTableView.dataSource = self;
    self.collectionTableView.delegate = self;
    self.collectionTableView.backgroundColor = DZSUI_BackgroundColor;
    
    self.collectionTableView.estimatedRowHeight = 200;
    self.collectionTableView.rowHeight = UITableViewAutomaticDimension;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
    tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
    
    [self.collectionTableView setTableHeaderView:tableHeaderView];
    self.collectionTableView.tableFooterView = [UIView new];
    
    if (_type != CollectionViewTypeThreadFavorites) // 收藏存在取消收藏事件，故收藏拉取数据放在viewWillAppear中
//        [self requestData];
        [self login];
}
//Cookie
- (void)login {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] valueForKey:@"Cookie"];
    if (user) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs-qf.cloutropy.com/appapi/login.php"]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [[NSString stringWithFormat:@"username=%@&password=%@", [user valueForKey:@"bbs_username"], [user valueForKey:@"bbs_password"]] dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *serializationError = nil;
                    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
                    NSLog(@"%@", responseObject);
                    self.token = [[responseObject valueForKey:@"data"] valueForKey:@"token"];
                    __weak typeof (self) weakSelf = self;
                    self.collectionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                        weakSelf.currentIndex = 1;
                        [weakSelf requestData];
                    }];
                    self.collectionTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                        weakSelf.currentIndex ++;
                        [weakSelf requestData];
                    }];
                    [self requestData];
                });
            } else {
                NSLog(@"错误:%@", error);
                BBSUIAlert(@"获取我的帖子失败");
            }
        }];
        [task resume];
    }
}

- (void)refreshData
{
    self.currentIndex = 1;
    [self requestData];
}

- (void)requestData
{
    __weak typeof (self) weakSelf = self;
    if (_type == CollectionViewTypeThreadList) {
        NSCharacterSet *encode_set = [NSCharacterSet characterSetWithCharactersInString:@"#%<>[\\]^`{|}\"]+"].invertedSet;
        NSLog(@"token: %@",self.token);
        NSString *oriURL = [NSString stringWithFormat:@"http://bbs-qf.cloutropy.com/appapi/index.php?mod=space_thread&token=%@&page=%zu&pagesize=%d", self.token, self.currentIndex, BBSUIPageSize];
        NSLog(@"oriURL: %@",oriURL);
        NSString *urlString_encode = [oriURL stringByAddingPercentEncodingWithAllowedCharacters: encode_set];
        NSURL *url = [NSURL URLWithString:urlString_encode];
        NSLog(@"url: %@", url);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"GET";
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *serializationError = nil;
                    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
                    NSLog(@"%@", responseObject);
                    NSArray *resData = [responseObject valueForKey:@"data"];
                    NSMutableArray *modelArray = [NSMutableArray array];
                    for (NSDictionary *modelDict in resData) {
                        BBSThread *thread = [[BBSThread alloc] init];
                        thread.tid = [[modelDict valueForKey:@"tid"] integerValue];
                        thread.subject = [modelDict valueForKey:@"subject"];
                        thread.content = [modelDict valueForKey:@"dateline"];
                        thread.displayOrder = [[modelDict valueForKey:@"displayorder"] integerValue];
                        thread.authorId = [[modelDict valueForKey:@"authorid"] integerValue];
                        [modelArray addObject:thread];
                    }
                    if (weakSelf.currentIndex == 1) {
                        [weakSelf.collectionTableView.mj_header endRefreshing];
                        weakSelf.marrData = [NSMutableArray arrayWithArray:modelArray];
                        [weakSelf.collectionTableView reloadData];
                    }else{
                        if (modelArray.count > 0) {
                            NSMutableArray *indexPaths = [NSMutableArray array];
                            for (NSInteger i = 0; i < modelArray.count; i++) {
                                NSIndexPath *path = [NSIndexPath indexPathForRow:weakSelf.marrData.count + i inSection:0];
                                [indexPaths addObject:path];
                            }
                            [weakSelf.marrData addObjectsFromArray:modelArray];
                            [weakSelf.collectionTableView reloadData];
                        }
                    }
                    if (modelArray.count < BBSUIPageSize) {
                        NSLog(@"显示没有更多数据");
                        [weakSelf.collectionTableView.mj_footer endRefreshingWithNoMoreData];
                    } else {
                        [weakSelf.collectionTableView.mj_footer endRefreshing];
                    }
        
//                    if (weakSelf.currentIndex == 1) {
//                        [self bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
//                            [weakSelf.collectionTableView.mj_header beginRefreshing];
//                            [weakSelf requestData];
//                        }];
//                    }
                });
            } else {
                NSLog(@"错误:%@", error);
                BBSUIAlert(@"获取我的帖子失败");
            }
        }];
        //    [SwiftTransferTool beginVisitingNetwork];
        
        [task resume];
        
//        [BBSSDK getUserThreadListWithAuthorid:nil pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
//
//            if (error) {
//                return ;
//            }
//
//            if (weakSelf.currentIndex == 1) {
//                [weakSelf.collectionTableView.mj_header endRefreshing];
//                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
//                [weakSelf.collectionTableView reloadData];
//            }else{
//                if (array.count > 0) {
//                    NSMutableArray *indexPaths = [NSMutableArray array];
//                    for (NSInteger i = 0; i < array.count; i++) {
//                        NSIndexPath *path = [NSIndexPath indexPathForRow:weakSelf.marrData.count + i inSection:0];
//                        [indexPaths addObject:path];
//                    }
//                    [weakSelf.marrData addObjectsFromArray:array];
//                    [weakSelf.collectionTableView insertRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationAutomatic];
//                }
//            }
//            if (array.count < BBSUIPageSize) {
//                NSLog(@"显示没有更多数据");
//                [weakSelf.collectionTableView.mj_footer endRefreshingWithNoMoreData];
//            } else {
//                [weakSelf.collectionTableView.mj_footer endRefreshing];
//            }
//
//            if (weakSelf.currentIndex == 1) {
//                [self bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
//                    [weakSelf.collectionTableView.mj_header beginRefreshing];
//                    [weakSelf requestData];
//                }];
//            }
//        }];
    }
    
//    if (_type == CollectionViewTypeThreadFavorites) {
//        [BBSSDK getUserThreadFavoritesWithPageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
//            if (error) {
//                return ;
//            }
//
//            if (weakSelf.currentIndex == 1) {
//                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
//            }else{
//                [weakSelf.marrData addObjectsFromArray:array];
//            }
//            [weakSelf.collectionTableView reloadData];
//            [weakSelf.collectionTableView.mj_header endRefreshing];
//            [weakSelf.collectionTableView.mj_footer endRefreshing];
//
//            if (weakSelf.currentIndex == 1) {
//                [self bbs_configureTipViewWithTipMessage:@"暂无内容" hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
//                    [weakSelf.collectionTableView.mj_header beginRefreshing];
//                    [weakSelf requestData];
//                }];
//            }
//        }];
//    }
    
//    if (_type == CollectionViewTypeOtherUserThreadList && self.authorid) { // 查看他人帖子列表
//        [BBSSDK getUserThreadListWithAuthorid:self.authorid pageIndex:self.currentIndex pageSize:BBSUIPageSize result:^(NSArray<BBSThread *> *array, NSError *error) {
//            if (error) {
//                return ;
//            }
//
//            if (weakSelf.currentIndex == 1) {
//                weakSelf.marrData = [NSMutableArray arrayWithArray:array];
//            }else{
//                [weakSelf.marrData addObjectsFromArray:array];
//            }
//            [weakSelf.collectionTableView reloadData];
//            [weakSelf.collectionTableView.mj_header endRefreshing];
//            [weakSelf.collectionTableView.mj_footer endRefreshing];
//
//            if (weakSelf.currentIndex == 1) {
//                [self bbs_configureTipViewWithFrame:CGRectMake(0, 339, DZSUIScreen_width, 339) tipMessage:@"暂无内容" noDataImage:nil hasData:weakSelf.marrData.count != 0 hasError:YES reloadButtonBlock:^(id sender) {
//                    [weakSelf.collectionTableView.mj_header beginRefreshing];
//                    [weakSelf requestData];
//                }];
//            }
//        }];
//
//    }
}

- (void)setAuthorid:(NSNumber *)authorid {
    _authorid = authorid;
//    _currentIndex = 1;
//    [self requestData];
}

#pragma mark UITbleview  delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _marrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBSUIThreadSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.deleteOnClickBlock = ^(BBSThread *threadModel) {
        [self deleteThreadWithID:threadModel.tid];
    };
    cell.isMyPosts = true;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.collectionViewType = _type;
    cell.threadModel = _marrData[indexPath.row];
    cell.cellType = BBSUIThreadSummaryCellTypeForums;
//    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
//    __weak typeof(self)weakSelf = self;
//    cell.addressOnClickBlock = ^(BBSThread *threadModel) {
//        CLLocationCoordinate2D coordinate = {threadModel.latitude,threadModel.longitude};
//        BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:threadModel.poiTitle];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
//        [[MOBFViewController currentViewController].navigationController presentViewController:nav animated:YES completion:nil];
//    };
    
    return cell;
}

- (void)deleteThreadWithID:(NSInteger)threadID {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"确定删除该帖子吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        NSURL *url = [NSURL URLWithString;
        NSCharacterSet *encode_set = [NSCharacterSet characterSetWithCharactersInString:@"#%<>[\\]^`{|}\"]+"].invertedSet;
        NSString *oriURL = [NSString stringWithFormat:@"http://bbs-qf.cloutropy.com/appapi/index.php?mod=delete_forum&tid=%zu&token=%@", threadID, self.token];
          NSLog(@"oriURL: %@",oriURL);
          NSString *urlString_encode = [oriURL stringByAddingPercentEncodingWithAllowedCharacters: encode_set];
          NSURL *url = [NSURL URLWithString:urlString_encode];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"GET";
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteCellWithID:threadID];
                });
            } else {
                NSLog(@"错误:%@", error);
                BBSUIAlert(@"删除失败，请稍后再试");
            }
        }];
        //    [SwiftTransferTool beginVisitingNetwork];
        
        [task resume];
    }];
    [vc addAction:cancel];
    [vc addAction:confirm];
    [[MOBFViewController currentViewController] presentViewController:vc animated:true completion:nil];
}

- (void)deleteCellWithID:(NSInteger)threadID {
    NSInteger index = 0;
    for (BBSThread *model in self.marrData) {
        if (model.tid == threadID) {
            break;
        }
        index ++;
    }
    NSLog(@"索引: %zu %zu threadID %zu", index, self.marrData.count, threadID);
    if (index < self.marrData.count) {
        [self.marrData removeObjectAtIndex:index];
        [self.collectionTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        BBSUIAlert(@"删除成功");
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BBSThread *thread = self.marrData[indexPath.row];
    if (thread.displayOrder == -2) {
        BBSUIAlert(@"审核中的帖子不支持查看");
        return;
    }
    BBSUIThreadDetailViewController *detailVC = [[BBSUIThreadDetailViewController alloc] initWithThreadModel:thread];
    
    if ([MOBFViewController currentViewController].navigationController)
    {
        [[MOBFViewController currentViewController].navigationController pushViewController:detailVC animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 收藏列表可做删除操作，帖子列表不删除
    
    if (_type == CollectionViewTypeThreadFavorites) {
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isDeleting) {
        return;
    }
    _isDeleting = YES;
    
    // 删除模型
    BBSThread *thread = self.marrData[indexPath.row];
    
    __weak typeof (self) weakSelf = self;
    [BBSSDK unFavoriteThreadWithFavid:[NSString stringWithFormat:@"%zd", thread.favid] result:^(NSError *error) {
        if (! error) {
            [weakSelf.marrData removeObjectAtIndex:indexPath.row];

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            _isDeleting = NO;
        }else{
            _isDeleting = NO;
        }
    }];
}

/**
 *  修改Delete按钮文字为“删除”
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}



@end
