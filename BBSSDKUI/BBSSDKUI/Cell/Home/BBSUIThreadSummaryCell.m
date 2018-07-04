//
//  DZSThreadAbstractCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadSummaryCell.h"
#import <BBSSDK/BBSThread.h>
#import "Masonry.h"
#import "BBSUIViewsRepliesView.h"
#import "BBSUIMacro.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIThreadSummaryCell ()

/**
 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 作者
 */
@property (nonatomic, strong) UILabel *authorLabel;

/**
 标题
 */
@property (nonatomic, strong) UILabel *subjectLabel;

/**
 摘要
 */
@property (nonatomic, strong) UILabel *summaryLabel;

/**
 图片
 */
@property (nonatomic, strong) UIImageView *imagesView;

/**
 图片上数量显示
 */
@property (nonatomic, strong) UILabel *imageCountLabel;

/**
 浏览数View
 */
@property (nonatomic, strong) BBSUIViewsRepliesView *viewsView ;

/**
 回复数View
 */
@property (nonatomic, strong) BBSUIViewsRepliesView *repliesView ;

/**
 时间Label
 */
@property (nonatomic, strong) UILabel *timeLabel ;


@end

@implementation BBSUIThreadSummaryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self configUI];
//        self.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1];
    }
    
    return self;
}


- (void)configUI
{
    //头像
    self.avatarImageView =
    ({
        UIImage *placeholdImage = [UIImage imageNamed:@"default"];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:placeholdImage];
        [self addSubview:avatarImageView];
        [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(18);
            make.width.height.equalTo(@25);
        }];
        avatarImageView ;
    });
    
    //作者名
    self.authorLabel =
    ({
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.font = [UIFont systemFontOfSize:12];
        authorLabel.textColor = DZSUIColorFromHex(0xB4B4B4);
        [self addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(10);
            make.centerY.equalTo(_avatarImageView);
        }];
        
        authorLabel ;
    });
    
    //cell右侧图片
    self.imagesView =
    ({
        UIImageView *imagesView = [[UIImageView alloc] init];
        imagesView.image = [UIImage BBSImageNamed:@"Home/wutu@2x.png"];
        [self addSubview:imagesView];
        [imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(50);
            make.right.equalTo(self).offset(-15);
            make.height.equalTo(@75);
            make.width.equalTo(@0);
            
        }];
        imagesView ;
    });
    
    //主标题
    self.subjectLabel =
    ({
        UILabel *subjectLabel = [[UILabel alloc] init];
        subjectLabel.font = [UIFont systemFontOfSize:16];
        subjectLabel.textColor = DZSUIColorFromHex(0x3A4045);
        subjectLabel.numberOfLines = 2 ;
        subjectLabel.text = @"subjectContent" ;
        [self addSubview:subjectLabel];
        [subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.top.equalTo(_avatarImageView.mas_bottom).offset(7);
            make.right.equalTo(_imagesView.mas_left).offset(-15);
        }];
        subjectLabel;
    });
    
    //摘要
    self.summaryLabel =
    ({
        UILabel *summaryLabel = [[UILabel alloc] init];
        summaryLabel.font = [UIFont systemFontOfSize:13];
        summaryLabel.textColor = DZSUIColorFromHex(0x787878);
        summaryLabel.numberOfLines = 2 ;
        summaryLabel.text = @"summaryContent" ;
        [self addSubview:summaryLabel];
        [summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(3);
            make.width.equalTo(_subjectLabel);
        }];
        
        summaryLabel ;
    });
    

    
    //图片上的图片数
    self.imageCountLabel =
    ({
        UILabel *imageCountLabel = [[UILabel alloc] init];
        imageCountLabel.font = [UIFont boldSystemFontOfSize:16];
        imageCountLabel.textColor = [UIColor whiteColor];
        [_imagesView addSubview:imageCountLabel];
        [imageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_imagesView);
        }];
        imageCountLabel ;
    });

    // 回复数view
    self.repliesView =
    ({
        BBSUIViewsRepliesView *repliesView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeReplies];
        [self addSubview:repliesView];
        [repliesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_summaryLabel);
            make.top.equalTo(_summaryLabel.mas_bottom).offset(15);
            make.height.equalTo(@16);
#warning nodata
            make.width.equalTo(@44);
        }];
        repliesView ;
    });
    
    // 浏览数view
    self.viewsView =
    ({
        BBSUIViewsRepliesView *viewsView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeViews];
        [self addSubview:viewsView];
        [viewsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_repliesView.mas_right).offset(15);
            make.top.equalTo(_repliesView);
            make.height.width.equalTo(_repliesView);
        }];
        viewsView ;
    });
    
    // 时间文本
    self.timeLabel =
    ({
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:11.5];
        timeLabel.textColor = DZSUIColorFromHex(0xB4B4B4);
        timeLabel.text = @"xx时间前";
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(_viewsView);
            make.bottom.equalTo(self).offset(-15);
        }];
        timeLabel ;
    });
}


- (void) setThreadModel:(BBSThread *)threadModel
{
    _threadModel = threadModel ;
    
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_threadModel.avatar] placeholderImage:[UIImage BBSImageNamed:@"Home/wutu@2x.png"]];
    
    _authorLabel.text  = _threadModel.author;
    _subjectLabel.text = _threadModel.subject;
    _summaryLabel.text = _threadModel.summary;
    _repliesView.count = _threadModel.replies ;
    _viewsView.count   = _threadModel.views;
    
    [self layoutIfNeeded];
    
    NSInteger imageCount = _threadModel.images.count ;
    
    if(imageCount)
    {
        NSString * url = [_threadModel.images firstObject];
        
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@100);
        }];
        
        [_imagesView sd_setImageWithURL:[NSURL URLWithString:url]];
        
        _imageCountLabel.hidden = imageCount - 1;
        
        if (imageCount-1)
        {
            _imageCountLabel.text = [@"+" stringByAppendingFormat:@"%zd",_threadModel.images.count];
        }
    }
    else
    {
        _imageCountLabel.hidden = YES;
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
    }
}


@end
