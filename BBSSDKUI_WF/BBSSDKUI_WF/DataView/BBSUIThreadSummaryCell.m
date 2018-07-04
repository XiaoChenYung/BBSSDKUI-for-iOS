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

/**
 分割线
 */
@property (nonatomic, strong) UIView *line;

/**
 竖分割线
 */
@property (nonatomic, strong) UIView *verticalLine;

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
    CGFloat padding = 15;
    
    //头像
    self.avatarImageView =
    ({
        UIImage *placeholdImage = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:placeholdImage];
        avatarImageView.layer.cornerRadius = 10;
        avatarImageView.layer.masksToBounds = YES;
        // 光栅化
        avatarImageView.layer.shouldRasterize = true;
        avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        [self.contentView addSubview:avatarImageView];
        
        avatarImageView.frame = CGRectMake(padding, padding, 20, 20);
        
        avatarImageView ;
    });
    
    //作者名
    self.authorLabel =
    ({
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.font = [UIFont systemFontOfSize:13];
        authorLabel.textColor = DZSUIColorFromHex(0x8A8D94);
        [self.contentView addSubview:authorLabel];
        
        authorLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame)+10, CGRectGetMinY(_avatarImageView.frame), DZSUIScreen_width - CGRectGetMinX(_avatarImageView.frame) - 25, CGRectGetHeight(_avatarImageView.frame));
        
        authorLabel ;
    });
    
    //cell右侧图片
    self.imagesView =
    ({
        CGFloat imagesViewWH = 80;
        
        YYAnimatedImageView *imagesView = [[YYAnimatedImageView alloc] init];
        imagesView.contentMode = UIViewContentModeScaleAspectFill;
        imagesView.clipsToBounds = YES;
        imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [self.contentView addSubview:imagesView];
        
        imagesView.frame = CGRectMake(DZSUIScreen_width-imagesViewWH-padding, 46, imagesViewWH, imagesViewWH);
        
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
//        subjectLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:subjectLabel];
        
        [subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.top.equalTo(self.contentView).offset(44);
            make.right.equalTo(_imagesView.mas_left).offset(-15);
            //            make.height.equalTo(@30);
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
        [self.contentView addSubview:summaryLabel];
        
        // ??????????
//        summaryLabel.preferredMaxLayoutWidth = (self.frame.size.width -10.0 * 2);
//        [summaryLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];//
//        [summaryLabel setContentHuggingPriority:UILayoutPriorityRequired/*抱紧*/
//                                    forAxis:UILayoutConstraintAxisHorizontal];
//        [summaryLabel setContentHuggingPriority:UILayoutPriorityRequiredforAxis:UILayoutConstraintAxisVertical];
        
        [summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(5);
            make.right.equalTo(@-15);
        }];
        
        summaryLabel ;
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
    
    self.forumTagView =
    ({
        UIButton *forumTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        [forumTagView setBackgroundColor:DZSUIColorFromHex(0x9DB9FF)];//DDE1EB
        [forumTagView setTitle:@"版块" forState:UIControlStateNormal];
        [forumTagView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        forumTagView.titleLabel.font = [UIFont systemFontOfSize:11];
        [forumTagView.layer setCornerRadius:2];
        [forumTagView.layer setMasksToBounds:YES];
        // 光栅化
        forumTagView.layer.shouldRasterize = true;
        forumTagView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [forumTagView setContentEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        [self.contentView addSubview:forumTagView];
        
        [forumTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_summaryLabel);
            make.top.equalTo(_imagesView.mas_bottom).offset(10);
            //        make.top.equalTo(self).offset(46+kImageWidth+7);
            //            make.bottom.equalTo(_line.mas_top).offset(-10).priorityHigh();
            make.height.mas_equalTo(17);
        }];
        
        forumTagView ;
    });
    
    self.signView =
    ({
        BBSUIThreadTypeSignView *signView = [[BBSUIThreadTypeSignView alloc] init];
        
        [self.contentView addSubview:signView];
        
        signView ;
    });
    
    // 回复数view
    self.repliesView =
    ({
        BBSUIViewsRepliesView *repliesView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeReplies];
        
        [self.contentView addSubview:repliesView];
        [repliesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_forumTagView);
            make.left.equalTo(_forumTagView.mas_right).offset(0);
            make.centerY.equalTo(_forumTagView);
        }];
        
        repliesView ;
    });
    
    // 浏览数view
    self.viewsView =
    ({
        BBSUIViewsRepliesView *viewsView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeViews];
        
        [self.contentView addSubview:viewsView];
        [viewsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_forumTagView);
            make.left.equalTo(_repliesView.mas_right).offset(15);
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
        [self.contentView addSubview:timeLabel];
        
        timeLabel.frame = CGRectMake(CGRectGetMaxX(_viewsView.frame)+15, CGRectGetMinY(_forumTagView.frame), 150, CGRectGetHeight(_forumTagView.frame));
        
        timeLabel ;
    });
    
    // 地址Tag v2.4.0
    self.addressTagView = ({
        UIButton *addressTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressTagView setBackgroundColor:DZSUIColorFromHex(0xEAEDF2)];
        [addressTagView setTitle:@"地址" forState:UIControlStateNormal];
        [addressTagView setTitleColor:DZSUIColorFromHex(0x9A9CAA) forState:UIControlStateNormal];
        [addressTagView setImage:[UIImage BBSImageNamed:@"/LBS/LBS_min_icon.png"] forState:UIControlStateNormal];
        [addressTagView addTarget:self action:@selector(addressTagOnClick:) forControlEvents:UIControlEventTouchUpInside];
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
            make.left.equalTo(_summaryLabel);
            make.top.equalTo(_repliesView.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        addressTagView ;
    });
    
    // 横线
    _line = [[UIView alloc] init];
    _line.backgroundColor = DZSUIColorFromHex(0xF9F9F9);
    //    _line.alpha = 0.075;
    [self.contentView addSubview:_line];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).priorityHigh();
        make.height.mas_equalTo(1).priorityHigh();
        make.top.equalTo(_repliesView.mas_bottom).offset(10).priorityHigh();
        make.left.bottom.equalTo(self.contentView);
    }];
    
    // 竖线
    _verticalLine = [[UIView alloc] init];
    _verticalLine.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
    [self.contentView addSubview:_verticalLine];
    [_verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_authorLabel.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(1, 11));
        make.centerY.equalTo(_authorLabel);
    }];
    
    _verticalLine.hidden = YES;
    
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
    });
    self.tipLabel.hidden = YES;
    
    self.subjectLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 66;
