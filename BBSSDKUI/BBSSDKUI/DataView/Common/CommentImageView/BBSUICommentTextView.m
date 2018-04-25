//
//  BBSUICommentTextView.m
//
//
//  Created by liyc on 17/9/02.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "BBSUICommentTextView.h"
#import "UIView+Extension.h"
#import "BBSUIImagePickerView.h"
#import "Masonry.h"
#import "UIImage+BBSFunction.h"
#import "BBSUIExpressionViewConfiguration.h"
#import "BBSUILBSLocationViewController.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 适配函数
#define CONVERT_SCALE(x) (x)/2
#define ConvertTo6_W(x) (CONVERT_SCALE(x)*320)/375
#define ConvertTo6_H(x) (CONVERT_SCALE(x)*568)/667
#define CT_SCALE_X      SCREEN_WIDTH/320.0
#define CT_SCALE_Y      SCREEN_HEIGHT/568.0

@interface BBSUICommentTextView() <iBBSUIImagePickerViewDelegate,BBSUIExpressionViewDelegate>
{
    UIButton                *_issueBtn;
    UIView                  *_bgView;
    UITapGestureRecognizer  *_tap;
    UIButton                *_imagePickButton;
    UIButton                *_keyboardButton;
    UIButton                *_faceButton;
    UIButton                *_badge;
    UIButton                *_addressButton;
}

@property (nonatomic ,strong) BBSUIImagePickerView *imagePickerView ;

@property (nonatomic, strong) BBSUIExpressionView *expView;

@property (nonatomic, copy)   void (^handler)(NSArray <UIImage *>*images,NSString *content);

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UIButton *addressTagView;

@end

@implementation BBSUICommentTextView

+ (instancetype)topTextView
{
    return [[self alloc] init];
}

+ (instancetype)portalTextView
{
    BBSUICommentTextView *textView = [[self alloc] init];
    textView -> _imagePickButton.hidden = YES;
    textView -> _keyboardButton.hidden = YES;
    textView -> _faceButton.hidden = YES;
    
    CGRect frame =textView -> _addressButton.frame;
    frame.origin.x = 12.5;
    textView -> _addressButton.frame = frame;
    
    return textView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ConvertTo6_H(316)*CT_SCALE_Y);
        // 切换中文九宫格所有数据都对 但是现实会有一个差不多10的间距  加大高度 补足 多的部分键盘挡住 视觉效果没有变
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ConvertTo6_H(400)*CT_SCALE_Y);
//        self.lpTextView.scrollsToTop = NO;
        self.countNumTextView.scrollsToTop = NO;
        self.backgroundColor = UIColorFromRGB(0xf8f8f8);
        [self makeSubView];
        // 添加键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setSendHandler:(void (^)(NSArray<UIImage *> *, NSString *))handler
{
    self.handler = handler;
}

- (void)cleanData
{
    [self.countNumTextView setText:nil];
    
    [_imagePickerView cleanData];
}

#pragma mark - Setter
-(void)setAddressLBS:(NSDictionary *)addressLBS{
    _addressLBS = addressLBS;
    NSString *text = @"";
    if (addressLBS == nil) {
        self.addressTagView.hidden = YES;
        self.countNumTextView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2 * ConvertTo6_W(30)*CT_SCALE_X, ConvertTo6_H(200)*CT_SCALE_Y);
    }else{
        text = [addressLBS valueForKey:@"name"];
        self.addressTagView.hidden = NO;
        self.countNumTextView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2 * ConvertTo6_W(30)*CT_SCALE_X, ConvertTo6_H(200)*CT_SCALE_Y - 40);
    }
    [_addressTagView setTitle:[NSString stringWithFormat:@" %@",text] forState:UIControlStateNormal];
    CGSize titleSize = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_addressTagView.titleLabel.font.fontName size:_addressTagView.titleLabel.font.pointSize]}];
    CGRect frame = _addressTagView.frame;
    frame.size.width = titleSize.width + 8 * 2 + 20;
    _addressTagView.frame = frame;
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.countNumTextView becomeFirstResponder];
    });
    
    
}

