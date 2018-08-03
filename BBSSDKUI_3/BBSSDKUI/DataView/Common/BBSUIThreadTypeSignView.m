//
//  BBSUIThreadTypeSignView.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/6/2.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadTypeSignView.h"
#import "Masonry.h"

@interface BBSUIThreadTypeSignView()

@property (nonatomic, assign) BOOL hot;

@property (nonatomic, assign) BOOL support;

@property (nonatomic, assign) BOOL perfect;

@end

#define koffset 5

@implementation BBSUIThreadTypeSignView

- (void) setupWithPaths:(NSArray *)paths
{    
    for (UIView *obj in self.subviews)
    {
        [obj removeFromSuperview];
    }
    
    switch (paths.count)
    {
        case 1:
        {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[0]]];
            
            [self addSubview:image];
            [image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
                make.width.height.equalTo(@15);
            }];
        }
            break;
        
        case 2:
        {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[0]]];
            [self addSubview:image];
            [image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.width.height.equalTo(@15);
            }];
            
            UIImageView *image1 = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[1]]];
            [self addSubview:image1];
            [image1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(image.mas_right).offset(koffset);
                make.centerY.equalTo(image);
                make.width.height.equalTo(@15);
                make.right.equalTo(self);
            }];
        }
             break;
            
        case 3:
        {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[0]]];;
            [self addSubview:image];
            [image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.width.height.equalTo(@15);
            }];
            
            UIImageView *image1 = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[1]]];;
            [self addSubview:image1];
            [image1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(image.mas_right).offset(koffset);
                make.centerY.equalTo(image);
                make.width.height.equalTo(@15);
            }];
            
            UIImageView *image2 = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:paths[2]]];;
            [self addSubview:image2];
            [image2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(image1.mas_right).offset(koffset);
                make.centerY.equalTo(image1);
                make.width.height.equalTo(@15);
                make.right.equalTo(self);
            }];
        }
             break;
        
        default:
            break;
    }
    
    
}
@end