//    self.summaryLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20;
}

#pragma mark - cell赋值

- (void) setThreadModel:(BBSThread *)threadModel
{
    //threadModel.address = @"游族网络";
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
    
    if (_cellType == BBSUIThreadSummaryCellTypePortal)
    {
        self.read = _threadModel.isSelected;
        _timeLabel.text = [NSString bbs_timeTextWithTimesStamp:dateline];
        [_repliesView setupWithCount:_threadModel.commentnum style:BBSUIViewRepliesStyleImage];
        [_viewsView setupWithCount:_threadModel.viewnum style:BBSUIViewRepliesStyleImage];
        
        if(threadModel.pic)
        {
            NSString * url = _threadModel.pic;
            
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
            
            [self makeConstraintWithImageType];
        }
        else
        {
            [self makeConstraintWithNoImageType];
        }
        
        return;
    }
    
    if (_threadModel.forumName)
    {
        _forumTagView.hidden = NO;
        [_forumTagView setTitle:[NSString stringWithFormat:@" %@ ",_threadModel.forumName] forState:UIControlStateNormal];
    }
    
    if (_cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        if (_threadModel.type && [_threadModel.type isEqualToString:@"portal"])
        {
            self.tipLabel.text = @"资讯";
            self.tipLabel.backgroundColor = DZSUIColorFromHex(0xffc6b7);
            [_forumTagView setTitle:[NSString stringWithFormat:@" %@ ",_threadModel.catname] forState:UIControlStateNormal];
        }
        else
        {
            self.tipLabel.text = @"论坛";
            self.tipLabel.backgroundColor = DZSUIColorFromHex(0xb2ddfd);
        }
    }
    
    if ( (!_threadModel.author || _threadModel.author.length == 0) && _threadModel.tid)
    {
        _avatarImageView.image = [UIImage BBSImageNamed:@"/Thread/bbs_login_account.png"];
    }
    else
    {
        _avatarImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault.png"];
        
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:_threadModel.avatar] result:^(NSData *imageData, NSError *error) {
            if (error)
            {
                NSLog(@"%@",error);
                return ;
            }
            UIImage *image = [UIImage imageWithData:imageData];
            
            //        [weadSelf setImageWithImage:image inView:_avatarImageView];
            _avatarImageView.image = image;
        }];
    }
    
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
        
        [self makeConstraintWithImageType];
        
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
        _imageCountLabel.hidden = YES;
        
        [self makeConstraintWithNoImageType];
    }
    
    if ( (!_threadModel.author || _threadModel.author.length == 0) && _threadModel.tid)
    {
        NSLog(@"0000000000000m  %@ -- %lu  %@",_threadModel.author, _threadModel.tid, _threadModel.subject);
        _avatarImageView.image = [UIImage BBSImageNamed:@"/Thread/bbs_login_account.png"];
        _authorLabel.text = @"匿名用户";
    }
    
    if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid) {
        [_addressTagView setTitle:[NSString stringWithFormat:@" %@",_threadModel.poiTitle] forState:UIControlStateNormal];
        _addressTagView.hidden = NO;
    }else{
        _addressTagView.hidden = YES;
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

- (void)makeConstraintWithImageType
{
    if (_cellType == BBSUIThreadSummaryCellTypePortal)
    {
        // ?????????????
//        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.top.equalTo(@15);
//            make.right.equalTo(@-15);
//        }];
//
//        [_authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_subjectLabel);
//            make.top.equalTo(_subjectLabel.mas_bottom).offset(12);
//            make.height.equalTo(@10);
//        }];
//
//        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_verticalLine.mas_right).offset(10);
//            make.centerY.equalTo(_authorLabel);
//            make.height.equalTo(@10);
//        }];
//
//        [_viewsView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(@-20);
//            make.centerY.equalTo(_authorLabel);
//            make.height.equalTo(@15);
//        }];
//
//        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(_viewsView.mas_left).offset(-13);
//            make.height.equalTo(_viewsView);
//            make.centerY.equalTo(_viewsView);
//        }];
//
//        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(@0);
//            make.top.equalTo(_authorLabel.mas_bottom).offset(13);
//            make.height.equalTo(@120);
//        }];
//
//        [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_authorLabel);
//            make.top.equalTo(_imagesView.mas_bottom).offset(15);
//            make.right.equalTo(@-15);
//        }];
//
//        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self.contentView);
//            make.height.mas_equalTo(4.5);
//            make.top.equalTo(_summaryLabel.mas_bottom).offset(15.5);
//            make.bottom.equalTo(self.contentView).priorityHigh();
//        }];
        
        
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@15);
            make.right.equalTo(@-15);
        }];
        
        [_authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(12);
            make.height.equalTo(@10);
        }];
        
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_verticalLine.mas_right).offset(10);
            make.centerY.equalTo(_authorLabel);
            make.height.equalTo(@10);
        }];
        
        [_viewsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-20);
            make.centerY.equalTo(_authorLabel);
            make.height.equalTo(@15);
        }];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_viewsView.mas_left).offset(-13);
            make.height.equalTo(_viewsView);
            make.centerY.equalTo(_viewsView);
        }];
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_authorLabel.mas_bottom).offset(13);
            make.left.right.equalTo(@0);
            make.height.equalTo(@120);
        }];
        
        [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_authorLabel);
            make.top.equalTo(_imagesView.mas_bottom).offset(15);
            make.right.equalTo(@-15);
        }];
        
        [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(4.5);
            make.top.equalTo(_summaryLabel.mas_bottom).offset(15.5);
            make.bottom.equalTo(self.contentView).priorityHigh();
        }];
        
    }
    
    else
    {
        CGFloat imageWH = 80;
        
        if (_cellType == BBSUIThreadSummaryCellTypeSearch)
        {
            [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.top.equalTo(@15);
                make.width.equalTo(@120);
                make.height.equalTo(@17);
            }];
        }
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(46);
            make.right.equalTo(self.contentView).offset(-15);
            make.width.equalTo(@(imageWH));
            make.height.equalTo(@(imageWH));
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView);
            make.top.equalTo(self.contentView).offset(44);
            make.right.equalTo(_imagesView.mas_left).offset(-15);
        }];
        
        [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(5);
            make.right.equalTo(_imagesView.mas_left).offset(-10);
        }];
        
        [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_summaryLabel);
            make.top.equalTo(_imagesView.mas_bottom).offset(10);
            //        make.top.equalTo(self).offset(46+kImageWidth+7);
            //        make.bottom.equalTo(_line.mas_top).offset(-10).priorityHigh();
            make.height.mas_equalTo(16);
        }];
        
        [_signView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-15);
            make.centerY.equalTo(_forumTagView);
        }];
        

        // 地址的展示
        if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid) {
            [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView).priorityHigh();
                make.height.mas_equalTo(1).priorityHigh();
                make.top.equalTo(_addressTagView.mas_bottom).offset(10).priorityHigh();
                make.left.bottom.equalTo(self.contentView);
            }];
        }else{
            [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView).priorityHigh();
                make.height.mas_equalTo(1).priorityHigh();
                make.top.equalTo(_repliesView.mas_bottom).offset(10).priorityHigh();
                make.left.bottom.equalTo(self.contentView);
            }];
        }
        
    }
}

