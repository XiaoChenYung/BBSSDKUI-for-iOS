//
//  BBSUIReplyStateView.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIReplyStateView.h"
#import "Masonry.h"

@interface BBSUIReplyStateView ()

@property(nonatomic, strong) UIView *indicatorView;
@property(nonatomic, strong) UIButton *failAlert;
@property(nonatomic, strong) UIButton *successAlert;

@end

@implementation BBSUIReplyStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.replyBtn =
    ({
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [replyBtn setTitle:@"写评论..." forState:UIControlStateDisabled];
        [replyBtn setTitleColor:DZSUIColorFromHex(0xC5C8CC) forState:UIControlStateDisabled];
//        [replyBtn setImage:[UIImage BBSImageNamed:@"/Common/replyBig@2x.png"] forState:UIControlStateDisabled];
        replyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        replyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        replyBtn.enabled = NO;
        
        [self addSubview:replyBtn];
        [replyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(11);
            make.top.equalTo(self).offset(10);
            make.height.equalTo(@30);
            make.width.equalTo(@64);
        }];
        replyBtn;
    });
    
    self.indicatorView =
    ({
        UIView *alertView  = [[UIView alloc] init];
        [self addSubview:alertView];
        [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] init];
        view.color = [UIColor blueColor];
        [alertView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(alertView);
            make.height.width.equalTo(@30);
        }];
//        [view startAnimating];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = DZSUIColorFromHex(0x3A4045);
//        label.text = @"正在提交";
        [alertView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_right).offset(5);
            make.centerY.equalTo(view);
            make.right.equalTo(alertView);
        }];
        
        alertView.hidden = YES;
        alertView ;
    });
}

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

- (void)setState:(BBSUIReplyState)state
{
    if (_state!=state)
    {
        switch (state) {
                
            case BBSUIReplyStateNormal:
            {
                self.indicatorView.hidden = YES ;
                self.replyBtn.hidden = NO;
                
//                [_replyBtn setTitle:@"回复" forState:UIControlStateDisabled];
//                [_replyBtn setImage:[UIImage BBSImageNamed:@"/Common/replyBig@2x.png"] forState:UIControlStateDisabled];
//                [_replyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self).offset(11);
//                    make.top.equalTo(self).offset(10);
//                    make.height.equalTo(@30);
//                    make.width.equalTo(@64);
//                }];
            }
                break;
                
            case BBSUIReplyStateUploading:
            {
                self.indicatorView.hidden = NO;
                self.replyBtn.hidden = YES;
                
            }
                break;
                
            case BBSUIReplyStateFail:
            {
                self.indicatorView.hidden = YES ;
                self.replyBtn.hidden = NO;
//                [_replyBtn setTitle:@"回帖失败" forState:UIControlStateDisabled];
//                [_replyBtn setImage:[UIImage BBSImageNamed:@"/Common/postFail@2x.png"] forState:UIControlStateDisabled];
//                [_replyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.center.equalTo(self);
//                    make.height.equalTo(@30);
//                    make.width.equalTo(@100);
//                }];
            }
                
                break;
            case BBSUIReplyStateSuccess:
            {
                self.indicatorView.hidden = YES ;
                self.replyBtn.hidden = NO;
//                [_replyBtn setTitle:@"回帖成功" forState:UIControlStateDisabled];
//                [_replyBtn setImage:[UIImage BBSImageNamed:@"/Common/postSuccess@2x.png"] forState:UIControlStateDisabled];
//                [_replyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.center.equalTo(self);
//                    make.height.equalTo(@30);
//                    make.width.equalTo(@100);
//                }];
            }
                
                break;
                
            default:
                break;
        }
    }
    _state = state;
}

@end
