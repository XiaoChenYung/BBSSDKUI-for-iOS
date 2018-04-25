//
//  BBSUIAccusationViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/8/29.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIAccusationViewController.h"
#import "BBSUIAccusationTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSSDK.h>
#import "BBSUIContext.h"
#import "BBSUIProcessHUD.h"
#import "MBProgressHUD.h"

#define TABLE_FOOTER_HEIGHT 60

@interface BBSUIAccusationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *accusationTableView;

@property (nonatomic, strong) NSArray *accusationMessageArray;

@property (nonatomic, strong) BBSThread *currentThread;

@property (nonatomic, assign) NSInteger currentSelectIndex;

@property (nonatomic, strong) UIView *tableFooterView;

@end

@implementation BBSUIAccusationViewController

- (instancetype)initWithThread:(BBSThread *)thread
{
    self = [super init];
    if (self) {
        _currentThread = thread;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择举报理由";
    
    [self configureUI];
    
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureUI
{
    self.accusationTableView = [UITableView new];
    [self.view addSubview:self.accusationTableView];
    [self.accusationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.accusationTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.accusationTableView setDelegate:self];
    [self.accusationTableView setDataSource:self];
    
    self.tableFooterView = [[UIView alloc] init];
    [self.tableFooterView setFrame:CGRectMake(0, 0, DZSUIScreen_width, TABLE_FOOTER_HEIGHT)];
    [self.accusationTableView setTableFooterView:self.tableFooterView];
    
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tableFooterView addSubview:commitButton];
    [commitButton setFrame:CGRectMake(12, 10, DZSUIScreen_width - 2 * 12, 40)];
    [commitButton.layer setCornerRadius:2];
    [commitButton.layer setMasksToBounds:YES];
    [commitButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:170/255.0 blue:66/255.0 alpha:1/1.0]];
    [commitButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)initData
{
    self.accusationMessageArray = @[@"广告内容", @"违规内容", @"恶意灌水", @"重复发帖", @"其它"];
    self.currentSelectIndex = 0;
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accusationMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AccusationCellIdentifier = @"AccusationCellIdentifier";
    BBSUIAccusationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AccusationCellIdentifier];
    if (!cell) {
        cell = [[BBSUIAccusationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AccusationCellIdentifier];
    }
    
    [cell setAccusationMessage:self.accusationMessageArray[indexPath.row] selected:indexPath.row == self.currentSelectIndex];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentSelectIndex = indexPath.row;
    [tableView reloadData];
}

#pragma mark - 
- (void)commitButtonHandler:(UIButton *)button
{
    __weak typeof(self) theController = self;
    NSString *accusationMessage = self.accusationMessageArray[self.currentSelectIndex];
    [BBSSDK accusationWithRtype:@"thread"
                            rid:_currentThread.tid fid
                               :_currentThread.fid 
                        message:accusationMessage 
                         result:^(NSError *error) {
                             
                             if (!error) {
                                 
                                 MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                                 [self.view addSubview:HUD];
                                 HUD.label.text = @"举报成功";
                                 
                                 HUD.contentColor = [UIColor whiteColor];
                                 HUD.mode = MBProgressHUDModeText;
                                 HUD.bezelView.backgroundColor = [UIColor blackColor];
                                 [HUD showAnimated:YES];
                                 [HUD hideAnimated:YES afterDelay:2];
                                 
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                     [theController.navigationController popViewControllerAnimated:YES];
                                 });
                                 
                                 
                             }else{
                                 [BBSUIProcessHUD showFailInfo:error.description delay:2];
                             }
                         
                         }];
}

@end
