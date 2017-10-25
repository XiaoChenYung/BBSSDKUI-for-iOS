//
//  DZSThreadAbstractCell.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadSummaryCell.h"
#import "BBSThread+BBSUI.h"
#import "Masonry.h"
#import "BBSUIViewsRepliesView.h"
#import "BBSUIMacro.h"
#import "UIImage+BBSFunction.h"
#import "YYImage.h"
#import "YYAnimatedImageView.h"
#import "BBSUIThreadTypeSignView.h"
#import "NSString+Time.h"
#import "NSString+Paragraph.h"

#define kImageWidth (([UIScreen mainScreen].bounds.size.width) * 80 / 375)

@interface BBSUIThreadSummaryCell ()

/**
 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 版块标签
 */
@property (nonatomic, strong) UILabel *forumTagView;

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
@property (nonatomic, strong) YYAnimatedImageView *imagesView;

/**
 图片上数量显示
 */
@property (nonatomic, strong) UILabel *imageCountLabel;

/**
 顶 精 热
 */
@property (nonatomic, strong) BBSUIThreadTypeSignView *signView;

/**
 时间Label
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 显示 精华 顶 热门的 标示
 */
@property (nonatomic, strong) NSMutableArray *signs;

/**
 分割线
 */
@property (nonatomic, strong) UIView *line;

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

@property (nonatomic, strong) BBSThread *threadModel;

@property (nonatomic, assign) BBSUIThreadSummaryCellType cellType;

@end

@implementation BBSUIThreadSummaryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self configUI];
    }
    
    return self;
}


- (void)configUI
{
    self.contentView.frame = self.frame;
    
    _line = [[UIView alloc] init];
    _line.backgroundColor = DZSUIColorFromHex(0xF9F9F9);
    [self.contentView addSubview:_line];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).priorityHigh();
        make.height.mas_equalTo(3).priorityHigh();
        make.bottom.equalTo(self.contentView);
    }];
    
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
        
        [avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@15);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
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
            make.left.equalTo(_avatarImageView.mas_right).offset(8);
            make.centerY.equalTo(_avatarImageView);
            make.height.equalTo(@14);
        }];
        
        authorLabel ;
    });
    
    //cell右侧图片
    self.imagesView =
    ({
        YYAnimatedImageView *imagesView = [[YYAnimatedImageView alloc] init];
        imagesView.contentMode = UIViewContentModeScaleAspectFill;
        imagesView.clipsToBounds = YES;
        imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [self.contentView addSubview:imagesView];
        
        [imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@19);
            make.right.equalTo(@-15);
            make.width.height.equalTo(@105);
        }];
        
        imagesView ;
    });
    
    //主标题
    self.subjectLabel =
    ({
        UILabel *subjectLabel = [[UILabel alloc] init];
  
        subjectLabel.font = [UIFont boldSystemFontOfSize:16];
        subjectLabel.textColor = DZSUIColorFromHex(0x4E4F57);
        subjectLabel.numberOfLines = 2 ;
        subjectLabel.text = @"" ;
        [self.contentView addSubview:subjectLabel];
        
        [subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(_avatarImageView.mas_bottom).offset(10);
            make.right.equalTo(@-15);
        }];
        
        subjectLabel;
    });
    
    self.repliesLabel =
    ({
        UILabel *replies = [UILabel new];
        replies.font = [UIFont systemFontOfSize:10];
        replies.textColor = DZSUIColorFromHex(0xACADB8);
        replies.text = @"评论 ";
        [self.contentView addSubview:replies];
        
        [replies mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.height.equalTo(@10);
            make.bottom.equalTo(_line.mas_top).offset(-17);
        }];
        
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
        
        [imageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_imagesView);
            make.width.height.equalTo(_imagesView);
        }];
        
        imageCountLabel;
    });
    
    self.forumTagView =
    ({
        UILabel *forumTagView = [UILabel new];
        forumTagView.textColor = DZSUIColorFromHex(0xACADB8);
        forumTagView.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:forumTagView];
        
        [forumTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(_line.mas_top).offset(18);
        }];
        
        forumTagView ;
    });
    
    self.signView =
    ({
        BBSUIThreadTypeSignView *signView = [[BBSUIThreadTypeSignView alloc] init];
        
        [self.contentView addSubview:signView];
        [signView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.viewsLabel.mas_right).offset(8);
            make.centerY.equalTo(_viewsLabel);
        }];
        
        signView ;
    });
    
    self.timeLabel =
    ({
        UILabel *time = [UILabel new];
        [self.contentView addSubview:time];
        time.font = [UIFont systemFontOfSize:10];
        time.textColor = DZSUIColorFromHex(0xACADB8);
        
        time;
    });
    
    self.subjectLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 66;
    [self.subjectLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (void) setThreadModel:(BBSThread *)threadModel cellType:(BBSUIThreadSummaryCellType)cellType
{
    _cellType = cellType;
    _threadModel = threadModel ;
    
    _avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
    
    [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:_threadModel.avatar] result:^(NSData *imageData, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error);
            return ;
        }
        UIImage *image = [UIImage imageWithData:imageData];
    
        _avatarImageView.image = image;
    }];
    
    self.read = _threadModel.isSelected;
    
    _signs = [NSMutableArray array];
    
    if (_threadModel.heatLevel)
    {
        [_signs addObject:kSignTypeHot];
    }
    
    if (_threadModel.digest)
    {
        [_signs addObject:kSignTypePerfect];
    }
    
    if (_threadModel.displayOrder > 0)
    {
        [_signs addObject:kSignTypeLike];
    }
    
    [_signView setupWithPaths:_signs.mutableCopy];
    
    if (_threadModel.forumName)
    {
        _forumTagView.text = _threadModel.forumName;
    }
    else
    {

    }

    _timeLabel.text = [NSString timeTextWithTimesStamp:threadModel.createdOn];
    
    NSInteger imageCount = _threadModel.images.count ;
    
    if(imageCount)
    {
        _imagesView.hidden = NO;
        
        NSString * url = [_threadModel.images firstObject];
        
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
        
        
        if (imageCount-1)
        {
            _imageCountLabel.hidden = NO;
            _imageCountLabel.text = [@"+" stringByAppendingFormat:@"%zd",_threadModel.images.count];
        }
        else
        {
            _imageCountLabel.hidden = YES;
        }
    }
    else
    {
        _imagesView.hidden = YES;
        
    }
    
    _repliesLabel.text = [NSString stringWithFormat:@"评论 %lu",(long)_threadModel.replies];
    _favoriteLabel.text = [NSString stringWithFormat:@"喜欢 %lu",(long)_threadModel.recommend_add];
    _viewsLabel.text = [NSString stringWithFormat:@"查看 %lu",(long)_threadModel.views];
    
    // 设置frame
    [self _setCellFrame];
}

