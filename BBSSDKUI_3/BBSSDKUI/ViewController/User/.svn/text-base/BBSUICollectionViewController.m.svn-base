//
//  BBSUICollectionViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICollectionViewController.h"
#import "BBSUICollectionView.h"

@interface BBSUICollectionViewController ()

@end

@implementation BBSUICollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.collectionViewType == CollectionViewTypeThreadList)
    {
        self.title = @"我的帖子";
    }else if (self.collectionViewType == CollectionViewTypeThreadFavorites)
    {
        self.title = @"我的收藏";
    }
    
    _collectionView = [[BBSUICollectionView alloc] initWithFrame: self.view.bounds type:self.collectionViewType];
    
    __weak typeof (self) weakSelf = self;
    _collectionView.deleteCellBlock = ^(){
        if (weakSelf.deleteCellBlock)
        {
            weakSelf.deleteCellBlock();
        }
    };
    
    [self.view addSubview:_collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置数据
    [_collectionView refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
