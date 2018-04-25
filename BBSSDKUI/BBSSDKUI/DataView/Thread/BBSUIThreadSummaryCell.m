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
#import "NSString+BBSUITime.h"
#import "NSString+BBSUIParagraph.h"

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
 分割线2
 */
@property (nonatomic, strong) UIView *lineOrange;

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

/**
 资讯还是论坛的标签
 */
@property (nonatomic, strong) UILabel *tipLabel;

/**
 地址标签 v2.4.0
 */
@property (nonatomic, strong) UIButton *addressTagView;

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
    
    // 摘要
    self.summaryLabel =
    ({
        UILabel *summaryLb = [[UILabel alloc] init];
        
        summaryLb.font = [UIFont boldSystemFontOfSize:13];
        summaryLb.textColor = DZSUIColorFromHex(0x4E4F57);
        summaryLb.numberOfLines = 2 ;
        summaryLb.text = @"";
        [self.contentView addSubview:summaryLb];
        
        [summaryLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(_authorLabel.mas_bottom).offset(23);
            make.right.equalTo(@-15);
        }];
        
        summaryLb;
    });
    self.summaryLabel.hidden = YES;
    
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
    
    // 地址Tag v2.4.0
    self.addressTagView = ({
        UIButton *addressTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressTagView setBackgroundColor:DZSUIColorFromHex(0xEAEDF2)];
        [addressTagView setTitle:@"地址" forState:UIControlStateNormal];
        [addressTagView setTitleColor:DZSUIColorFromHex(0x9A9CAA) forState:UIControlStateNormal];
        [addressTagView addTarget:self action:@selector(addressTagOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [addressTagView setImage:[UIImage BBSImageNamed:@"/LBS/LBS_min_icon.png"] forState:UIControlStateNormal];
        addressTagView.titleLabel.font = [UIFont systemFontOfSize:11];
        [addressTagView.layer setCornerRadius:2];
        [addressTagView.layer setMasksToBounds:YES];
        addressTagView.hidden = YES;
        // 光栅化
        addressTagView.layer.shouldRasterize = true;
        addressTagView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [addressTagView setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        [self.contentView addSubview:addressTagView];

        [addressTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.top.equalTo(_forumTagView.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];

        addressTagView ;
    });
    
    
    self.lineOrange =
    ({
        UIView *line = [UIView new];
        [self.contentView addSubview:line];
        line.backgroundColor = DZSUIColorFromHex(0xFFAA42);
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(6);
            make.size.mas_equalTo(CGSizeMake(2, 11));
        }];
        
        line;
    });
    self.lineOrange.hidden = YES;
    
    self.tipLabel =
    ({
        UILabel *label = [UILabel new];
        [self.contentView addSubview:label];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(@0);
            make.size.mas_equalTo(CGSizeMake(36, 18));
        }];
        label;
    }
    );
    self.tipLabel.hidden = YES;
    
    
    self.subjectLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 66;
    [self.subjectLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (void) setThreadModel:(BBSThread *)threadModel cellType:(BBSUIThreadSummaryCellType)cellType
{
    _cellType = cellType;
    _threadModel = threadModel ;
    
    NSInteger dateline;
    
    if (threadModel.dateline)
    {
        dateline = threadModel.dateline;
    }
    else
    {
        dateline = threadModel.createdOn;
    }
    
    if (cellType == BBSUIThreadSummaryCellTypePortal)
    {
        self.read = _threadModel.isSelected;
        _timeLabel.text = [NSString bbs_timeTextWithTimesStamp:dateline];
        _summaryLabel.textColor = DZSUIColorFromHex(0x9A9EA5);
        
        if (threadModel.pic)
        {
            _imagesView.hidden = NO;
            
            NSString * url = threadModel.pic;
            
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
            
        }else
        {
            _imagesView.hidden = YES;
        }
        
        _repliesLabel.text = [NSString stringWithFormat:@"评论 %lu",(long)_threadModel.commentnum];
        _viewsLabel.text = [NSString stringWithFormat:@"查看 %lu",(long)_threadModel.viewnum];
        
        // author和username长度截取
        if (_threadModel.author.length > 10) _threadModel.author = [_threadModel.author substringToIndex:10];
        if (_threadModel.username.length > 10) _threadModel.username = [_threadModel.username substringToIndex:10];
        
        _authorLabel.text = [NSString stringWithFormat:@"文:%@", (_threadModel.author && _threadModel.author.length > 0)?_threadModel.author : _threadModel.username];
        
        _authorLabel.font = [UIFont systemFontOfSize:10];
        _authorLabel.textColor = DZSUIColorFromHex(0xACADB8);
        _line.backgroundColor = DZSUIColorFromHex(0xACADB8);
        _summaryLabel.text = _threadModel.summary;
        
        [self _setCellFrame];
        
        return;
    }
    
    if (_threadModel.forumName)
    {
        _forumTagView.text = _threadModel.forumName;
        
    }
    
    if (cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        if (_threadModel.type && [_threadModel.type isEqualToString:@"portal"])
        {
            self.tipLabel.text = @"资讯";
            self.tipLabel.backgroundColor = DZSUIColorFromHex(0xffc6b7);
            _forumTagView.text = _threadModel.catname;
        }
        else
        {
            self.tipLabel.text = @"论坛";
            self.tipLabel.backgroundColor = DZSUIColorFromHex(0xb2ddfd);
        }
    }
    
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
    

    _timeLabel.text = [NSString bbs_timeTextWithTimesStamp:dateline];
    
    NSInteger imageCount = _threadModel.images.count ;
    
    if(imageCount || threadModel.pic)
    {
        _imagesView.hidden = NO;
        
        NSString * url = [_threadModel.images firstObject];
        if (!url)
        {
            url = threadModel.pic;
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
        
        
        if (imageCount > 1)
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
    
    if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid) {
        [_addressTagView setTitle:[NSString stringWithFormat:@" %@",_threadModel.poiTitle] forState:UIControlStateNormal];
        _addressTagView.hidden = NO;
    }else{
        _addressTagView.hidden = YES;
    }
    
    // 设置frame
    [self _setCellFrame];
    
    if ( (!_threadModel.author || _threadModel.author.length == 0) && _threadModel.tid)
    {
        _avatarImageView.image = [UIImage BBSImageNamed:@"/Thread/bbs_login_account.png"];
        _authorLabel.text = @"匿名用户";
    }
    
    
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
    
    NSString *title;
    NSString *content;
    
    if (_threadModel.aid)
    {
        title = _threadModel.title;
//        content =
    }
    else
    {
        title = _threadModel.subject;
    }
    
    _authorLabel.attributedText  = [NSString bbs_stringWithString:((!_threadModel.author || _threadModel.author.length == 0) && _threadModel.tid) ? @"匿名用户":_threadModel.author
                                                     fontSize:13
                                            defaultColorValue:@"8A8D94"
                                                    lineSpace:0
                                                    wordSpace:0];
    
    CGFloat fontSize = 16;
    if (_cellType == BBSUIThreadSummaryCellTypePortal)
    {
        fontSize = 18;
        _subjectLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    if (_read)
    {
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString bbs_stringWithString:title
                                                             fontSize:fontSize
                                                    defaultColorValue:@"ACADB8"
                                                            lineSpace:6
                                                            wordSpace:0];

        }else{
            if (_cellType == BBSUIThreadSummaryCellTypePortal)
            {
                _subjectLabel.attributedText = [self stringWithString:[self removeLastThreeChar:_threadModel.title] lineSpace:6];
            }else{
                _subjectLabel.attributedText = [self stringWithString:_threadModel.subject lineSpace:6];
            }
        
            _subjectLabel.textColor = DZSUIColorFromHex(0xACADB8);
        }
    }
    else
    {
        
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString bbs_stringWithString:title
                                                             fontSize:fontSize
                                                    defaultColorValue:@"4E4F57"
                                                            lineSpace:6
                                                            wordSpace:0];
            
        }else{
            
            if (_cellType == BBSUIThreadSummaryCellTypePortal)
            {
                _subjectLabel.attributedText = [self stringWithString:[self removeLastThreeChar:_threadModel.title] lineSpace:6];
            }else{
                _subjectLabel.attributedText = [self stringWithString:_threadModel.subject lineSpace:6];
            }
            _subjectLabel.textColor = DZSUIColorFromHex(0x4E4F57);
        }
    }
    
    if(_threadModel.aid)
    {
        if (_threadModel.title.length == 0) _subjectLabel.text = @" ";
    }
    else
    {
        if (_threadModel.subject.length == 0) _subjectLabel.text = @" ";
    }
}

