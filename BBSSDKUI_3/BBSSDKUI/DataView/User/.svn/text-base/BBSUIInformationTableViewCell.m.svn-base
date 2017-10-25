//
//  BBSUIInformationTableViewCell.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/17.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIInformationTableViewCell.h"
#import "Masonry.h"
#import <BBSSDK/BBSInformation.h>
#import "NSString+Paragraph.h"

@interface BBSUIInformationTableViewCell ()

/**
 icon图片
 */
@property (nonatomic, strong) UIImageView *iconImageView;

/**
 标题
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 时间
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 消息简介
 */
@property (nonatomic, strong) UILabel *summaryLabel;


@end

@implementation BBSUIInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI{
    self.backgroundColor = [UIColor whiteColor];
    
    /**
     icon图片
     */
    CGFloat iconWH = 30;
    self.iconImageView =
    ({
        UIImageView *iconImageView = [UIImageView new];
        [self addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(@15);
            make.width.height.mas_equalTo(iconWH);
        }];
        iconImageView.layer.cornerRadius = iconWH/2;
        iconImageView.layer.masksToBounds = YES;
        
        iconImageView;
    });
    
    /**
     小红点
     */
    self.redView =
    ({
        UIView *view = [UIView new];
        [self addSubview:view];
        view.backgroundColor = [UIColor redColor];
        CGFloat viewWH = 9;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.iconImageView.mas_right).offset(0);
            make.top.equalTo(self.iconImageView.mas_top).offset(0);
            make.width.height.mas_equalTo(viewWH);
        }];
        view.layer.cornerRadius = viewWH/2;
        view.layer.masksToBounds = YES;
        
        view;
    });
    
    /**
     时间
     */
    self.timeLabel =
    ({
        UILabel *timeLable = [UILabel new];
        timeLable.font = [UIFont systemFontOfSize:10];
        timeLable.textColor = DZSUIColorFromHex(0xABAFBA);
        timeLable.textAlignment = NSTextAlignmentRight;
        [self addSubview:timeLable];
        
        timeLable;
    });
    
    /**
     标题
     */
    self.titleLabel =
    ({
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = DZSUIColorFromHex(0x6A7081);
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(10);
            make.centerY.equalTo(self.timeLabel);
            make.height.equalTo(@12);
            make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        }];
        
        titleLabel;
    });
    
    /**
     消息简介
     */
    self.summaryLabel =
    ({
        UILabel *summaryLabel = [UILabel new];
        summaryLabel.font = [UIFont systemFontOfSize:14];
        summaryLabel.textColor = DZSUIColorFromHex(0x2D3037);
        summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:summaryLabel];

        summaryLabel;
    });
}

- (void)setInformation:(BBSInformation *)information{
    
    if ([information.type isEqualToString:@"mob_notice"] ||
        [information.type isEqualToString:@"system"]) {  // 系统广播 || 系统消息
        self.iconImageView.image = [UIImage BBSImageNamed:@"/Common/mob_notice.png"];
        [self makeConstraintWithNoSummary];
        
        self.titleLabel.attributedText = [NSString stringWithString:information.title fontSize:12 defaultColorValue:@"6A7081" lineSpace:0 wordSpace:0];
    }

    else if ([information.type isEqualToString:@"mob_like"]
             || [information.type isEqualToString:@"post"]
             || [information.type isEqualToString:@"mob_follow"])
    {    // 喜欢、点赞 || 评论、回复 || 关注
        
        self.iconImageView.image = [UIImage BBSImageNamed:@"/User/AvatarDefault3.png"];
        [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:information.avatar] result:^(NSData *imageData, NSError *error)
         {
             if (error)
             {
                 NSLog(@"——————%@",error);
                 return ;
             }
             
             UIImage *image = [UIImage imageWithData:imageData];
             self.iconImageView.image = image;
         }];
        
        NSString *title;
        
        if ([information.type isEqualToString:@"mob_like"])
        {
            [self makeConstraintWithSummary];
            title = [NSString stringWithFormat:@"<span style=\"color:%@\">%@</span>点赞了您的帖子<span style=\"color:%@\">%@</span>",@"12d9f0", information.author, @"12d9f0", information.note];
            
        }
        else if ([information.type isEqualToString:@"post"])
        {
            [self makeConstraintWithSummary];
            title = [NSString stringWithFormat:@"<span style=\"color:%@\">%@</span>回复了您的帖子<span style=\"color:%@\">%@</span>",@"12d9f0", information.author, @"12d9f0", information.note];
            
        }
        else
        {
            [self makeConstraintWithNoSummary];
            title = [NSString stringWithFormat:@"<span style=\"color:%@\">%@</span>关注了您",@"12d9f0", information.author];
        }

        self.titleLabel.attributedText = [NSString stringWithString:title fontSize:12 defaultColorValue:@"6A7081" lineSpace:0 wordSpace:0];
    }

    self.timeLabel.text = [self dataWithTimeStamp:information.dateline];
    self.summaryLabel.text = information.note;
    
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if (information.isnew.integerValue == 0) self.redView.hidden = YES;
    else    self.redView.hidden = NO;
}

- (void)makeConstraintWithSummary{
    self.summaryLabel.hidden = NO;
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
        make.right.equalTo(@-15);
        make.width.equalTo(@60);
        make.height.equalTo(@12);
    }];
    [self.summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.right.equalTo(@-15);
        make.height.equalTo(@14);
    }];
}

- (void)makeConstraintWithNoSummary{
    self.summaryLabel.hidden = YES;
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.right.equalTo(@-15);
        make.width.equalTo(@60);
        make.height.equalTo(@12);
    }];
    [self.summaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.right.equalTo(@-15);
        make.height.equalTo(@0);
    }];
}


- (NSString *)dataWithTimeStamp:(NSInteger)timeStamp {
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"YYYY-MM-dd"];
    //以 1970/01/01 GMT为基准，然后过了secs秒的时间
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString *date = [stampFormatter stringFromDate:stampDate];
    
    return date;
}

@end






