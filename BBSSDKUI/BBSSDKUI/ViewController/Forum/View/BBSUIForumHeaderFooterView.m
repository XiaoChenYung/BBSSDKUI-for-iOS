//
//  BBSUIForumHeaderFooterView.m
//  BBSSDKUI_WF
//
//  Created by 崔林豪 on 2018/4/12.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIForumHeaderFooterView.h"
#import "BBSForum+BBSUI.h"


static NSString *headIdentifier = @"header";

@interface BBSUIForumHeaderFooterView ()

@property (nonatomic, strong) UILabel *titleLabel;
//编辑按钮
@property (nonatomic, strong) UIButton *editButton;
//收放按钮
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *lineView  ;

@end

@implementation BBSUIForumHeaderFooterView

#pragma mark - init
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self _initViews];
    }
    return self;
}

+ (instancetype)sectionHeadViewWithTableView:(UITableView *)tableView section:(NSInteger)section allData:(NSArray *)allData
{
    BBSUIForumHeaderFooterView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headIdentifier];
    if (!headView) {
        headView = [[BBSUIForumHeaderFooterView alloc] initWithReuseIdentifier:headIdentifier];
    }
    return headView;
}

#pragma mark - UI
- (void)_initViews
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 39)];
    [self addSubview:headerView];
    self.headerView = headerView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 50, 32)];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [titleLabel setTextColor:DZSUIColorFromHex(0x6A7081)];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    CGFloat editButtonWidth = 30;
    //编辑按钮
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setFrame:CGRectMake(DZSUIScreen_width - 15 - editButtonWidth, 0, editButtonWidth, 32)];
    [editButton setTitleColor:DZSUIColorFromHex(0x6D96FF) forState:UIControlStateNormal];
    [editButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [editButton setImage:[UIImage BBSImageNamed:@"/Forum/EditForumDone.png"] forState:UIControlStateSelected];
    [editButton setImage:[UIImage BBSImageNamed:@"/Forum/AddForum.png"] forState:UIControlStateNormal];
    self.editButton = editButton;
    
    [editButton addTarget:self action:@selector(_editButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editButton];
    
    //收放按钮
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[setButton setFrame:CGRectMake(DZSUIScreen_width - 15 - editButtonWidth, -15, editButtonWidth+8, 32)];
    [setButton setFrame:CGRectMake(DZSUIScreen_width - 15 - editButtonWidth, 0, editButtonWidth+8, 32)];
    [setButton setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
    [setButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [setButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [setButton addTarget:self action:@selector(_setButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [setButton setImage:[UIImage BBSImageNamed:@"User/icon_upArrow.png"] forState:UIControlStateNormal];
    [setButton setImage:[UIImage BBSImageNamed:@"User/icon_downArrow.png"] forState:UIControlStateSelected];
    setButton.tag = 200 + self.sectionTag;
    self.setButton = setButton;
    
    UIView *lineView = [[UIView alloc] init];
    [headerView addSubview:lineView];
    lineView.backgroundColor = DZSUIColorFromHex(0xEDEFF3);
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
        make.size.height.mas_equalTo(1);
    }];
    self.lineView = lineView;
    [headerView addSubview:setButton];
    
    [self.titleLabel setFrame:CGRectMake(15, 0, DZSUIScreen_width, 32)];
    [self.editButton setFrame:CGRectMake(DZSUIScreen_width - 45, 0, 30, 32)];
    
}

- (void)setIsclicked:(BOOL)isclicked
{
    _isclicked = isclicked;
    if (isclicked) {
        _setButton.selected = YES;
    }else {
        _setButton.selected = NO;
    }
}

- (void)setIsEdited:(BOOL)isEdited
{
    _isEdited = isEdited;
    if (isEdited) {
        _editButton.selected = YES;
    }else {
        _editButton.selected = NO;
    }
}

- (void)tetttttt
{
    _isEdited = !_isEdited;
    if (_isEdited) {
        _editButton.selected = YES;
    }else {
        _editButton.selected = NO;
    }
}

- (void)updateHeaderView:(NSArray *)allData isSelectForum:(BOOL)isSelectForum
{
    if (self.sectionTag == 0) {
        [self.titleLabel setText:@"置顶版块"];
        if (isSelectForum)
        {//选择版块
            self.editButton.hidden = YES;
            self.setButton.hidden = YES;
        }
        else
        {//全部版块
            self.setButton.hidden = YES;
            self.editButton.hidden = NO;
        }
    }
    else
    {
        NSArray *dicArr = allData[self.sectionTag - 1];
        if (isSelectForum)
        {//选择版块
            self.titleLabel.text = @"所有版块";
        }
        else
        {//全部版块
            [dicArr enumerateObjectsUsingBlock:^(BBSForum *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj.groupName.length > 0) {
                    [self.titleLabel setText:obj.groupName];
                }else {
                    [self.titleLabel setText:@"论坛列表"];
                }
                
            }];
        }
        self.editButton.hidden = YES;
        self.setButton.hidden = NO;
    }
}

#pragma mark - 编辑
- (void)_editButtonHandler:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.deleagte respondsToSelector:@selector(editForumHeaderView:)]) {
        [self.deleagte editForumHeaderView:self.sectionTag];
    }
}

#pragma mark - 展开收回
- (void)_setButtonHandler:(UIButton *)sender
{
     sender.selected = !sender.selected;
    if ([self.deleagte respondsToSelector:@selector(expectForumHeaderView:)]) {
        [self.deleagte expectForumHeaderView:self.sectionTag];
    }
    
}

@end