/**
 贝塞尔曲线方式设置圆角图片
 
 @param image image
 @param imageView imageView
 */
- (void)setImageWithImage:(UIImage *)image inView:(UIImageView *)imageView{
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size,NO,1.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:3] addClip];
    [image drawInRect:imageView.bounds];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)setRead:(BOOL)read
{
    _read = read;
    
    _authorLabel.attributedText  = [NSString stringWithString:_threadModel.author
                                                     fontSize:13
                                            defaultColorValue:@"8A8D94"
                                                    lineSpace:0
                                                    wordSpace:0];
    
    if (_read)
    {
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString stringWithString:_threadModel.subject
                                                             fontSize:16
                                                    defaultColorValue:@"ACADB8"
                                                            lineSpace:6
                                                            wordSpace:0];

        }else{
            _subjectLabel.attributedText = [self stringWithString:_threadModel.subject lineSpace:1];

            _subjectLabel.textColor = DZSUIColorFromHex(0xACADB8);

        }
        
    }
    else
    {
        
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString stringWithString:_threadModel.subject
                                                             fontSize:16
                                                    defaultColorValue:@"4E4F57"
                                                            lineSpace:6
                                                            wordSpace:0];
            
        }else{
            _subjectLabel.attributedText = [self stringWithString:_threadModel.subject lineSpace:6];

            _subjectLabel.textColor = DZSUIColorFromHex(0x4E4F57);

        }
        
    }
    
    if (_threadModel.subject.length == 0) _subjectLabel.text = @" ";

}