- (NSString*) removeLastThreeChar:(NSString*)origin
{
    NSString* cutted;
    if([origin hasSuffix:@"..."]){
        cutted = [origin substringToIndex:([origin length]-3)];// 去掉最后一个","
    }else{
        cutted = origin;
    }
    return cutted;
}

- (void)_setCellFrame
{
    if (_cellType == BBSUIThreadSummaryCellTypeForums)
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
    
    if (_cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        _signView.hidden = NO;
        _forumTagView.hidden = YES;
        _repliesLabel.hidden = NO;
        _favoriteLabel.hidden = NO;
        _viewsLabel.hidden = NO;
        _tipLabel.hidden = NO;
        _avatarImageView.hidden = YES;
        _authorLabel.hidden = YES;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        
        [self _setSearchFrame];
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
    
    if (_cellType == BBSUIThreadSummaryCellTypePortal)
    {
        _signView.hidden = YES;
        _forumTagView.hidden = YES;
        _avatarImageView.hidden = YES;
        _authorLabel.hidden = NO;
        _repliesLabel.hidden = NO;
        _favoriteLabel.hidden = YES;
        _viewsLabel.hidden = NO;
        _lineOrange.hidden = NO;
        _summaryLabel.hidden = NO;
        _subjectLabel.hidden = NO;
        
        [self _setFrameForPortal];
    }
}

- (void)_setFrameHomePage
{
    CGFloat padding = 15;
    NSInteger imageCount = _threadModel.images.count ;
    
    CGFloat subjectlabelR;
    
    [_addressTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_subjectLabel);
        make.top.equalTo(_forumTagView.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    BOOL hasAddress = NO;
    if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid){
        hasAddress = YES;
    }
    
    if (imageCount > 0 && _threadModel.images)
    {
        _imagesView.hidden = NO;
        subjectlabelR = -140;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-padding));
            make.top.equalTo(@10).priorityHigh();
            make.bottom.equalTo(_line.mas_top).offset(hasAddress?-30:-10);
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
            make.bottom.equalTo(_line.mas_top).offset(hasAddress?-38:-18);
        }];
    }
    else
    {
        _imagesView.hidden = YES;
        subjectlabelR = -15;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-padding));
            make.top.equalTo(@10).priorityHigh();
            make.width.height.equalTo(@105);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(@10).priorityHigh();
            make.right.equalTo(@-15);
        }];
        
        [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(_line.mas_top).offset(hasAddress?-38:-18);
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
    
    [_addressTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_subjectLabel);
        make.top.equalTo(_viewsLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    BOOL hasAddress = NO;
    if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid){
        hasAddress = YES;
    }
    
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
            make.top.equalTo(_imagesView.mas_bottom).offset(hasAddress?39:19);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
            make.right.equalTo(_imagesView.mas_left).offset(-20);
        }];
        
        [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.bottom.equalTo(_line.mas_top).offset(hasAddress?-37:-17);
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
            make.height.equalTo(@10);
        }];
        
        [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).priorityHigh();
            make.height.mas_equalTo(3).priorityHigh();
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(_repliesLabel.mas_bottom).offset(hasAddress?37:17);
        }];
    }
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_authorLabel.mas_right).offset(8);
        make.centerY.equalTo(_authorLabel);
        make.height.equalTo(_authorLabel);
    }];
}

