//
//  BBSUIForumHeaderItem.m
//  BBSSDKUI
//
//  Created by liyc on 2017/9/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIForumHeaderItem.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"
#import <BBSSDK/BBSForum.h>
#import "UIImageView+WebCache.h"

@interface BBSUIForumHeaderItem ()

@property (nonatomic, strong) UIImageView   *forumImageView;

@property (nonatomic, strong) UILabel       *forumNameLabel;

@property (nonatomic, copy) void (^clickHandler) (BBSForum *forum);

@property (nonatomic, strong) BBSForum *currentForum;

@property (nonatomic, assign) BOOL isMore;

@end

@implementation BBSUIForumHeaderItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _configureUI];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)_configureUI
{
    CGFloat imageViewWidth = 42;
    _forumImageView = [[UIImageView alloc] init];
    [self addSubview:_forumImageView];
    [_forumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.mas_equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(imageViewWidth, imageViewWidth));
    }];
    _forumImageView.layer.cornerRadius = 8;
    [_forumImageView.layer setMasksToBounds:YES];
    [_forumImageView setImage:[UIImage BBSImageNamed:@"/Home/forumItem.png"]];
    
    _forumNameLabel = [UILabel new];
    [self addSubview:_forumNameLabel];
    [_forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forumImageView.mas_bottom).with.offset(10);
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width, 21));
    }];
    _forumNameLabel.font = [UIFont fontWithName:@".PingFangSC-Regular" size:12];
    _forumNameLabel.textColor = [UIColor colorWithRed:78/255.0 green:79/255.0 blue:87/255.0 alpha:1/1.0];
    [_forumNameLabel setTextAlignment:NSTextAlignmentCenter];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)setForum:(BBSForum *)forum moreForumFlag:(BOOL)moreForumFlag result:(void (^)(BBSForum *))handler
{
    self.clickHandler = handler;
    self.currentForum = forum;
    self.isMore = moreForumFlag;
    
    if (moreForumFlag) {
        [_forumNameLabel setText:@"更多"];
        [_forumImageView setImage:[UIImage BBSImageNamed:@"/Home/moreForum.png"]];
    }else{
        [_forumNameLabel setText:forum.name];
        [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                     forHTTPHeaderField:@"Accept"];
        
        if (forum.fid == 0) {
            [_forumImageView sd_setImageWithURL:[NSURL URLWithString:forum.forumPic] placeholderImage:[UIImage BBSImageNamed:@"/Forum/All.png"]];
        }else{
            [_forumImageView sd_setImageWithURL:[NSURL URLWithString:forum.forumPic] placeholderImage:[UIImage BBSImageNamed:@"/Common/forumList.png"]];
        }
    }
}

- (void)itemTapped:(UIGestureRecognizer *)gesture
{
    if (self.clickHandler) {
        
        if (self.isMore) {
            self.clickHandler(nil);
        }else{
            self.clickHandler(self.currentForum);
        }
        
    }
}


@end
