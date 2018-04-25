//
//  BBSUIActionSheet.m
//  BBSLBSPro
//
//  Created by wukx on 2018/4/5.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import "BBSUIActionSheet.h"

typedef NS_ENUM(NSInteger,BBSUIActionSheetType) {
    BBSUIActionSheetTypeWithImg,
    BBSUIActionSheetTypeWithTitle,
};

@interface BBSUIActionSheet()

@property(nonatomic,copy) void (^actionSheetClickWithIndexBlock)(int index);

@property(nonatomic,assign) BBSUIActionSheetType actionSheetType;
@property(nonatomic,strong) UIWindow *backWindow;
@property(nonatomic,copy) NSArray *imgArray;
@property(nonatomic,copy) NSArray *titles;
@property(nonatomic,copy) NSArray *colors;
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,strong) UIView *optionsBgView;
@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) NSMutableArray *optionBtnArrayM;
@property(nonatomic,assign) float bgViewHeigh;

@end

@implementation BBSUIActionSheet

+(instancetype)actionSheetWithTitleArray:(NSArray<NSString *> *)titleArray andTitleColorArray:(NSArray *)colors delegate:(id<BBSUIActionSheetDelegate>)delegate{
    return [[self alloc] initSheetWithTitles:titleArray andTitleColors:colors andDelegate:delegate];
}

+(instancetype)actionSheetWithTitleArray:(NSArray *)titleArray  andTitleColorArray:(NSArray *)colors block:(void (^)(int index)) block{
    BBSUIActionSheet *actionSheet = [[self alloc] initSheetWithTitles:titleArray andTitleColors:colors andDelegate:nil];
    actionSheet.actionSheetClickWithIndexBlock = block;
    return actionSheet;
}

+(instancetype)actionSheetWithImageArray:(NSArray *)imgArray delegate:(id<BBSUIActionSheetDelegate>)delegate{
    return [[self alloc] initSheetWithImgs:imgArray andDelegate:delegate];
}

+(instancetype)actionSheetWithImageArray:(NSArray *)imgArray block:(void (^)(int index)) block{
    BBSUIActionSheet *actionSheet = [[self alloc] initSheetWithImgs:imgArray andDelegate:nil];
    actionSheet.actionSheetClickWithIndexBlock = block;
    return actionSheet;
}

-(instancetype)initSheetWithTitles:(NSArray *)titleArray andTitleColors:(NSArray *)colors andDelegate:(id<BBSUIActionSheetDelegate>)delegate{
    self.titles = titleArray;
    self.colors = colors;
    self.actionSheetType = BBSUIActionSheetTypeWithTitle;
    _delegate = delegate;
    return [self initActionSheet];
}
-(instancetype)initSheetWithImgs:(NSArray *)imgArray andDelegate:(id<BBSUIActionSheetDelegate>)delegate{
    self.actionSheetType = BBSUIActionSheetTypeWithImg;
    self.imgArray = imgArray;
    _delegate = delegate;
    return [self initActionSheet];
}

-(instancetype)initActionSheet{
    if (self = [super init]) {
        
        self.frame = [UIScreen mainScreen].bounds;
        
        [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0f]];
        [self addSubview:self.bgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlertView)];
        [self addGestureRecognizer:tap];
        [self.bgView addSubview:self.cancelBtn];
        [self.bgView addSubview:self.optionsBgView];
        
        float kRealValue = [UIScreen mainScreen].bounds.size.width/375.0;
        float btnHeight = kRealValue*(45);//按钮统一高度
        float lineHeight = 0.5f;//线高
        float optionViewLineHeight = 0;//线总高
        NSArray *arrayC = [[NSArray alloc] init];
        switch (self.actionSheetType){
            case BBSUIActionSheetTypeWithImg:
                arrayC = self.imgArray;
                break;
            case BBSUIActionSheetTypeWithTitle:
                arrayC = self.titles;
                break;
            default:
                break;
        }
        //线永远比数组数少一个 如果数组等于0 线的数量不能等于-1 所以线高等于0
        if (arrayC.count == 0) {
            optionViewLineHeight = 0;
        }else{
            optionViewLineHeight = (arrayC.count-1) * lineHeight;
        }
        float optionBgWithCancelBtnMargin = kRealValue*15;//选项和按钮之间间距
        float optionBgViewHeight = btnHeight*arrayC.count + optionViewLineHeight;//选项View高度
        float btnAllAroundMargin = kRealValue*10;//按钮距离四周的间距
        self.bgViewHeigh = optionBgViewHeight+optionBgWithCancelBtnMargin+btnHeight;
        _bgView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.bgViewHeigh);
        
        _cancelBtn.frame = CGRectMake(btnAllAroundMargin, self.bgView.frame.size.height - btnAllAroundMargin -btnHeight, self.bgView.frame.size.width - 2*btnAllAroundMargin, btnHeight);
        //选项背景View高度等于线总高+选项总高
        _optionsBgView.frame = CGRectMake(btnAllAroundMargin, 0, self.bgView.frame.size.width - 2*btnAllAroundMargin, optionBgViewHeight);
        
        for (int i = 0; i<arrayC.count; ++i) {
            UIButton *button = [UIButton new];
            button.tag = 990+i;
            [button setBackgroundColor:[UIColor whiteColor]];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            if (self.actionSheetType == BBSUIActionSheetTypeWithTitle) {
                NSString *title = @"";
                NSAssert([self.titles[i] isKindOfClass:[NSString class]], @"标题数组里必须传入NSString类型对象" );
                title = self.titles[i];
                [button setTitle:title forState:UIControlStateNormal];
                [self.optionBtnArrayM addObject:button];
                
            }else if (self.actionSheetType == BBSUIActionSheetTypeWithImg){
                NSString *imageName = @"";
                //过滤掉误传的非NSString类型的图片名数据
                NSAssert([self.imgArray[i] isKindOfClass:[NSString class]], @"图片名数组里必须传入NSString类型" );
                imageName = self.imgArray[i];
                [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            }
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.optionsBgView addSubview:button];
            //按钮布局从上向下 已布局按钮高度+已布局线高度
            button.frame = CGRectMake(0, i*btnHeight+i*lineHeight, _optionsBgView.frame.size.width, btnHeight);

            //当数组长度非0的时候 创建比数组少一的线
            if (i != self.titles.count-1) {
                UIView *line = [UIView new];
                [self.optionsBgView addSubview:line];
                [line setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1f]];
                line.frame = CGRectMake(0, CGRectGetMaxY(button.frame), _optionsBgView.frame.size.width, lineHeight);
            }
        }
        [self optionColorSet];
    }
    return self;
}

