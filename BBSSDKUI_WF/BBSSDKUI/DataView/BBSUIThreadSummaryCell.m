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

#define kImageWidth (([UIScreen mainScreen].bounds.size.width) * 80 / 375)

@interface BBSUIThreadSummaryCell ()

/**
 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 版块标签
 */
@property (nonatomic, strong) UIButton *forumTagView;

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
@property (nonatomic, strong) UILabel *timeLabel;

/**
 显示 精华 顶 热门的 标示
 */
@property (nonatomic, strong) NSMutableArray *signs;

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
    //头像
    self.avatarImageView =
    ({
        UIImage *placeholdImage = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:placeholdImage];
        avatarImageView.layer.cornerRadius = 3;
        avatarImageView.layer.masksToBounds = YES;
        [self addSubview:avatarImageView];
        [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(15);
            make.width.height.equalTo(@20);
        }];
        avatarImageView ;
    });
    
    //作者名
    self.authorLabel =
    ({
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.font = [UIFont systemFontOfSize:13];
        authorLabel.textColor = DZSUIColorFromHex(0x8A8D94);
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
        YYAnimatedImageView *imagesView = [[YYAnimatedImageView alloc] init];
        imagesView.contentMode = UIViewContentModeScaleAspectFill;
        imagesView.clipsToBounds = YES;
        imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [self addSubview:imagesView];
        imagesView ;
    });
    
    //主标题
    self.subjectLabel =
    ({
        UILabel *subjectLabel = [[UILabel alloc] init];
        subjectLabel.font = [UIFont boldSystemFontOfSize:16];
        subjectLabel.textColor = DZSUIColorFromHex(0x3A4045);
        subjectLabel.numberOfLines = 2 ;
        subjectLabel.text = @"subjectContent" ;
        [self addSubview:subjectLabel];
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
            make.top.equalTo(_subjectLabel.mas_bottom).offset(9);
        }];
        
        summaryLabel ;
    });
    
    //图片上的图片数
    self.imageCountLabel =
    ({
        UILabel *imageCountLabel = [[UILabel alloc] init];
        imageCountLabel.font = [UIFont systemFontOfSize:18];
        imageCountLabel.textColor = [UIColor whiteColor];
        [_imagesView addSubview:imageCountLabel];
        [imageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_imagesView);
        }];
        imageCountLabel ;
    });
    
    self.forumTagView =
    ({
        UIButton *forumTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [forumTagView setTitle:@"版块" forState:UIControlStateNormal];
        [forumTagView setTitleColor:DZSUIColorFromHex(0xB4B4B4) forState:UIControlStateNormal];
        forumTagView.titleLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:forumTagView];
        
        forumTagView ;
    });
    
    self.signView =
    ({
        BBSUIThreadTypeSignView *signView = [[BBSUIThreadTypeSignView alloc] init];

        [self addSubview:signView];

        signView ;
    });
    
    // 回复数view
    self.repliesView =
    ({
        BBSUIViewsRepliesView *repliesView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeReplies];
        
        [self addSubview:repliesView];
        [repliesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_forumTagView.mas_right).offset(23);
            make.centerY.equalTo(_forumTagView);
        }];
        
        repliesView ;
    });
    
    // 浏览数view
    self.viewsView =
    ({
        BBSUIViewsRepliesView *viewsView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeViews];

        [self addSubview:viewsView];
        [viewsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_repliesView.mas_right).offset(23);
            make.centerY.equalTo(_repliesView);
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
        }];
        timeLabel ;
    });
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.075;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self).priorityHigh();
        make.height.mas_equalTo(1).priorityHigh();
        make.top.equalTo(_repliesView.mas_bottom).offset(15).priorityHigh();
    }];
}

- (void) setThreadModel:(BBSThread *)threadModel
{
    _threadModel = threadModel ;
    
    _avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
    [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:_threadModel.avatar] result:^(NSData *imageData, NSError *error) {
        if (error)
        {
            BBSUILog(@"%@",error);
            return ;
        }
        UIImage *image = [UIImage imageWithData:imageData];
        _avatarImageView.image = image;
    }];
    
    _authorLabel.text  = _threadModel.author;
    
    _subjectLabel.attributedText = [self stringWithString:_threadModel.subject lineSpace:6];
    _summaryLabel.attributedText = [self stringWithString:_threadModel.summary lineSpace:3];

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
        _forumTagView.hidden = NO;
        [_forumTagView setTitle:[NSString stringWithFormat:@" %@ ",_threadModel.forumName] forState:UIControlStateNormal];
    }
    else
    {
        _forumTagView.hidden = YES;
    }
    
    NSInteger timeOffset = [[NSDate date] timeIntervalSince1970] - threadModel.createdOn ;
    
    _timeLabel.text = [self timeTextWithOffset:timeOffset];
    
    NSInteger imageCount = _threadModel.images.count ;
    
    if(imageCount)
    {
        NSString * url = [_threadModel.images firstObject];
        
        _imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:url] result:^(NSData *imageData, NSError *error) {
            if (error)
            {
                BBSUILog(@"%@",error);
                return ;
            }
            
            UIImage *image = [UIImage imageWithData:imageData];
            _imagesView.image = image;
        }];
                
        [self makeConstraintWithImageType];
                
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
        _imageCountLabel.hidden = YES;
    
        [self makeConstraintWithNoImageType];
    }
}