- (void)makeConstraintWithNoImageType
{
    if (_cellType == BBSUIThreadSummaryCellTypePortal)
    {
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@15);
            make.right.equalTo(@-15);
        }];
        
        [_authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(12);
            make.height.equalTo(@10);
        }];
        
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_verticalLine.mas_right).offset(10);
            make.centerY.equalTo(_authorLabel);
            make.height.equalTo(@10);
        }];
        
        [_viewsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-20);
            make.centerY.equalTo(_authorLabel);
            make.height.equalTo(@15);
        }];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_viewsView.mas_left).offset(-13);
            make.height.equalTo(_viewsView);
            make.centerY.equalTo(_viewsView);
        }];
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(46);
            make.right.equalTo(self.contentView).offset(-15).priorityHigh();
            make.width.equalTo(@0);
            make.height.equalTo(@0);
        }];
        
        [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_authorLabel);
            make.top.equalTo(_authorLabel.mas_bottom).offset(13);
            make.right.equalTo(@-15);
        }];
        
        [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(4.5).priorityHigh();
            make.top.equalTo(_summaryLabel.mas_bottom).offset(15.5);
            make.bottom.equalTo(self.contentView).priorityHigh();
        }];
        
    }
    else
    {
        if (_cellType == BBSUIThreadSummaryCellTypeSearch)
        {
            [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.top.equalTo(@15);
                make.width.equalTo(@120);
                make.height.equalTo(@17);
            }];
        }
        
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(46);
            make.right.equalTo(self.contentView).offset(-15).priorityHigh();
            make.width.equalTo(@0);
            make.height.equalTo(@0);
        }];
        
        [_subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView).priorityHigh();
            make.top.equalTo(self.contentView).offset(44);
            make.right.equalTo(_imagesView.mas_left);
        }];
        
        [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_subjectLabel);
            make.top.equalTo(_subjectLabel.mas_bottom).offset(5);
            make.right.equalTo(@-15);
        }];
        
        [_forumTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_summaryLabel);
            make.top.equalTo(_summaryLabel.mas_bottom).offset(10).priorityHigh();
            make.height.mas_equalTo(16);
        }];
        
        [_signView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-15);
            make.centerY.equalTo(_forumTagView);
        }];
        
        // 地址的展示
        if (_threadModel.poiTitle && _threadModel.poiTitle.length !=0 && _threadModel.tid) {
            [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView).priorityHigh();
                make.height.mas_equalTo(1).priorityHigh();
                make.top.equalTo(_addressTagView.mas_bottom).offset(10).priorityHigh();
                make.left.bottom.equalTo(self.contentView);
            }];
        }else{
            [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView).priorityHigh();
                make.height.mas_equalTo(1).priorityHigh();
                make.top.equalTo(_repliesView.mas_bottom).offset(10).priorityHigh();
                make.left.bottom.equalTo(self.contentView);
            }];
        }
    }
    
}