#pragma mark - 监听键盘
- (void)keyboardWillAppear:(NSNotification *)notif
{
    
    if ([self.countNumTextView isFirstResponder]) {
        NSDictionary *info = [notif userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        //        CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGSize keyboardSize = [value CGRectValue].size;
        _keyboardHeight = keyboardSize.height;
        
        // 5s ios10 可能有问题  带验证
        [UIView animateWithDuration:0.5 animations:^{
            if (keyboardSize.height == 292.0 || keyboardSize.height == 282.0) {
                // 适配搜狗输入法 分别在6p  6/5s 高度
                self.y = SCREEN_HEIGHT - keyboardSize.height - ConvertTo6_H(316)*CT_SCALE_Y ;
            }else{
                self.y = SCREEN_HEIGHT - keyboardSize.height - ConvertTo6_H(316)*CT_SCALE_Y ;
            }
            
            [_imagePickerView setFrame:CGRectMake(0, SCREEN_HEIGHT - keyboardSize.height, self.superview.width, _keyboardHeight)];
            
  
//            //表情
//            if (!_expView)
//            {
//                _expView = [[BBSUIExpressionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - _keyboardHeight, SCREEN_WIDTH, _keyboardHeight)];
//                _expView.delegate = self;
//            }
            
//            self.y = SCREEN_HEIGHT - keyboardSize.height - ConvertTo6_H(316)*CT_SCALE_Y ;
        }];
        [self.superview addSubview:_bgView];
        [self.superview addSubview:self];
        [self.superview addSubview:_imagePickerView];
    }
}
- (void)keyboardWillDisappear:(NSNotification *)notif
{
//    [UIView animateWithDuration:0.5 animations:^{
//        self.y = SCREEN_HEIGHT;
//    }];
//    [_bgView removeFromSuperview];
}

- (void)dismissCommentView
{
    [_countNumTextView resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        self.y = SCREEN_HEIGHT;
    }];
    [_bgView removeFromSuperview];
    [_imagePickerView removeFromSuperview];
    [_expView removeFromSuperview];
    _expView = nil;
}

#pragma mark - 非通知调用键盘消失方法
- (void)keyboardWillDisappear
{
    [self.countNumTextView resignFirstResponder];
}


