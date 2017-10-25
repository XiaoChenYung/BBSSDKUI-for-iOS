//
//  BBSUISettingViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUISettingViewController.h"
#import "BBSUIButton.h"
#import "BBSUIContext.h"
#import "BBSUICoreDataManage.h"

@interface BBSUISettingViewController ()<UITableViewDelegate,
                                         UITableViewDataSource,
                                         UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BBSUISettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, DZSUIScreen_height - 60) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width, 5}];
    tableHeaderView.backgroundColor = DZSUI_BackgroundColor;
    
    [self.tableView setTableHeaderView:tableHeaderView];
    self.tableView.tableFooterView = [UIView new];
    
    NSArray *colorArray = @[DZSUIColorFromHex(0xFF8D65), DZSUIColorFromHex(0xFFB85B)];
    BBSUIButton *button = [[BBSUIButton alloc] initWithFrame:CGRectMake(10, DZSUIScreen_height - 50, DZSUIScreen_width - 20, 40) FromColorArray:colorArray ByGradientType:leftToRight];
    [button setTitle:@"退出" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BBSSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = DZSUIColorFromHex(0x4E4F57);
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = DZSUIColorFromHex(0xACADB8);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"清理缓存";
        
        CGFloat dataSize = [[BBSUICoreDataManage shareManager] getDataSize];

        if (dataSize < 0)
        {
            dataSize = 0;
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%fM",dataSize];
        
        if (dataSize < 1)
        {
            dataSize = dataSize *1024;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fK",dataSize];
        }
        
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定清空缓存数据？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[BBSUICoreDataManage shareManager] clearCache];
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.detailTextLabel.text = @"0K";
    }
}


#pragma mark - Action
- (void)logoutAction:(id)sender
{
    [BBSUIContext shareInstance].currentUser = nil;

    [BBSSDK logout:^(NSError *error) {
        NSLog(@"error = %@", error);
    }];
    
    if ([MOBFViewController currentViewController].navigationController) {
        [[MOBFViewController currentViewController].navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
