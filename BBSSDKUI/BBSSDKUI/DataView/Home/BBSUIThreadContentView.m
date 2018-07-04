
//
//  BBSUIThreadContentView.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadContentView.h"
#import "Masonry.h"

@interface BBSUIThreadContentView ()

/**
 标题
 */
@property (nonatomic, strong) UILabel *subjectLabel;

/**
 摘要
 */
@property (nonatomic, strong) UILabel *summaryLabel;

///**
// 附件图片容器
// */
//@property (nonatomic, strong) UIView *attachmentContainerView;

/**
 附件图片1
 */
@property (nonatomic, strong) UIImageView *attachImageViewOne;

/**
 附件图片2
 */
@property (nonatomic, strong) UIImageView *attachImageViewTwo;

/**
 附件图片3
 */
@property (nonatomic, strong) UIImageView *attachImageViewThree;

@end

@implementation BBSUIThreadContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
        [self setViewAutoLayout];
    }
    
    return self;
}

#pragma mark -
- (void)configureUI
{
    self.subjectLabel = [[UILabel alloc] init];
    [self addSubview:self.subjectLabel];
    [self.subjectLabel setNumberOfLines:1];
    
    self.summaryLabel = [[UILabel alloc] init];
    [self addSubview:self.summaryLabel];
    
//    self.attachImageViewOne = [UIImageView new];
//    [self addSubview:_attachImageViewOne];
//    
//    self.attachImageViewTwo = [UIImageView new];
//    [self addSubview:_attachImageViewTwo];
//    
//    self.attachImageViewThree = [UIImageView new];
//    [self addSubview:_attachImageViewThree];
    
}

- (void)setViewAutoLayout
{
    [self.subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        /**
         *  相对于TopGroupView而言，距离顶部是10像素
         */
        make.top.equalTo(self.mas_top).with.offset(10);
        
        /**
         *  相对于TopGroupView而言，距离左边是0像素
         */
        make.left.equalTo(self.mas_left).with.offset(0);
        
        make.right.equalTo(self.mas_right).with.offset(0);
        
        /**
         *  相对于TopGroupView而言，高度是40像素
         */
        make.height.equalTo(@40);
    }];

    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subjectLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
    }];
//
//    CGFloat Padding = 10;
//    CGFloat imageWidth = (DZSUIScreen_width - Padding * 4) / 3;
//    [self.attachImageViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).with.offset(0);
//        make.top.equalTo(self.summaryLabel.mas_bottom).with.offset(5);
//        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
//        make.bottom.equalTo(self.mas_bottom);
//    }];
//    
//    [self.attachImageViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.attachImageViewOne.mas_top);
//        make.left.equalTo(self.attachImageViewOne.mas_right).with.offset(10);
//        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
//        make.bottom.equalTo(self.attachImageViewOne.mas_bottom);
//    }];
//    
//    [self.attachImageViewThree mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.attachImageViewOne.mas_top);
//        make.left.equalTo(self.attachImageViewTwo.mas_right).width.offset(10);
//        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
//        make.bottom.equalTo(self.attachImageViewOne.mas_bottom);
//    }];
    
    
//
//    [self.attachmentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@0);
//        make.top.equalTo(self.summaryLabel.mas_bottom).with.offset(5);
//        make.bottom.equalTo(self.mas_bottom).with.offset(05);
//        make.right.equalTo(0);
//    }];
//
//    NSArray *array = @[self.attachImageViewOne, self.attachImageViewTwo, self.attachImageViewThree];
//    [self makeEqualWidthViews:array inView:self.attachmentContainerView LRpadding:0 viewPadding:10];
    
}

- (void)setThreadModel:(BBSThread *)threadModel
{
    _threadModel = threadModel;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self.subjectLabel setText:_threadModel.subject];
    [self.summaryLabel setText:_threadModel.summary];
    for (NSString *imageURL in _threadModel.images) {
        [self.attachImageViewOne setImage:[UIImage imageNamed:imageURL]];
    }
}


#pragma mark - private
/**
 *  将若干view等宽布局于容器containerView中
 *
 *  @param views         viewArray
 *  @param containerView 容器view
 *  @param LRpadding     距容器的左右边距
 *  @param viewPadding   各view的左右边距
 */
-(void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView LRpadding:(CGFloat)LRpadding viewPadding :(CGFloat)viewPadding
{
    UIView *lastView;
    for (UIView *view in views) {
        [containerView addSubview:view];
        if (lastView) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(containerView);
                make.left.equalTo(lastView.mas_right).offset(viewPadding);
                make.width.equalTo(lastView);
            }];
        }else
        {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(containerView).offset(LRpadding);
                make.top.bottom.equalTo(containerView);
            }];
        }
        lastView=view;
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-LRpadding);
    }];
}

@end