- (NSString *)timeTextWithOffset:(NSInteger)offset
{
    NSInteger year = 365 * 24 * 60 * 60 ;
    NSInteger month = 30 * 24 * 60 * 60 ;
    NSInteger day = 24 * 60 * 60 ;
    NSInteger hour = 60 * 60 ;
    NSInteger min = 60 ;
    
    if (offset/year)
    {
        return [NSString stringWithFormat:@"%zd年前",offset/year];
    }
    
    if (offset/month)
    {
        return [NSString stringWithFormat:@"%zd月前",offset/month];
    }
    
    if (offset/day)
    {
        return [NSString stringWithFormat:@"%zd天前",offset/day];
    }
    
    if (offset/hour)
    {
         return [NSString stringWithFormat:@"%zd小时前",offset/hour];
    }
    
    if (offset/min)
    {
        return [NSString stringWithFormat:@"%zd分钟前",offset/min];
    }
    
    return [NSString stringWithFormat:@"%zd秒前",offset];
}

- (void)makeConstraintWithImageType
{
    [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(46);
        make.right.equalTo(self).offset(-15);
        make.width.equalTo(@(kImageWidth));
        make.height.equalTo(@(kImageWidth));
    }];
    
    [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImageView);
        make.top.equalTo(self).offset(44);
        make.right.equalTo(_imagesView.mas_left).offset(-15);
    }];
    
    [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_summaryLabel);
//        make.top.equalTo(self).offset(46+kImageWidth+7);
        make.top.equalTo(_summaryLabel.mas_bottom).offset(7).priorityHigh();
    }];
    
    [_signView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_summaryLabel);
        make.centerY.equalTo(_forumTagView);
    }];
}

- (void)makeConstraintWithNoImageType
{
    [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(46);
        make.right.equalTo(self).offset(-15);
        make.width.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatarImageView);
        make.top.equalTo(self).offset(44);
        make.right.equalTo(_imagesView.mas_left);
    }];
    
    [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_summaryLabel);
        make.top.equalTo(_summaryLabel.mas_bottom).offset(7).priorityHigh();
    }];
    
    [_signView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_summaryLabel);
        make.centerY.equalTo(_forumTagView);
    }];
}

- (void)setRead:(BOOL)read
{
    _read = read;
    
    if (_read)
    {
        _subjectLabel.textColor = DZSUIColorFromHex(0xA5A7A8);
        _summaryLabel.textColor = DZSUIColorFromHex(0x9A9EA5);
    }
    else
    {
        _subjectLabel.textColor = DZSUIColorFromHex(0x3A4045);
        _summaryLabel.textColor = DZSUIColorFromHex(0x9A9EA5);
    }
}

- (void)setCellType:(BBSUIThreadSummaryCellType)cellType
{

    if (cellType == BBSUIThreadSummaryCellTypeHomepage)
    {
        _signView.hidden = YES;
        _forumTagView.hidden = NO;
        _timeLabel.hidden = YES;
        
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleImage];
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleImage];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_forumTagView.mas_right).offset(23);
            make.centerY.equalTo(_forumTagView);
        }];
    }
    else
    {
        _signView.hidden = NO;
        _forumTagView.hidden = YES;
        _timeLabel.hidden = NO;
        
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleCharacters];
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleCharacters];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_signView.mas_right).offset(_signs.count?10:0);
            make.centerY.equalTo(_forumTagView);
        }];
    }
}

- (NSMutableAttributedString *)stringWithString:(NSString *)string lineSpace:(CGFloat)offset
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
    
    [paragrah setLineSpacing:offset];
    
    [str addAttribute:NSParagraphStyleAttributeName value:paragrah range:NSMakeRange(0, string.length)];
    
    return str;
}

@end
