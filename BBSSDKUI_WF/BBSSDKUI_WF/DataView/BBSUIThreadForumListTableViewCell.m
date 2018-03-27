//
//  BBSUIThreadForumListTableViewCell.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadForumListTableViewCell.h"
#import "Masonry.h"
#import "BBSUIMacro.h"
#import <BBSSDK/BBSForum.h>
#import "UIImage+BBSFunction.h"

@interface BBSUIThreadForumListTableViewCell()

@property (nonatomic, strong) UIImageView *forumImageView;
@property (nonatomic, strong) UILabel *forumNameLabel ;

@end

@implementation BBSUIThreadForumListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self configUI];
    }
    return self ;
}

- (void)configUI
{
    self.forumImageView =
    ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:@"/Common/forumList.png"]];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(9);
            make.height.width.equalTo(@40);
        }];
        imageView;
    });

    self.forumNameLabel =
    ({
        UILabel *forumNameLabel = [[UILabel alloc] init];
        forumNameLabel.text = @"forumName";
        forumNameLabel.textColor = DZSUIColorFromHex(0x3A4045);
        forumNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:forumNameLabel];
        [forumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_forumImageView.mas_right).offset(15);
            make.centerY.equalTo(_forumImageView);
        }];
        forumNameLabel ;
    });
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor darkGrayColor];
    line.alpha = 0.1;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_forumNameLabel);
        make.right.bottom.equalTo(self);
        make.height.equalTo(@1);
    }];
}

- (void)setModel:(BBSForum *)model
{
    _model = model ;
    
    _forumNameLabel.text = model.name;
    
    __weak typeof(self) theCell = self;
    if (_model.forumPic) {
        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:_model.forumPic] result:^(UIImage *image, NSError *error) {
            if (error) {
                theCell.forumImageView.image = [UIImage BBSImageNamed:@"/Common/forumList.png"];
            }else{
                theCell.forumImageView.image = image;
            }
            
        }];
    }else{
        self.forumImageView.image = [UIImage BBSImageNamed:@"/Common/forumList.png"];
    }
}

@end
