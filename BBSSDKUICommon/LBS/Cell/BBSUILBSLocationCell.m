//
//  BBSUILBSLocationCell.m
//  BBSLBSPro
//
//  Created by wukx on 2018/4/4.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUILBSLocationCell.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "UIImage+BBSFunction.h"

@interface BBSUILBSLocationCell()

@property (strong, nonatomic) UILabel *namelabel;
@property (strong, nonatomic) UILabel *addresslabel;
@property (strong, nonatomic) UIImageView *checkImageView;

@end

@implementation BBSUILBSLocationCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        if (!_namelabel) {
            _namelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, screenWidth-15-30, 28)];
            _namelabel.textColor = [UIColor blackColor];
            _namelabel.font = [UIFont systemFontOfSize:16.0];
            [self.contentView addSubview:_namelabel];
        }
        if (!_addresslabel) {
            _addresslabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_namelabel.frame), screenWidth-15-30, 15)];
            _addresslabel.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
            _addresslabel.font = [UIFont systemFontOfSize:12.0];
            [self.contentView addSubview:_addresslabel];
        }
        if (!_checkImageView) {
            _checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-15-13, ([BBSUILBSLocationCell cellHeight] - 10)/2.0 , 13, 10)];
            _checkImageView.image = [UIImage BBSImageNamed:@"/LBS/okBlueIcon@2x.png"];
            _checkImageView.hidden = YES;
            [self.contentView addSubview:_checkImageView];
        }
        //self.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 60.0;
}

+ (NSString *)getID{
    return @"BBSUILBSLocationCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCheck:(BOOL)check{
    self.checkImageView.hidden = !check;
}

- (void)configureForData:(AMapPOI *)data{
    if (data == nil) {
        self.namelabel.text = @"不显示位置";
        self.addresslabel.text = @"";
        return;
    }
    self.namelabel.text = data.name;
    self.addresslabel.text = data.address;
}
- (void)configureForData:(AMapPOI *)data keyword:(NSString *)keyword{
    [self configureForData:data];
    if (keyword && ![keyword isEqualToString:@""]) {
        self.namelabel.attributedText = [self highlightKeyword:keyword origintext:data.name];
        self.addresslabel.attributedText = [self highlightKeyword:keyword origintext:data.address];
    }
}
- (NSMutableAttributedString *)highlightKeyword:(NSString *)keyword origintext:(NSString *)origintext{
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:origintext];
    NSMutableArray *indexArray = @[].mutableCopy;
    for(int i =0; i < [origintext length]; i++)
    {
        NSString *temp = [origintext substringWithRange:NSMakeRange(i,1)];
        if ([keyword containsString:temp]) {
            [indexArray addObject:[NSValue valueWithRange:NSMakeRange(i, 1)]];
        }
    }
    
    [indexArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:23/255.0f green:182/255.0f blue:0 alpha:1] range:range];
    }];
    return attributeStr;
}

@end