- (void)_setSearchFrame
{
    CGFloat padding = 15;
    NSInteger imageCount = _threadModel.images.count ;
    
    [_addressTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_subjectLabel);
        make.top.equalTo(_viewsLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    BOOL hasAddress = NO;
    if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid){
        hasAddress = YES;
    }
    
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
            make.top.equalTo(_imagesView.mas_bottom).offset(hasAddress?39:19);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(padding));
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
            make.right.equalTo(_imagesView.mas_left).offset(-20);
        }];
        
        [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.bottom.equalTo(_line.mas_top).offset(hasAddress?-37:-17);
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
            make.height.equalTo(@10);
        }];
        
        [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).priorityHigh();
            make.height.mas_equalTo(3).priorityHigh();
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(_repliesLabel.mas_bottom).offset(hasAddress?37:17);
        }];
    }
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
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


/**
 门户
 */
- (void)_setFrameForPortal
{
    if(_threadModel.pic)
    {
        _imagesView.hidden = NO;
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(@0);
            make.height.equalTo(@152);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(_imagesView.mas_bottom).offset(15);
            make.right.equalTo(@-15);
        }];
        
        
    }
    else
    {
        _imagesView.hidden = YES;

        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(@15);
            make.right.equalTo(@-15);
        }];
    }
    
    [_authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lineOrange.mas_right).offset(5);
        make.centerY.equalTo(_lineOrange);
        make.height.equalTo(@10);
    }];
    
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_authorLabel.mas_right).offset(14);
        make.centerY.equalTo(_lineOrange);
        make.height.equalTo(_authorLabel);
    }];
    
    [_viewsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-18);
        make.centerY.equalTo(_lineOrange);
        make.height.equalTo(_authorLabel);
    }];
    
    [_repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewsLabel.mas_left).offset(-15);
        make.centerY.equalTo(_lineOrange);
        make.height.equalTo(_authorLabel);
    }];
    
    [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 2));
        make.top.equalTo(_summaryLabel.mas_bottom).offset(25);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
    }];
    
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

#pragma mark - selector
- (void)addressTagOnClick:(id)sender
{
    if (_threadModel && _threadModel.poiTitle && ![_threadModel.poiTitle isEqualToString:@""]) {
        if (_addressOnClickBlock) {
            _addressOnClickBlock(_threadModel);
        }
    }
}

@end