- (void)setRead:(BOOL)read
{
    _read = read;
    NSString *title;
    NSString *content;

    if (_threadModel.aid)
    {
        title = _threadModel.title;
        content = _threadModel.summary;
        [_forumTagView setTitle:[NSString stringWithFormat:@" %@ ",_threadModel.catname] forState:UIControlStateNormal];
        
        NSLog(@"--%@----vvv---setRead-%ld", _threadModel, (long)_threadModel.viewnum);

        [_viewsView setupWithCount:_threadModel.viewnum style:BBSUIViewRepliesStyleImage];
        [_repliesView setupWithCount:_threadModel.commentnum style:BBSUIViewRepliesStyleImage];
    }
    else if (_cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        title = _threadModel.subject;
        content = _threadModel.message;
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleImage];
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleImage];
    }
    else
    {
        title = _threadModel.subject;
        content = _threadModel.summary;
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleImage];
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleImage];
    }
    if (content.length == 0 || !content)
    {
        content = @" ";
    }
    
    if (_threadModel.aid) {
        // author和username长度截取
        if (_threadModel.author.length > 10) _threadModel.author = [_threadModel.author substringToIndex:10];
        if (_threadModel.username.length > 10) _threadModel.username = [_threadModel.username substringToIndex:10];
        _authorLabel.text = [NSString stringWithFormat:@"文:%@", (_threadModel.author && _threadModel.author.length > 0)?_threadModel.author : _threadModel.username];
    }
    else
    {
        NSLog(@"0000000000000m  %@ -- %@",_threadModel.author, _threadModel.subject);
        _authorLabel.attributedText  = [NSString bbs_stringWithString:(_threadModel.author && _threadModel.author.length) ? _threadModel.author:@"匿名用户"
                                                         fontSize:13
                                                defaultColorValue:@"8A8D94"
                                                        lineSpace:0
                                                        wordSpace:0];
        
        
    }
    
