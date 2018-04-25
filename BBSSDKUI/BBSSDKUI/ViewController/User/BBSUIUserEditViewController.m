//
//  BBSUIUserEditViewController.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/19.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIUserEditViewController.h"
#import "Masonry.h"

@interface BBSUIUserEditViewController ()

@property (nonatomic, strong) BBSUIUserEditView *editView;

@property (nonatomic, strong) BBSUser *currentUser;

@property (nonatomic, assign) BBSUIEditUserInfoType type;

@end

@implementation BBSUIUserEditViewController

- (instancetype)initWithUser:(BBSUser *)user editType:(BBSUIEditUserInfoType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _currentUser = user;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTitleColor:DZSUIColorFromHex(0x6A7081)];
    
    self.editView = [[BBSUIUserEditView alloc] initWithFrame:CGRectMake(0, NavigationBar_Height, BBS_WIDTH(self.view), BBS_HEIGHT(self.view)) user:self.currentUser editType:self.type];
    [self.view addSubview:self.editView];

}



- (void)backButtonHandler:(UIButton *)button
{
    if (self.type == BBSUIEditUserInfoTypeRegister) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