-(void)setCancelDefaultColor:(UIColor *)cancelDefaultColor{
    _cancelDefaultColor = cancelDefaultColor;
    [self.cancelBtn setTitleColor:cancelDefaultColor forState:UIControlStateNormal];
}
-(void)setOptionDefaultColor:(UIColor *)optionDefaultColor{
    _optionDefaultColor = optionDefaultColor;
    [self optionColorSet];
}

-(void)optionColorSet{
    //颜色数组可以为空  为空默认黑色  不为空必须传UIColor类型
    if (self.optionBtnArrayM.count != 0) {
        UIColor *color = [UIColor whiteColor];
        
        
        for (int i = 0; i<self.optionBtnArrayM.count; ++i) {
            UIButton *button = self.optionBtnArrayM[i];
            if (i<self.colors.count) {
                NSAssert([self.colors[i] isKindOfClass:[UIColor class]], @"标题颜色数组里必须传入UIColor类型对象" );
                color = self.colors[i];
            }else{
                
                if (self.optionDefaultColor != nil) {
                    color = self.optionDefaultColor;
                }else{
                    color = [UIColor blackColor];
                }
            }
            [button setTitleColor:color forState:UIControlStateNormal];
        }
        
    }
}

-(void)buttonClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(bbsui_actionSheetClickWithIndex:)]) {
        [self.delegate bbsui_actionSheetClickWithIndex:(int)btn.tag-990];
    }
    if (self.actionSheetClickWithIndexBlock) {
        self.actionSheetClickWithIndexBlock((int)btn.tag-990);
    }
    
    [self dismissAlertView];
}
-(void)cancelBtnClick{
    [self dismissAlertView];
}

-(void)layerAnimationMakeWithUp:(BOOL)up{
    [self.layer removeAllAnimations];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    if (up == YES) {
        colorAnimation.duration = 0.3;
        colorAnimation.fromValue = (__bridge id _Nullable)([[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0] CGColor]);
        colorAnimation.toValue = (__bridge id _Nullable)([[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor]);
    }else{
        colorAnimation.duration = 0.15;
        colorAnimation.fromValue = (__bridge id _Nullable)([[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor]);
        colorAnimation.toValue = (__bridge id _Nullable)([[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0] CGColor]);
    }
    
    
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    colorAnimation.fillMode = kCAFillModeForwards;
    colorAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:colorAnimation forKey:@"colorAnimation"];
    
}

-(void)showActionSheet{
    _backWindow.hidden = NO;
    [self.backWindow addSubview:self];
    [self layerAnimationMakeWithUp:YES];
    [self.bgView.superview layoutIfNeeded];
    CGRect tmpFrame = self.bgView.frame;
    tmpFrame.origin.y = self.frame.size.height - self.bgViewHeigh;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = tmpFrame;
        [self.bgView.superview layoutIfNeeded];//强制绘制
    }];
}
-(void)dismissAlertView{
    
    [self layerAnimationMakeWithUp:NO];
    
    CGRect tmpFrame = self.bgView.frame;
    tmpFrame.origin.y = self.frame.size.height;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.bgView.frame =tmpFrame;
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Getter

-(UIWindow *)backWindow{
    if (!_backWindow) {
        _backWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _backWindow;
}

-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton new];
        [_cancelBtn setBackgroundColor:[UIColor colorWithRed:98/255.0 green:190/255.0 blue:130/255.0 alpha:1]];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancelBtn.layer.cornerRadius = 10;
        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIView *)optionsBgView{
    if (!_optionsBgView) {
        _optionsBgView = [UIView new];
        [_optionsBgView setBackgroundColor:[UIColor whiteColor]];
        _optionsBgView.layer.cornerRadius = 10;
        _optionsBgView.layer.masksToBounds = YES;
    }
    return _optionsBgView;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        [_bgView setBackgroundColor:[UIColor clearColor]];
    }
    return _bgView;
}

-(NSMutableArray *)optionBtnArrayM{
    if (!_optionBtnArrayM) {
        _optionBtnArrayM = [[NSMutableArray alloc] initWithCapacity:41];
    }
    return _optionBtnArrayM;
}

@end
