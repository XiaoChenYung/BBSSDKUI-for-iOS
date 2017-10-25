//
//  BBSUINavHeaderView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/6.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUINavHeaderView.h"
#import "NSObject+SimpleKVONotification.h"
#define NAVBAR_CHANGE_POINT 50

const CGFloat BBSLimitValue = 200;

@interface BBSUINavHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation BBSUINavHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backButton];
    }
    return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    for (UITableView *tableView in self.tableViews) {

        [tableView addObserverForKeyPath:NSStringFromSelector(@selector(contentOffset)) block:^(__weak id obj, id oldValue, id newValue) {
            
            UITableView *tableView = (UITableView *)obj;
            CGFloat tableViewoffsetY = tableView.contentOffset.y;
            
            UIColor * color = [UIColor whiteColor];
            CGFloat alpha = MIN(1, tableViewoffsetY/(BBSLimitValue+11));
            
            self.backgroundColor = [color colorWithAlphaComponent:alpha];
            
            if (tableViewoffsetY < BBSLimitValue){
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.backButton.hidden = NO;
                    self.backButton.alpha = 1-alpha;
                    self.titleLabel.alpha = alpha;
                    [self.rightButotnArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.hidden = NO;
                        obj.alpha = 1-alpha;
                    }];
                    
                }];
            } else if (tableViewoffsetY >= BBSLimitValue){
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.backButton.hidden = YES;
                    [self.rightButotnArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.hidden = YES;
                    }];
                    
                }];
            }
        }];
    }
    
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(7, 30, 30, 30)];
        [_backButton setBackgroundImage:[UIImage BBSImageNamed:@"/Common/BackButton3@2x.png"] forState:UIControlStateNormal];
        
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backButton;
}

- (void)backAction
{
    [[MOBFViewController currentViewController].navigationController popViewControllerAnimated:YES];
}

- (void)setRightButotnArray:(NSArray *)rightButotnArray
{
    _rightButotnArray = rightButotnArray;
    
    if (rightButotnArray.count == 0)
    {
        return;
    }
    
    CGFloat right = 7;
    CGFloat width = 30;
    CGFloat left = self.frame.size.width-right-width;
    
    for (int i = 0; i < rightButotnArray.count; i ++ ) {
        UIButton *button = rightButotnArray[i];
        button.frame = CGRectMake(left, 30, width, width);
        [self addSubview:button];
        
        left -= (width + 10);
    }
}

- (void)setTitle:(NSString *)title
{

    CGFloat titleW = 150;
    CGFloat titleX = (self.frame.size.width-titleW) / 2;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, 30, titleW, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = DZSUIColorFromHex(0x2A2B30);
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = title;
    _titleLabel = titleLabel;
    
    [self addSubview:titleLabel];
    titleLabel.alpha = 0;
    
}

@end
