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

@end

@implementation BBSUIViewsRepliesView

+ (instancetype)viewWithType:(BBSUIViewType)type
{
    BBSUIViewsRepliesView * view = [[self alloc] init];
    view.type = type;
    return view;
}

- (void)setupWithCount:(NSInteger)count style:(BBSUIViewRepliesStyle)style
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (style == BBSUIViewRepliesStyleImage)
    {
        UIImage *image = [UIImage BBSImageNamed:_type?@"/Home/thread_reply@2x.png":@"/Home/thread_see.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(16);
        }];
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.font = [UIFont systemFontOfSize:11];
        countLabel.textColor = DZSUIColorFromHex(0xB4B4B4);
        countLabel.text = [NSString stringWithFormat:@"%zd",count] ;
        [self addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(imageView);
            make.left.equalTo(imageView.mas_right);
            make.right.equalTo(self);
        }];
    }
    else
    {
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.font = [UIFont systemFontOfSize:11];
        countLabel.textColor = DZSUIColorFromHex(0xB4B4B4);
        
        NSString *text = _type?@"评论":@"查看";
        countLabel.text = [NSString stringWithFormat:@"%zd%@",count,text] ;
        [self addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}


@end
