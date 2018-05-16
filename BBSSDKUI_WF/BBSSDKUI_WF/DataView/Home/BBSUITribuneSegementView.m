//
//  BBSUITribuneSegementView.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/6.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUITribuneSegementView.h"
#import "BBSUIPopoverView.h"


@interface BBSUITribuneSegementView ()

@property (nonatomic, strong)UIView *bottomLine;
@property (nonatomic, strong) UIButton *currentSelectedBtn;
@property (nonatomic, assign) NSInteger currentOrderType;
@property (nonatomic, assign) NSInteger currentSelectType;

@end

@implementation BBSUITribuneSegementView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonsArr = [NSMutableArray array];
        [self _initUI];
        self.userInteractionEnabled = YES;
        self.backgroundColor = DZSUIColorFromHex(0xffffff);
    }
    return self;
}

#pragma mark - initUI
- (void)_initUI
{
    NSArray *titlesArr = @[@"最新",@"热门",@"精华",@"置顶"];
    UIView *lastView = nil;
    CGFloat width = (DZSUIScreen_width - 276)/4;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        [self.buttonsArr addObject:btn];
        [btn setTitleColor:DZSUIColorFromHex(0x6D96FF) forState:UIControlStateSelected];
        [btn setTitleColor:DZSUIColorFromHex(0x29292F) forState:UIControlStateNormal];
        btn.titleLabel.font = BBSFont(15);
        [btn setTitle:titlesArr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 20 + i;
        if (i == 0) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(78);
                make.top.bottom.mas_equalTo(-2);
            }];
        }else {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(lastView.mas_right).mas_equalTo(width);
                make.top.bottom.mas_equalTo(-2);
            }];
        }
        lastView = btn;
    }
    UIButton *btn = [self viewWithTag:20];
    
    //下划线
    UIView *bottomLine = [[UIView alloc] init];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastView.mas_bottom).offset(0);
        make.centerX.mas_equalTo(lastView);
        make.size.mas_equalTo(CGSizeMake(30, 2));
    }];
    bottomLine.backgroundColor = DZSUIColorFromHex(0x6D96FF);
    self.bottomLine = bottomLine;
    
    //筛选按钮
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:filterBtn];
    
        [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.left.mas_equalTo(lineView.mas_right).mas_equalTo(11);
            make.right.mas_equalTo(-11);
            make.centerY.mas_equalTo(lastView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
    
    [filterBtn setBackgroundImage:[UIImage BBSImageNamed:@"User/icon_Sort.png"] forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //竖线
    UIView *lineView = [UIView new];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(filterBtn.mas_left).mas_equalTo(-5);
        make.centerY.mas_equalTo(lastView);
        make.size.mas_equalTo(CGSizeMake(1, 15));
    }];
    lineView.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
    
    
    [self typeClick:btn];
}

#pragma mark - 筛选
- (void)hoverViewClick:(UIButton *)sender
{
    _currentSelectedBtn.selected = NO;
    sender.selected = YES;
    _currentSelectedBtn = sender;

    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_currentSelectedBtn);
        make.top.mas_equalTo(_currentSelectedBtn.mas_bottom).mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 2));
    }];
}

- (void)typeClick:(UIButton *)sender
{
    _currentSelectedBtn.selected = NO;
    sender.selected = YES;
    _currentSelectedBtn = sender;
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_currentSelectedBtn);
        make.top.mas_equalTo(_currentSelectedBtn.mas_bottom).mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 2));
    }];
   
     self.currentSelectType = sender.tag - 20;
    switch (sender.tag) {
        case 20://最新
        {
            [self.delegate selectSegementType:BBSUISegmentViewMenuTypeNew];
        }
            break;
        case 21://热门
        {
            [self.delegate selectSegementType:BBSUISegmentViewMenuTypeHot];
        }
            break;
        case 22://精华
        {
            [self.delegate selectSegementType:BBSUISegmentViewMenuTypeCream];
        }
            break;
        case 23://置顶
        {
            [self.delegate selectSegementType:BBSUISegmentViewMenuTypeTop];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 排序
- (void)filterBtnClick:(UIButton *)sender
{
    BBSUIPopoverView *orderPopoverView = [BBSUIPopoverView popoverView];
    orderPopoverView.showShade = YES; // 显示阴影背景
    orderPopoverView.selectType = self.currentSelectType;
    orderPopoverView.orderIndex = self.currentOrderType;
    [orderPopoverView showToView:sender withActions:[self orderTypeActions] button:sender];
}

- (NSArray<BBSUIPopoverAction *> *)orderTypeActions {
    
    __weak typeof(self) theThreadListVC = self;
    BBSUIPopoverAction *createdOnOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按回复时间排序" handler:^(BBSUIPopoverAction *action) {
         self.currentOrderType = 0;
        //theThreadListVC.currentOrderType = 0;
        //[theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        [theThreadListVC.delegate selectSortByType:BBSUISegmentViewMenuReplySort];
        
    }];
    // 加好友 action
    BBSUIPopoverAction *lastPostOrderAction = [BBSUIPopoverAction actionWithSelectedImage:nil deselectedImage:nil title:@"按发帖时间排序" handler:^(BBSUIPopoverAction *action) {
        self.currentOrderType = 1;
        //theThreadListVC.currentOrderType = 1;
        //[theThreadListVC.threadListView requestDataWithOrderType:theThreadListVC.currentOrderType];
        [theThreadListVC.delegate selectSortByType:BBSUISegmentViewMenuSendSort];
        
    }];
    
    return @[createdOnOrderAction, lastPostOrderAction];
}


@end
