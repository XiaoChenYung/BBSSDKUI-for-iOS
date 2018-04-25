//
//  BBSUILBSNotLocationCell.m
//  BBSLBSPro
//
//  Created by wukexiu on 2018/4/4.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUILBSNotLocationCell.h"
#import "UIImage+BBSFunction.h"

@interface BBSUILBSNotLocationCell()

@property (strong, nonatomic) UILabel *titlelabel;
@property (strong, nonatomic) UIImageView *checkImageView;

@end

@implementation BBSUILBSNotLocationCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        if (!_titlelabel) {
            _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, ([BBSUILBSNotLocationCell cellHeight] - 28)/2.0, screenWidth-15-30, 28)];
            _titlelabel.textColor = [UIColor colorWithRed:14.0/255.0 green:134.0/255.0 blue:255.0/255.0 alpha:1.0];
            _titlelabel.font = [UIFont systemFontOfSize:16.0];
            [self.contentView addSubview:_titlelabel];
        }
        if (!_checkImageView) {
            _checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-15-13, ([BBSUILBSNotLocationCell cellHeight] - 10)/2.0 , 13, 10)];
            _checkImageView.image = [UIImage BBSImageNamed:@"/LBS/okBlueIcon@2x.png"];
            _checkImageView.hidden = YES;
            [self.contentView addSubview:_checkImageView];
        }
        //self.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 52;
}

+ (NSString *)getID{
    return @"BBSUILBSNotLocationCell";
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

- (void)configureForTitle:(NSString *)title{
    self.titlelabel.text = title;
}

@end
