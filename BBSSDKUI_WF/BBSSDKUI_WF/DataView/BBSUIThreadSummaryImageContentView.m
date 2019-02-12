//
//  BBSUIThreadSummaryImageContentView.m
//  BBSSDKUI_WF
//
//  Created by xiaochen yang on 2019/2/11.
//  Copyright © 2019 MOB. All rights reserved.
//

#import "BBSUIThreadSummaryImageContentView.h"

@interface BBSUIThreadSummaryImageContentView ()

@end

@implementation BBSUIThreadSummaryImageContentView

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
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = true;
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
