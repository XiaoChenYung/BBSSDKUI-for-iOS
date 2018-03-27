//
//  BBSUICollectionTableViewCell.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICollectionTableViewCell.h"
#import "YYImage.h"
#import "Masonry.h"
#import <BBSSDK/BBSThread.h>
#import "BBSUIViewsRepliesView.h"
#import "NSString+Time.h"

#define kImageWidth (([UIScreen mainScreen].bounds.size.width) * 80 / 375)

@interface BBSUICollectionTableViewCell ()

/**
 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 作者名
 */
@property (nonatomic, strong) UILabel *authorLabel;

/**
 摘要
 */
@property (nonatomic, strong) UILabel *summaryLabel;

/**
 图片
 */
@property (nonatomic, strong) YYAnimatedImageView *imagesView;

/**
 时间Label
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 图片数
 */
@property (nonatomic, strong) UILabel *imageCountLabel;

/**
 评论
 */
@property (nonatomic, strong) UILabel *repliesLabel;

/**
 喜欢
 */
@property (nonatomic, strong) UILabel *favoriteLabel;

/**
 查看
 */
@property (nonatomic, strong) UILabel *viewsLabel;

/**
 分割线
 */
@property (nonatomic, strong) UIView *lineView;

@end

@implementation BBSUICollectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI{
    self.contentView.frame = self.frame;
    CGFloat padding = 15;
    
    //头像
    self.avatarImageView =
    ({
        UIImage *placeholdImage = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:placeholdImage];
        avatarImageView.layer.cornerRadius = 12;
        avatarImageView.layer.masksToBounds = YES;
        // 光栅化
        avatarImageView.layer.shouldRasterize = true;
        avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        [self.contentView addSubview:avatarImageView];
        
        avatarImageView.frame = CGRectMake(padding, padding, 24, 24);
        
        avatarImageView ;
    });
    
    //作者名
    self.authorLabel =
    ({
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.font = [UIFont systemFontOfSize:12];
        authorLabel.textColor = DZSUIColorFromHex(0x4E4F57);
        [self.contentView addSubview:authorLabel];
        
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarImageView);
            make.height.equalTo(@12);
            make.left.equalTo(self.avatarImageView.mas_right).offset(8);
        }];
        
        authorLabel ;
    });
    
    // 时间文本
    self.timeLabel =
    ({
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.textColor = DZSUIColorFromHex(0xACADB8);
        timeLabel.text = @"xx时间前";
        [self.contentView addSubview:timeLabel];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarImageView);
            make.height.equalTo(@10);
            make.left.equalTo(self.authorLabel.mas_right).offset(8);
        }];
        
        timeLabel ;
    });
    
    //cell右侧图片
    self.imagesView =
    ({
        YYAnimatedImageView *imagesView = [[YYAnimatedImageView alloc] init];
        imagesView.contentMode = UIViewContentModeScaleAspectFill;
        imagesView.clipsToBounds = YES;
        imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [self.contentView addSubview:imagesView];
        
        imagesView ;
    });
    
    //主标题
    self.summaryLabel =
    ({
        UILabel *subjectLabel = [[UILabel alloc] init];
        subjectLabel.font = [UIFont boldSystemFontOfSize:16];
        subjectLabel.textColor = DZSUIColorFromHex(0x4E4F57);
        subjectLabel.numberOfLines = 2 ;
        subjectLabel.text = @"subjectContent" ;
        [self.contentView addSubview:subjectLabel];
        
        subjectLabel;
    });
    
    self.lineView =
    ({
        UIView *line = [UIView new];
        line.backgroundColor = DZSUIColorFromHex(0xF9F9F9);
        [self.contentView addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@3);
        }];
        
        line;
    });
    
    self.repliesLabel =
    ({
        UILabel *replies = [UILabel new];
        replies.font = [UIFont systemFontOfSize:10];
        replies.textColor = DZSUIColorFromHex(0xACADB8);
        replies.text = @"评论 ";
        [self.contentView addSubview:replies];
        
        replies;
    });
    
    self.favoriteLabel =
    ({
        UILabel *favorite = [UILabel new];
        favorite.font = [UIFont systemFontOfSize:10];
        favorite.textColor = DZSUIColorFromHex(0xACADB8);
        favorite.text = @"喜欢 ";
        [self.contentView addSubview:favorite];
        
        [favorite mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.repliesLabel.mas_right).offset(8);
            make.top.height.equalTo(self.repliesLabel);
        }];
        
        favorite;
    });
    
    self.viewsLabel =
    ({
        UILabel *views = [UILabel new];
        views.font = [UIFont systemFontOfSize:10];
        views.textColor = DZSUIColorFromHex(0xACADB8);
        views.text = @"查看 ";
        [self.contentView addSubview:views];
        
        [views mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.favoriteLabel.mas_right).offset(8);
            make.top.height.equalTo(self.repliesLabel);
        }];
        
        views;
    });
    
    
    //图片上的图片数
    self.imageCountLabel =
    ({
        UILabel *imageCountLabel = [[UILabel alloc] init];
        imageCountLabel.font = [UIFont systemFontOfSize:18];
        imageCountLabel.textColor = [UIColor whiteColor];
        imageCountLabel.textAlignment = NSTextAlignmentCenter;
        [_imagesView addSubview:imageCountLabel];
        
        imageCountLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_imagesView.frame), CGRectGetHeight(_imagesView.frame));
        
        imageCountLabel;
    });
    
}

