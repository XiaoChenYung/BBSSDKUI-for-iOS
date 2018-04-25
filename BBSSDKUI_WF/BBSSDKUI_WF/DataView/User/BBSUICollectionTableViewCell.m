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
#import "NSString+BBSUITime.h"
#import "BBSUILBSShowLocationViewController.h"

#define kImageWidth (([UIScreen mainScreen].bounds.size.width) * 80 / 375)

@interface BBSUICollectionTableViewCell ()

/**
 标题
 */
@property (nonatomic, strong) UILabel *summaryLabel;

/**
 摘要
 */
@property (nonatomic, strong) UILabel *contentLabel;

/**
 图片
 */
@property (nonatomic, strong) YYAnimatedImageView *imagesView;

/**
 灌水区
 */
@property (nonatomic, strong) UILabel *signLabel;

/**
 时间Label
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 回复数
 */
@property (nonatomic, strong) BBSUIViewsRepliesView *repliesLabel;

/**
 浏览数
 */
@property (nonatomic, strong) BBSUIViewsRepliesView *viewsLabel;

/**
 图片数
 */
@property (nonatomic, strong) UILabel *imageCountLabel;

/**
 地址标签 v2.4.0
 */
@property (nonatomic, strong) UIButton *addressTagView;

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
    //标题
    self.summaryLabel =
    ({
        UILabel *summaryLabel = [[UILabel alloc] init];
        summaryLabel.font = [UIFont systemFontOfSize:13];
        summaryLabel.textColor = DZSUIColorFromHex(0x3A4045);
        summaryLabel.numberOfLines = 2 ;
        summaryLabel.text = @"summaryContent" ;
        [self addSubview:summaryLabel];
 
        summaryLabel ;
    });
    
    // 摘要
    self.contentLabel =
    ({
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.textColor = DZSUIColorFromHex(0x787878);
        contentLabel.numberOfLines = 2 ;
        contentLabel.text = @"summaryContent" ;
        [self addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_summaryLabel);
            make.top.equalTo(_summaryLabel.mas_bottom).offset(5);
        }];
        
        contentLabel ;
    });
    
    //cell左侧图片
    self.imagesView =
    ({
        YYAnimatedImageView *imagesView = [[YYAnimatedImageView alloc] init];
        imagesView.contentMode = UIViewContentModeScaleAspectFill;
        imagesView.clipsToBounds = YES;
        imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [self addSubview:imagesView];
        imagesView ;
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
            make.top.equalTo(_imagesView);
        }];
        
        imageCountLabel;
    });
    
    // 灌水区
    self.signLabel =
    ({
        UILabel *signLabel = [UILabel new];
        signLabel.preferredMaxLayoutWidth = 100;
        [signLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        signLabel.font = [UIFont systemFontOfSize:10];
        signLabel.textColor = DZSUIColorFromHex(0xFFFFFF);
        signLabel.textAlignment = NSTextAlignmentCenter;
        
        signLabel.backgroundColor = DZSUIColorFromHex(0xDDE1EB);
        signLabel.layer.cornerRadius = 2;
        signLabel.layer.masksToBounds = YES;
        [self addSubview:signLabel];
        
        [_signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15).priorityHigh();
            make.bottom.equalTo(@-12).priorityHigh();
            make.height.equalTo(@15).priorityHigh();
            make.top.equalTo(self.contentLabel.mas_bottom).offset(13);
        }];
        
        signLabel;
    });
    
    self.repliesLabel =
    ({
        BBSUIViewsRepliesView *repliesView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeReplies];
        
        [self addSubview:repliesView];
//        [repliesView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.signLabel);
//            make.left.equalTo(_signLabel.mas_right).offset(0);
//            make.centerY.equalTo(_signLabel);
//        }];
        
        repliesView ;
    });
    
    self.viewsLabel =
    ({
        BBSUIViewsRepliesView *viewsView = [BBSUIViewsRepliesView viewWithType:BBSUIViewTypeViews];
        [self addSubview:viewsView];
        
        [viewsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.repliesLabel);
            make.left.equalTo(_repliesLabel.mas_right).offset(15);
            make.centerY.equalTo(_repliesLabel);
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
            make.left.equalTo(_viewsLabel.mas_right).offset(17);
            make.centerY.equalTo(_viewsLabel);
        }];
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
        [self addSubview:addressTagView];
        
        [addressTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_signLabel);
            make.top.equalTo(_signLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        addressTagView ;
    });
}

