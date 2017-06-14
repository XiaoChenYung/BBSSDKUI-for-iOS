//
//  BBSUIForumItem.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumItem.h"
#import "UIViewExt.h"
#import "UIImage+BBSFunction.h"

#define BBSUIForumImageViewWidth 45

@interface BBSUIForumItem ()

@property (nonatomic, strong) UIImageView *forumImageView;

@property (nonatomic, strong) UILabel *forumTitleLabel;

@property (nonatomic, copy) void (^selectHandler)(BBSForum *forum);

@end

@implementation BBSUIForumItem

- (instancetype)initWithFrame:(CGRect)frame selectHander:(void (^)(BBSForum *))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
        _selectHandler = handler;
    }
    
    return self;
}

- (void)configureUI
{
    self.forumImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - BBSUIForumImageViewWidth) / 2, 5, BBSUIForumImageViewWidth, BBSUIForumImageViewWidth)];
    self.forumImageView.layer.cornerRadius = self.width / 10;
    //将多余的部分切掉
    self.forumImageView.layer.masksToBounds = YES;
    [self.forumImageView setImage:[UIImage BBSImageNamed:@"/Common/forumList.png"]];
    [self addSubview:self.forumImageView];
    
    self.forumTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.forumImageView.bottom + 10, self.width, 15)];
    [self.forumTitleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.forumTitleLabel setTextColor:DZSUIColorFromHex(0x3A4045)];
    [self.forumTitleLabel setText:@"摄影大赛"];
    [self.forumTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.forumTitleLabel];
    
    [self addTapGesture];
}

- (void)setForum:(BBSForum *)forum
{
    _forum = forum;
    if (forum.forumPic) {
        self.forumImageView.image = [UIImage BBSImageNamed:@"/Common/forumList.png"];
        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:forum.forumPic] result:^(UIImage *image, NSError *error) {
            self.forumImageView.image = image;
        }];
    }else{
        if (_forum.fid == 0) {
            self.forumImageView.image = [UIImage BBSImageNamed:@"/Forum/All.png"];
        }
    }
    [self.forumTitleLabel setText:forum.name];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapedHandler:)];
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)itemTapedHandler:(UITapGestureRecognizer *)tap
{
    if (_selectHandler) {
        _selectHandler(self.forum);
    }
}

@end