//    if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
//        content = _threadModel.message;
//    }else{
//        content = _threadModel.summary;
//    }
    
    
    if (_read)
    {
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString bbs_stringWithString:title
                                                             fontSize:16
                                                    defaultColorValue:@"A5A7A8"
                                                            lineSpace:6
                                                            wordSpace:0];
            
            _summaryLabel.attributedText = [NSString bbs_stringWithString:content
                                                             fontSize:13
                                                    defaultColorValue:@"9A9EA5"
                                                            lineSpace:3
                                                            wordSpace:0];
        }
        else
        {
            if (_cellType == BBSUIThreadSummaryCellTypePortal)
            {
                _subjectLabel.attributedText = [self stringWithString:[self removeLastThreeChar:_threadModel.title] lineSpace:6];
            }else{
                _subjectLabel.attributedText = [self stringWithString:title lineSpace:6];
            }
            
            _summaryLabel.attributedText = [self stringWithString:content lineSpace:3];
            _subjectLabel.textColor = DZSUIColorFromHex(0xA5A7A8);
            _summaryLabel.textColor = DZSUIColorFromHex(0x9A9EA5);
        }
        
    }
    else
    {
        
        if (_cellType == BBSUIThreadSummaryCellTypeSearch) {
            _subjectLabel.attributedText = [NSString bbs_stringWithString:title
                                                             fontSize:16
                                                    defaultColorValue:@"3A4045"
                                                            lineSpace:6
                                                            wordSpace:0];
            
            _summaryLabel.attributedText = [NSString bbs_stringWithString:content
                                                             fontSize:13
                                                    defaultColorValue:@"9A9EA5"
                                                            lineSpace:3
                                                            wordSpace:0];
        }
        else
        {
            if (_cellType == BBSUIThreadSummaryCellTypePortal)
            {
                //html语言转成字符串
                _subjectLabel.attributedText = [self stringWithString:[self removeLastThreeChar:_threadModel.title] lineSpace:6];
            }
            else
            {
                _subjectLabel.attributedText = [self stringWithString:title lineSpace:6];
            }
            
            if ([content containsString:@"&quot;"]) {
                content = [content stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
            }
            _summaryLabel.attributedText = [self stringWithString:content lineSpace:3];
            _subjectLabel.textColor = DZSUIColorFromHex(0x3A4045);
            _summaryLabel.textColor = DZSUIColorFromHex(0x9A9EA5);
        }
    }
    _summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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

- (void)setCellType:(BBSUIThreadSummaryCellType)cellType
{
    _cellType = cellType;
    
    if (cellType == BBSUIThreadSummaryCellTypeForums)
    {
        _signView.hidden = NO;
        _forumTagView.hidden = YES;
        _timeLabel.hidden = NO;
        _subjectLabel.font = [UIFont boldSystemFontOfSize:16];
        
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleCharacters];
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleCharacters];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(_forumTagView);
        }];
        
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_viewsView.mas_right).offset(15);
            make.top.bottom.equalTo(_viewsView);
            make.width.equalTo(@120);
        }];
        
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    else if (cellType == BBSUIThreadSummaryCellTypePortal) {
        _signView.hidden = YES;
        _forumTagView.hidden = YES;
        _timeLabel.hidden = NO;
        _avatarImageView.hidden = YES;
        _verticalLine.hidden = NO;
        _imageCountLabel.hidden = YES;
        _subjectLabel.hidden = NO;
        _viewsView.hidden = NO;
        _repliesView.hidden = NO;
        
        _subjectLabel.font = [UIFont boldSystemFontOfSize:18];
        _authorLabel.font = [UIFont systemFontOfSize:10];
        _authorLabel.textColor = DZSUIColorFromHex(0x9A9CAA);
        _line.backgroundColor = DZSUIColorFromHex(0xEAEDF2);
    }
    
    else
    {
        _signView.hidden = YES;
        _forumTagView.hidden = NO;
        _timeLabel.hidden = YES;
        
        _subjectLabel.font = [UIFont boldSystemFontOfSize:16];
        
        [_repliesView setupWithCount:_threadModel.replies style:BBSUIViewRepliesStyleImage];
        
        NSLog(@"--%@----vvv----%ld", _threadModel, (long)_threadModel.views);
        
        
        [_viewsView setupWithCount:_threadModel.views style:BBSUIViewRepliesStyleImage];
        
        [_repliesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_forumTagView.mas_right).offset(23);
            make.centerY.equalTo(_forumTagView);
        }];
    }
    //MARK:--关注  浏览记录 cell
    if (cellType == BBSUIThreadSummaryCellTypeHistory || cellType == BBSUIThreadSummaryCellTypeAttion)
    {
        _timeLabel.hidden = NO;
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.top.bottom.equalTo(_viewsView);
            make.width.equalTo(@120);
        }];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    
    if (_cellType == BBSUIThreadSummaryCellTypeSearch)
    {
        _tipLabel.hidden = NO;
        _avatarImageView.hidden = YES;
        _authorLabel.hidden = YES;
        _timeLabel.hidden = NO;
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