-(void)makeSubView
{
    self.clipsToBounds = NO;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(ConvertTo6_W(30)*CT_SCALE_X, 10, SCREEN_WIDTH - 2 * ConvertTo6_W(30)*CT_SCALE_X, ConvertTo6_H(200)*CT_SCALE_Y)];
    contentView.layer.borderWidth = 0.5;
    contentView.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
    contentView.layer.cornerRadius = 2;
    contentView.clipsToBounds = YES;
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    // 输入框
    self.countNumTextView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2 * ConvertTo6_W(30)*CT_SCALE_X, ConvertTo6_H(200)*CT_SCALE_Y);
    self.countNumTextView.placeholder = @"请输入你的评论";
    self.countNumTextView.font = [UIFont systemFontOfSize:14];
    self.countNumTextView.textColor = UIColorFromRGB(0x333333);
    //self.countNumTextView.layer.borderWidth = 0.5;
    //self.countNumTextView.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
    self.countNumTextView.layer.cornerRadius = 2;
    self.countNumTextView.clipsToBounds = YES;
    [contentView addSubview:self.countNumTextView];
    
    // 地址标签
    self.addressTagView = ({
        UIButton *addressTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressTagView setBackgroundColor:DZSUIColorFromHex(0xEAEDF2)];
        [addressTagView setTitle:@" 地址" forState:UIControlStateNormal];
        [addressTagView setTitleColor:DZSUIColorFromHex(0x9A9CAA) forState:UIControlStateNormal];
        [addressTagView setImage:[UIImage BBSImageNamed:@"/LBS/LBS_min_icon.png"] forState:UIControlStateNormal];
        addressTagView.titleLabel.font = [UIFont systemFontOfSize:11];
        [addressTagView.layer setCornerRadius:2];
        [addressTagView.layer setMasksToBounds:YES];
        addressTagView.hidden = YES;
        // 光栅化
        addressTagView.layer.shouldRasterize = true;
        addressTagView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [addressTagView setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        [contentView addSubview:addressTagView];
        addressTagView.frame = CGRectMake(10, contentView.frame.size.height - 20 - 10, 60, 20);
        addressTagView ;
    });
    
    
    // @"发布"btn
    _issueBtn = [[UIButton alloc] init];
    _issueBtn.width = ConvertTo6_W(114)*CT_SCALE_X;
    _issueBtn.height = ConvertTo6_H(54)*CT_SCALE_Y;
    // 右边对齐输入框
    _issueBtn.x = contentView.x + contentView.width - _issueBtn.width;
    _issueBtn.y = contentView.y + contentView.height + 10;
    [_issueBtn setTitle:@"提交" forState:UIControlStateNormal];
    _issueBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _issueBtn.backgroundColor =  [UIColor colorWithRed:254/255.0 green:175/255.0 blue:93/255.0 alpha:1/1.0];
    _issueBtn.layer.cornerRadius = 2;
    _issueBtn.clipsToBounds = YES;
    [_issueBtn addTarget:self action:@selector(issueBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_issueBtn];
    
    //图片选择按钮
    CGFloat imagePickButtonWidth = 40;
    CGFloat imagePickButtonHeight = 36;
    _imagePickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_imagePickButton];
    [_imagePickButton setFrame:CGRectMake(12.5,
                                          _issueBtn.y + _issueBtn.height / 2 - imagePickButtonHeight / 2,
                                          imagePickButtonWidth,
                                          imagePickButtonHeight)];
    [_imagePickButton setImage:[UIImage BBSImageNamed:@"/Thread/PickImage.png"] forState:UIControlStateNormal];
    [_imagePickButton addTarget:self action:@selector(_pickButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    //键盘按钮
    CGFloat keyboarButtonWidth = 40;
    CGFloat keyboarButtonHeight = 34;
    _keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_keyboardButton];
    [_keyboardButton setFrame:CGRectMake(BBS_RIGHT(_imagePickButton) + 20,
                                         _issueBtn.y + _issueBtn.height / 2 - keyboarButtonHeight / 2,
                                         keyboarButtonWidth, 
                                         keyboarButtonHeight)];
    [_keyboardButton setImage:[UIImage BBSImageNamed:@"/Thread/Keyboard.png"] forState:UIControlStateNormal];
    [_keyboardButton addTarget:self action:@selector(_keyboardButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    //表情按钮
    CGFloat faceButtonWidth = 40;
    CGFloat faceButtonHeight = 40;
    _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_faceButton];
    [_faceButton setFrame:CGRectMake(BBS_RIGHT(_keyboardButton) + 20,
                                     _issueBtn.y + _issueBtn.height / 2 - faceButtonHeight / 2,
                                     faceButtonWidth,
                                     faceButtonHeight)];
    [_faceButton setImage:[UIImage BBSImageNamed:@"/Thread/Face@2x.png"] forState:UIControlStateNormal];
    [_faceButton addTarget:self action:@selector(_faceButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    
    //标志
    CGFloat badgeWidth = 16;
    CGFloat badgeHeight = 16;
    _badge = [UIButton buttonWithType:UIButtonTypeCustom];
    [_badge setTitle:@"0" forState:UIControlStateDisabled];
    _badge.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _badge.backgroundColor = [UIColor redColor];
    [_badge setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_badge setFrame:CGRectMake(_imagePickButton.width - badgeWidth, 0, badgeWidth, badgeHeight)];
    _badge.layer.cornerRadius = 8;
    _badge.enabled = NO;
    _badge.hidden = YES;
    [_imagePickButton addSubview:_badge];
    
    // 半透明灰色背景
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _bgView.backgroundColor = UIColorFromRGB(0x000000);
    _bgView.alpha = 0.5;
    
    _tap = [[UITapGestureRecognizer alloc] init];
    [_tap addTarget:self action:@selector(dismissCommentView)];
    [_bgView addGestureRecognizer:_tap];
    
    //图片选择器
    _imagePickerView = [[BBSUIImagePickerView alloc] init];
    _imagePickerView.delegate = self ;
    [_imagePickerView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.superview.width, 0)];
    
    
    //地址按钮
    CGFloat addressButtonWidth = 40;
    CGFloat addressButtonHeight = 40;
    _addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addressButton setImage:[UIImage BBSImageNamed:@"/LBS/LBS_max_icon.png"] forState:UIControlStateNormal];
    [_addressButton addTarget:self action:@selector(addressButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    _addressButton.frame = CGRectMake(BBS_RIGHT(_faceButton) + 20,
                                      _issueBtn.y + _issueBtn.height / 2 - addressButtonHeight / 2, addressButtonWidth, addressButtonHeight);
    [self addSubview:_addressButton];
}

#pragma mark - 点击发布按钮
- (void)issueBtnClicked
{
    NSString *string = [self.countNumTextView parseAttributeTextToNormalString:self.countNumTextView.textStorage];
    
    
        NSLog(@"%@",string);
    
    [self dismissCommentView];
    if (self.handler) {
        self.handler([_imagePickerView selectedImages], string);
    }
}

- (void)_pickButtonHandler:(UIButton *)button
{
    [_countNumTextView resignFirstResponder];
    
    [_expView removeFromSuperview];
}

- (void)_keyboardButtonHandler:(UIButton *)button
{
    if (![_countNumTextView isFirstResponder]) {
        [_countNumTextView becomeFirstResponder];
    }
    
    [_expView removeFromSuperview];
}

- (void)_faceButtonHandler:(UIButton *)button
{
    //表情
    if (!_expView)
    {
        _expView = [[BBSUIExpressionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - _keyboardHeight, SCREEN_WIDTH, _keyboardHeight)];
        _expView.delegate = self;
    }
    [self keyboardWillDisappear];
    
    [self.superview addSubview:_expView];
}

- (QZCountNumTextView *)countNumTextView
{
    if (!_countNumTextView) {

        _countNumTextView = [[QZCountNumTextView alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 150)];
//        _countNumTextView.frame = CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 150);
        _countNumTextView.placeholder = @"分享新鲜事...";
        _countNumTextView.maxCount = 100;
    }
    return _countNumTextView;
}


- (void)addressButtonHandler:(UIButton *)button{
    if (_openLBS) {
        _openLBS();
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_bgView removeGestureRecognizer:_tap];
}

#pragma mark - iBBSUIImagePickerViewDelegate

- (void)didBeginPickImages
{
    [_countNumTextView resignFirstResponder];
}

- (void)didEndPickImages
{
    
}

- (void)didResetAutolayout
{
    [self _setBadgeNumber:_imagePickerView.selectedImages.count];
}

- (void)_setBadgeNumber:(NSInteger)badge
{
    _badge.hidden = !badge ;
    
    [_badge setTitle:[NSString stringWithFormat:@"%zd",badge] forState:UIControlStateDisabled];
}

#pragma mark BBSUIExpressionViewDelegate

- (void)expressionView:(BBSUIExpressionView *)expressionView didSelectImageName:(NSString *)imageName
{
    [_countNumTextView setExpressionWithImageName:imageName fontSize:_countNumTextView.defaultFontSize];
}

@end