- (void)setCollection:(BBSThread *)collection{
    _avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
    
    [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:collection.avatar] result:^(NSData *imageData, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error);
            return ;
        }
        UIImage *image = [UIImage imageWithData:imageData];
        
        //        [weadSelf setImageWithImage:image inView:_avatarImageView];
        _avatarImageView.image = image;
    }];
    
    if (_collectionViewType == CollectionViewTypeHistory && [collection.type isEqualToString:@"portal"])
    {
        _summaryLabel.attributedText = [self stringWithString:collection.summary lineSpace:6];
    }
    else
    {
        _summaryLabel.attributedText = [self stringWithString:collection.subject lineSpace:6];
    }
    
    if (collection.aid)
    {
        _favoriteLabel.text = [NSString stringWithFormat:@"喜欢 %lu",(long)collection.click1];
        _repliesLabel.text = [NSString stringWithFormat:@"评论 %lu",(long)collection.commentnum];
        _viewsLabel.text = [NSString stringWithFormat:@"查看 %lu",(long)collection.viewnum];
    }
    else
    {
        _repliesLabel.text = [NSString stringWithFormat:@"评论 %lu",(long)collection.replies];
        _favoriteLabel.text = [NSString stringWithFormat:@"喜欢 %lu",(long)collection.recommend_add];
        _viewsLabel.text = [NSString stringWithFormat:@"查看 %lu",(long)collection.views];
    }
    
    if (collection.images.count >= 2)
    {
        _imageCountLabel.hidden = NO;
        _imageCountLabel.text = [@"+" stringByAppendingFormat:@"%zd",collection.images.count];
    }
    else
    {
        _imageCountLabel.hidden = YES;
    }
    
    _authorLabel.text = collection.author;
    _timeLabel.text = [NSString timeTextWithTimesStamp:collection.createdOn];
    if (collection.aid)
    {
        _timeLabel.text = [NSString timeTextWithTimesStamp:collection.dateline];
    }
    
    if (collection.images.count > 0 || collection.pic) {
        NSString * url = [collection.images firstObject];
        if (!url)
        {
            url = collection.pic;
        }
        _imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:url] result:^(NSData *imageData, NSError *error) {
            if (error)
            {
                NSLog(@"%@",error);
                return ;
            }
            
            UIImage *image = [UIImage imageWithData:imageData];
            _imagesView.image = image;
        }];
    }
    
    if (_collectionViewType == CollectionViewTypeThreadList || _collectionViewType == CollectionViewTypeOtherUserThreadList)
    {
        [self setFrameForUserThread:collection];
    }
    else
    {
        [self setFrameForFavorites:collection];
    }
    
    if ( (!collection.author || collection.author.length == 0) && collection.tid)
    {
        _avatarImageView.image = [UIImage BBSImageNamed:@"/Thread/bbs_login_account.png"];
        _authorLabel.text = @"匿名用户";
    }
}

// 收藏、历史记录
- (void)setFrameForFavorites:(BBSThread *)collection
{
    self.avatarImageView.hidden = NO;
    self.authorLabel.hidden = NO;
    
    CGFloat subjectlabelR;
    
    if(collection.images.count || collection.pic)
    {
        _imagesView.hidden = NO;
        
        [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@95);
            make.top.equalTo(@24);
            make.bottom.equalTo(@-24);
            make.right.equalTo(@-20);
        }];
        
        subjectlabelR = -135;
    }
    else
    {
        _imagesView.hidden = YES;
        subjectlabelR = -15;
    }
    
    [_summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImageView);
        make.top.equalTo(self.contentView).offset(49);
        make.right.equalTo(@(subjectlabelR));
    }];
    
    if(collection.images.count || collection.pic)
    {
        [_repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView);
            make.bottom.equalTo(self.contentView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
    else
    {
        [_repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView);
            make.top.equalTo(self.summaryLabel.mas_bottom).offset(17);
            make.bottom.equalTo(self.lineView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
}

/**
 个人帖子
 */
- (void)setFrameForUserThread:(BBSThread *)collection
{
    self.avatarImageView.hidden = YES;
    self.authorLabel.hidden = YES;
    
    CGFloat subjectlabelR;
    
    if(collection.images.count || collection.pic)
    {
        _imagesView.hidden = NO;
        
        [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@95);
            make.top.equalTo(@24);
            make.bottom.equalTo(_lineView.mas_top).offset(-24);
            make.right.equalTo(@-20);
        }];
        
        subjectlabelR = -135;
    }
    else
    {
        _imagesView.hidden = YES;
        subjectlabelR = -15;
    }
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@22);
        make.height.equalTo(@10);
    }];
    
    [_summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(self.contentView).offset(49);
        make.right.equalTo(@(subjectlabelR));
    }];
    
    if(collection.images.count || collection.pic)
    {
        [_repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeLabel);
            make.bottom.equalTo(self.contentView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
    else
    {
        [_repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeLabel);
            make.top.equalTo(self.summaryLabel.mas_bottom).offset(17);
            make.bottom.equalTo(self.lineView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
}

- (NSMutableAttributedString *)stringWithString:(NSString *)string lineSpace:(CGFloat)offset
{
    if (!string)
    {
        return nil;
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
    
    [paragrah setLineSpacing:offset];
    
    [str addAttribute:NSParagraphStyleAttributeName value:paragrah range:NSMakeRange(0, string.length)];
    
    return str;
}


@end
