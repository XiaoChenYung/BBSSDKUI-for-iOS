//
//  BBSUIThreadForumListSelectViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadForumListSelectViewController.h"
#import "BBSUIThreadForumListTableViewCell.h"
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSForum.h>

@interface BBSUIThreadForumListSelectViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView ;
@property (nonatomic, copy) void (^result)(BBSForum *) ;
@property (nonatomic, strong) NSArray *forums;

@end

@implementation BBSUIThreadForumListSelectViewController

#define kForumListCellReuseIdentifier @"BBSUIThreadForumListTableViewCellReuseIdentifier"

- (instancetype)initWithResult:(void (^)(BBSForum *))result
{
    if (self = [super init])
    {
        _result = result ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configUI];
    [self requestData];
}

- (void)configUI
{
    self.title = @"选择版块" ;

    self.tableView =
    ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:BBSUIThreadForumListTableViewCell.class forCellReuseIdentifier:kForumListCellReuseIdentifier];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self ;
        tableView.dataSource = self ;
        [self.view addSubview:tableView];
        tableView ;
    });
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _forums.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSUIThreadForumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kForumListCellReuseIdentifier];
    
    if (indexPath.row < _forums.count)
    {
        cell.model = _forums[indexPath.row];
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_result)
    {
        _result(_forums[indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (void)requestData
{
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        if (!error)
        {
            
            NSMutableArray *forums = forumsList.mutableCopy;
            
            for (NSInteger i=0; i<forums.count; i++)
            {
                BBSForum *forum = forums[i];
                if (forum.fid <= 0)
                {
                    [forums removeObject:forum];
                }
            }
            
            _forums = forums;
            
            [self.tableView reloadData];
        }
        else
        {
            BBSUIAlert(@"%@,code:%zd",error.userInfo[@"description"],error.code);
        }
    }];
}

@end
