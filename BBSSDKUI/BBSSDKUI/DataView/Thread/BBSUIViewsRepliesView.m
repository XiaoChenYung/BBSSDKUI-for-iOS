//
//  BBSUIViewsRepliesView.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIViewsRepliesView.h"
#import "Masonry.h"
#import "BBSUIMacro.h"
#import "UIImage+BBSFunction.h"

@interface BBSUIViewsRepliesView()

@property (nonatomic, assign) BBSUIViewType type;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *countLabel ;

@end

@implementation BBSUIViewsRepliesView

+ (instancetype)viewWithType:(BBSUIViewType)type
{
    BBSUIViewsRepliesView * view = [[self alloc] init];
    view.type = type;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self configUI];
    }
    return self ;
}

- (void)configUI
{
    self.imageView =
    ({
        UIImage *image = [UIImage BBSImageNamed:_type?@"回复b":@"views"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.right.equalTo(self.mas_centerX);
        }];
        imageView ;
    });
    
    self.countLabel =
    ({
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.font = [UIFont systemFontOfSize:11];
        countLabel.textColor = DZSUIColorFromHex(0xB4B4B4);
        countLabel.text = @"0" ;
        [self addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self);
            make.left.equalTo(self.mas_centerX);
        }];
        
        countLabel ;
    });
}

- (void)setCount:(NSInteger)count
{
    _count = count ;
    
    _countLabel.text = [NSString stringWithFormat:@"%zd",count];
}

@end