- (void)setCollection:(BBSThread *)collection{
    //collection.address = @"游族网络";
    _collection = collection;
    _summaryLabel.attributedText = [self stringWithString:collection.subject lineSpace:6];
    _contentLabel.attributedText = [self stringWithString:collection.summary lineSpace:3];
    
    _signLabel.text = [NSString stringWithFormat:@" %@  ",collection.forumName];
    
    [_repliesLabel setupWithCount:collection.replies style:BBSUIViewRepliesStyleImage];
    [_viewsLabel setupWithCount:collection.views style:BBSUIViewRepliesStyleImage];
    if (collection.images.count >= 2)
    {
        _imageCountLabel.hidden = NO;
        _imageCountLabel.text = [@"+" stringByAppendingFormat:@"%zd",collection.images.count];
    }
    else
    {
        _imageCountLabel.hidden = YES;
    }
    
    NSInteger timeOffset = [[NSDate date] timeIntervalSince1970] - collection.createdOn ;
    _timeLabel.text = [NSString bbs_timeTextWithOffset:timeOffset];
    
    if (collection.images.count > 0) {
        _imagesView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:collection.images.firstObject] result:^(NSData *imageData, NSError *error) {
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
    else{
        [self makeConstraintWithNoImageType];
    }
    

    if (_collection.poiTitle && _collection.poiTitle.length != 0 && _collection.tid)
    {
        _addressTagView.hidden = NO;
        [_addressTagView setTitle:[NSString stringWithFormat:@" %@",_collection.poiTitle] forState:UIControlStateNormal];
    }
    else
    {
        _addressTagView.hidden = YES;
    }
    
}

- (void)makeConstraintWithImageType
{
    if (self.collectionViewType == CollectionViewTypeOtherUserThreadList)
    {
        [self makeConstraintWithRightImage];
    }
    else
    {
        [self makeConstraintWithLeftImage];
    }
    
    NSInteger tmp_bottom = -12;
    if (_collection.poiTitle && _collection.poiTitle.length != 0 && _collection.tid)
    {
        tmp_bottom = -40;
    }
    [_signLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15).priorityHigh();
        make.bottom.equalTo(@(tmp_bottom)).priorityHigh();
        make.height.equalTo(@15).priorityHigh();
        make.top.equalTo(self.imagesView.mas_bottom).offset(13);
    }];
    
    if (_collectionViewType == CollectionViewTypeOtherUserThreadList) {
        self.signLabel.hidden = YES;
        [self.repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15).priorityHigh();
            //make.bottom.equalTo(@-12).priorityHigh();
            make.height.equalTo(@15).priorityHigh();
            make.top.equalTo(self.imagesView.mas_bottom).offset(13);
        }];
        
    }else{
        self.signLabel.hidden = NO;
        
        [self.repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.signLabel);
            make.left.equalTo(_signLabel.mas_right).offset(15);
            make.centerY.equalTo(_signLabel);
        }];
    }
}

- (void)makeConstraintWithLeftImage
{
    [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(15);
        make.width.equalTo(@(kImageWidth));
        make.height.equalTo(@(kImageWidth));
    }];
    
    [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imagesView.mas_right).offset(10);
        make.top.equalTo(_imagesView);
        make.right.equalTo(@-15);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(_viewsLabel);
    }];
    
    self.timeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)makeConstraintWithRightImage
{
    [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.width.equalTo(@(kImageWidth));
        make.height.equalTo(@(kImageWidth));
    }];
    
    [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_imagesView.mas_left).offset(-20);
        make.top.equalTo(_imagesView);
        make.left.equalTo(@15);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewsLabel.mas_right).offset(17);
        make.centerY.equalTo(_viewsLabel);
    }];
    
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)makeConstraintWithNoImageType
{
    [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(15);
        make.width.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    [_summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@15);
        make.right.equalTo(@-15);
    }];
    
    NSInteger tmp_bottom = -12;
    if (_collection.poiTitle && _collection.poiTitle.length != 0 && _collection.tid)
    {

        tmp_bottom = -40;
    }
    [_signLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15).priorityHigh();
        make.bottom.equalTo(@(tmp_bottom)).priorityHigh();
        make.height.equalTo(@15).priorityHigh();
        make.top.equalTo(self.contentLabel.mas_bottom).offset(13);
    }];
    
    if (_collectionViewType == CollectionViewTypeOtherUserThreadList) {
        self.signLabel.hidden = YES;
        [self.repliesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15).priorityHigh();
            //make.bottom.equalTo(@-12).priorityHigh();
            make.height.equalTo(@15).priorityHigh();
            make.top.equalTo(self.contentLabel.mas_bottom).offset(13);
        }];
        
    }else{
        self.signLabel.hidden = NO;
        
        [self.repliesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.signLabel);
            make.left.equalTo(_signLabel.mas_right).offset(15);
            make.centerY.equalTo(_signLabel);
        }];
    }
    
    if (self.collectionViewType == CollectionViewTypeOtherUserThreadList)
    {
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_viewsLabel.mas_right).offset(17);
            make.centerY.equalTo(_viewsLabel);
        }];
        
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(_viewsLabel);
        }];
        
        self.timeLabel.textAlignment = NSTextAlignmentRight;
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

#pragma mark - selector
- (void)addressTagOnClick:(id)sender
{
    if (_collection && _collection.poiTitle && ![_collection.poiTitle isEqualToString:@""]) {
        if (_addressOnClickBlock) {
            _addressOnClickBlock(_collection);
        }
    }
}

@end
