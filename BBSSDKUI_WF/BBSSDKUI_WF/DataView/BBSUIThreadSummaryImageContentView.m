//
//  BBSUIThreadSummaryImageContentView.m
//  BBSSDKUI_WF
//
//  Created by xiaochen yang on 2019/2/11.
//  Copyright © 2019 MOB. All rights reserved.
//

#import "BBSUIThreadSummaryImageContentView.h"
#import "BBSUIImagePreviewHUD.h"

@interface BBSUIThreadSummaryImageContentView ()

@end

@implementation BBSUIThreadSummaryImageContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = true;
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)ges {
//    CGPoint point = [ges locationInView:self];
//    NSInteger pos = (NSInteger)(point.x / (self.frame.size.width / 3));
//    NSLog(@"%zu %f %f", pos, point.x, self.frame.size.width);
    UIView *view = ges.view;
    [BBSUIImagePreviewHUD showWithImageUrls:self.images index:view.tag - 1000];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.mob.bbs.sdk.CellImageTap" object:@(pos)];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(threadSummaryImageContentView:didSelectedIndex:)]) {
//        [self.delegate threadSummaryImageContentView:self didSelectedIndex:pos];
//    }
}

- (void)setImages:(NSArray *)images {
    _images = images;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 12;
    [self addSubview:stackView];
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 1000 + i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [imageView addGestureRecognizer:tap];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = true;
        imageView.userInteractionEnabled = true;
        imageView.backgroundColor = [UIColor clearColor];
        if (i < images.count) {
            imageView.image = [UIImage BBSImageNamed:@"/Home/wutu@2x.png"];
            NSString *url = images[i];
            [[MOBFImageGetter sharedInstance] getImageDataWithURL:[NSURL URLWithString:url] result:^(NSData *imageData, NSError *error) {
                if (error)
                {
                    NSLog(@"%@",error);
                    return ;
                }
                UIImage *image = [UIImage imageWithData:imageData];
                imageView.image = image;
            }];
        }
        [stackView addArrangedSubview:imageView];
    }
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

@end