- (void)_setCellFrame
{
    if (_cellType == BBSUIThreadSummaryCellTypeForums || _cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        _signView.hidden = NO;
        _forumTagView.hidden = YES;
        _avatarImageView.hidden = NO;
        _authorLabel.hidden = NO;
        _repliesLabel.hidden = NO;
        _favoriteLabel.hidden = NO;
        _viewsLabel.hidden = NO;
        
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        
        [self _setForumFrame];
    }
    
    if (_cellType == BBSUIThreadSummaryCellTypeHomepage)
    {
        _signView.hidden = YES;
        _forumTagView.hidden = NO;
        _avatarImageView.hidden = YES;
        _authorLabel.hidden = YES;
        _repliesLabel.hidden = YES;
        _favoriteLabel.hidden = YES;
        _viewsLabel.hidden = YES;
        
        [self _setFrameHomePage];
    }
    
    if (_cellType == BBSUIThreadSummaryCellTypeHistory)
    {
        _timeLabel.hidden = NO;
        
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)_setFrameHomePage
{
    CGFloat padding = 15;
    NSInteger imageCount = _threadModel.images.count ;
    
    CGFloat subjectlabelR;
    
    if (imageCount > 0 && _threadModel.images)
    {
        _imagesView.hidden = NO;
        subjectlabelR = -140;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-padding));
            make.top.equalTo(@10).priorityHigh();
            make.bottom.equalTo(_line.mas_top).offset(-10);
            make.width.height.equalTo(@105);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(@10);
            make.right.equalTo(@-140);
        }];
        
        [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(_line.mas_top).offset(-18);
        }];
    }
    else
    {
        _imagesView.hidden = YES;
        subjectlabelR = -15;
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(@10).priorityHigh();
            make.right.equalTo(@-15);
        }];
        
        [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(_line.mas_top).offset(-18);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(22);
        }];
    }
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = DZSUIColorFromHex(0xEDEFF3);
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 11));
        make.left.equalTo(_forumTagView.mas_right).offset(8);
        make.centerY.equalTo(_forumTagView);
    }];
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).offset(8);
        make.centerY.equalTo(_forumTagView);
        make.height.equalTo(_forumTagView);
    }];
}

- (void)_setForumFrame
{
    CGFloat padding = 15;
    NSInteger imageCount = _threadModel.images.count ;
    
    if (imageCount && _threadModel.images)
    {
        _imagesView.hidden = NO;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-padding));
            make.top.equalTo(@19).priorityHigh();
            make.width.height.equalTo(@105);
        }];
        
        [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).priorityHigh();
            make.height.mas_equalTo(3).priorityHigh();
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(_imagesView.mas_bottom).offset(19);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
            make.right.equalTo(_imagesView.mas_left).offset(-20);
        }];
        
        [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.bottom.equalTo(_line.mas_top).offset(-17);
            make.height.equalTo(@10);
        }];
    }
    else
    {
        _imagesView.hidden = YES;
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
            make.right.equalTo(@-15);
        }];
        
        [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(17);
            make.bottom.equalTo(_line.mas_top).offset(-17);
            make.height.equalTo(@10);
        }];
    }
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_authorLabel.mas_right).offset(8);
        make.centerY.equalTo(_authorLabel);
        make.height.equalTo(_authorLabel);
    }];
}

// 收藏
- (void)setFrameForFavorites
{
    CGFloat subjectlabelR;
    
    NSInteger imageCount = _threadModel.images.count ;
    if(imageCount)
    {
        _imagesView.hidden = NO;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
    
    [_subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImageView);
        make.top.equalTo(self.contentView).offset(49);
        make.right.equalTo(@(subjectlabelR));
    }];
    
    if(imageCount)
    {
        [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView);
            make.bottom.equalTo(self.contentView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
    else
    {
        [_repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView);
            make.top.equalTo(self.subjectLabel.mas_bottom).offset(17);
            make.bottom.equalTo(self.contentView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
}

/**
 个人帖子
 */
- (void)setFrameForUserThread
{
    CGFloat subjectlabelR;
    
    NSInteger imageCount = _threadModel.images.count ;
    if(imageCount)
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
    
    self.avatarImageView.hidden = YES;
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@22);
        make.height.equalTo(@10);
    }];
    
    [_subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImageView);
        make.top.equalTo(self.contentView).offset(49);
        make.right.equalTo(@(subjectlabelR));
    }];
    
    if(imageCount)
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
            make.top.equalTo(self.subjectLabel.mas_bottom).offset(17);
            make.bottom.equalTo(self.contentView).offset(-17).priorityHigh();
            make.height.equalTo(@10);
        }];
    }
}


- (NSMutableAttributedString *)stringWithString:(NSString *)string lineSpace:(CGFloat)offset
{
    if (!string) {
        string = @"";
    }
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
    
    [paragrah setLineSpacing:offset];
    
    [str addAttribute:NSParagraphStyleAttributeName value:paragrah range:NSMakeRange(0, string.length)];
    
    return str;
}


@end
