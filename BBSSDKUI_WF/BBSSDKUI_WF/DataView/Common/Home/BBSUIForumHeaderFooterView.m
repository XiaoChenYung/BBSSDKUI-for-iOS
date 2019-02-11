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
@property (nonatomic, strong) UIImageView *imageView;
//编辑按钮
@property (nonatomic, strong) UIButton *editButton;
//收放按钮
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) UIView *headerView;

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
        [headView setImageWithSection:section];
    }
    return headView;
}

- (void)setImageWithSection:(NSInteger)section {
    if (section == 0) {
        self.imageView.image = [UIImage BBSImageNamed:@"Thread/icon_mingxing.png"];
    } else if (section == 1) {
        self.imageView.image = [UIImage BBSImageNamed:@"Thread/icon_remen.png"];
    }
}

#pragma mark - UI
- (void)_initViews
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DZSUIScreen_width, 40)];
    [self addSubview:headerView];
    self.headerView = headerView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    self.imageView = imageView;
    [headerView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 4, 50, 32)];
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
    [editButton setTitle:@"完成" forState:UIControlStateSelected];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    self.editButton = editButton;
    
    [editButton addTarget:self action:@selector(_editButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editButton];
    editButton.hidden = true;
    //收放按钮
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setFrame:CGRectMake(DZSUIScreen_width - 15 - editButtonWidth, -15, editButtonWidth+8, 32)];
    [setButton setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
    [setButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [setButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [setButton addTarget:self action:@selector(_setButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [setButton setImage:[UIImage BBSImageNamed:@"User/icon_upArrow.png"] forState:UIControlStateNormal];
    [setButton setImage:[UIImage BBSImageNamed:@"User/icon_downArrow.png"] forState:UIControlStateSelected];
    setButton.tag = 200 + self.sectionTag;
    self.setButton = setButton;
    setButton.hidden = true;
    [headerView addSubview:setButton];
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
    if (_isEdited) {
        _editButton.selected = YES;
    }else {
        _editButton.selected = NO;
    }
}

- (void)updateHeaderView:(NSArray *)allData isSelectForum:(BOOL)isSelect
{
//    if (self.sectionTag == 0) {
//        [self.titleLabel setFrame:CGRectMake(15, 0, DZSUIScreen_width, 32)];
//        [self.titleLabel setText:@"置顶版块"];
        
//        if (isSelect) {
//            self.setButton.hidden = YES;
//            self.editButton.hidden = YES;
//        }else {
//            self.setButton.hidden = YES;
//            self.editButton.hidden = true;
//        }
//    }
//    else
//    {
        [self.titleLabel setFrame:CGRectMake(40, 4, DZSUIScreen_width, 32)];
        NSArray *dicArr = allData[self.sectionTag];
        [dicArr enumerateObjectsUsingBlock:^(BBSForum *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.groupName.length > 0) {
                 [self.titleLabel setText:obj.groupName];
            }else {
                 [self.titleLabel setText:@"论坛列表"];
            }
           
        }];

        self.editButton.hidden = YES;
        self.setButton.hidden = true;
//    }
}

#pragma mark - 编辑
- (void)_editButtonHandler:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.deleagte respondsToSelector:@selector(editForumHeaderView)]) {
        [self.deleagte editForumHeaderView];
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
