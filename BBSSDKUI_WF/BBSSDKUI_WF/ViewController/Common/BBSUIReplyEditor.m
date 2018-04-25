//
//  BBSUIReplyEditor.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIReplyEditor.h"
#import "Masonry.h"
#import "BBSUIMacro.h"
#import "BBSUIImagePickerView.h"
#import "BBSUIExpressionViewConfiguration.h"
#import "BBSUIExpressionTextField.h"
#import "BBSUILBSLocationViewController.h"

@interface BBSUIReplyEditor ()<iBBSUIImagePickerViewDelegate, BBSUIExpressionViewDelegate, UITextViewDelegate>
{
    NSTimeInterval _animationDuration;
}

@property (nonatomic ,strong) UIView *editorView;
//@property (nonatomic ,strong) BBSUIExpressionTextField *textEditor ;
@property (nonatomic, strong) BBSUIExpressionTextView *textEditor;
@property (nonatomic ,strong) UIButton *sendBtn;
@property (nonatomic ,strong) UIView *imagePickBar;
@property (nonatomic ,strong) UIButton *imagePickBtn;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *addressButton;
@property (nonatomic ,strong) BBSUIImagePickerView *imagePickerView ;
@property (nonatomic ,copy) NSString *userName ;
@property (nonatomic ,strong) UIWindow *window ;
@property (nonatomic ,copy) FinishEditHandler handler ;
@property (nonatomic ,strong) UIButton *badge;
@property (nonatomic, strong) UIView *backGroundView;

@property (nonatomic, strong) BBSUIExpressionView *expView;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL secondShow;

@property (nonatomic, strong) NSDictionary *locationInfo;

@end

@implementation BBSUIReplyEditor

- (void)showWithUserName:(NSString *)userName finishEdit:(FinishEditHandler)handler
{
    self.userName = userName ;
    self.handler = handler ;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelAlert - 1 ;
    _backGroundView = [[UIView alloc] initWithFrame:self.window.bounds];
    _backGroundView.backgroundColor = [UIColor blackColor];
    _backGroundView.alpha = 0.25 ;
    [self.window addSubview:_backGroundView];
    self.view.frame = self.window.bounds ;
    [self.window addSubview:self.view];
    [self.window makeKeyAndVisible];
    if (_secondShow)
    {
        [_textEditor becomeFirstResponder];
    }
    
}

- (void)dismiss
{
    [self.view endEditing:YES];
    
    [self.window resignKeyWindow];
    [_expView removeFromSuperview];
    [_backGroundView removeFromSuperview];
    self.window = nil;
    self.view = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI
{
    self.view.userInteractionEnabled = YES ;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.editorView =
    ({
        UIView *editorView = [[UIView alloc] init];
        
        editorView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:editorView];
        
        [editorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_bottom);
            make.top.equalTo(self.view.mas_bottom).offset(-50);
        }];
        
        editorView ;
    });
    
    UIView *textFieldContainer = [[UIView alloc] init];
    [_editorView addSubview:textFieldContainer];
    [textFieldContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_editorView);
        make.height.equalTo(@50);
    }];
    
    UIView *lineTop = [[UIView alloc] init];
    lineTop.backgroundColor = [UIColor darkGrayColor];
    lineTop.alpha = 0.25 ;
    [textFieldContainer addSubview:lineTop];
    [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(textFieldContainer);
        make.height.equalTo(@1);
    }];
    
    self.sendBtn =
    ({
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        sendBtn.layer.cornerRadius = 2 ;
        
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        sendBtn.backgroundColor = DZSUIColorFromHex(0x5B7Ef0);
        
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [sendBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        
        [textFieldContainer addSubview:sendBtn];
        
        [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(textFieldContainer).offset(-15);
            make.centerY.equalTo(textFieldContainer);
            make.width.equalTo(@65);
            make.height.equalTo(@30);
        }];
        
        sendBtn ;
    });
    
    self.textEditor =
    ({
        BBSUIExpressionTextView *textEditor = [[BBSUIExpressionTextView alloc] init];
//        textEditor.placeholder = [@"回复: " stringByAppendingFormat:@"%@",_userName];
        textEditor.delegate = self;
        
        [textFieldContainer addSubview:textEditor];
        
        [textEditor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(textFieldContainer).offset(15);
            make.right.equalTo(_sendBtn.mas_left).offset(-15);
            make.top.equalTo(textFieldContainer).offset(10);
            make.height.equalTo(@39);
        }];
        
        textEditor ;
    });
    
    UIView *lineBottom = [[UIView alloc] init];
    lineBottom.backgroundColor = [UIColor darkGrayColor];
    lineBottom.alpha = 0.25 ;
    [textFieldContainer addSubview:lineBottom];
    [lineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(textFieldContainer);
        make.height.equalTo(@1);
    }];
    
    self.imagePickBar =
    ({
        UIView *imagePickBar = [[UIView alloc] init];
        [_editorView addSubview:imagePickBar];
        [imagePickBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_editorView);
            make.top.equalTo(textFieldContainer.mas_bottom);
            make.height.equalTo(@45);
        }];
        
        imagePickBar ;
    });
    
    UIButton *imagePickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imagePickBtn setImage:[UIImage BBSImageNamed:@"/Common/selectImage@2x.png"] forState:UIControlStateNormal];
    [imagePickBtn addTarget:self action:@selector(pickImages:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePickBar addSubview:imagePickBtn];
    [imagePickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_imagePickBar).offset(-10);
        make.centerY.equalTo(_imagePickBar);
        make.height.with.width.equalTo(@30);
    }];
    

    // 表情
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceButton = faceButton;
    [faceButton setImage:[UIImage BBSImageNamed:@"/Thread/Face@2x.png"] forState:UIControlStateNormal];
    [faceButton addTarget:self action:@selector(_faceButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePickBar addSubview:faceButton];
    [faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imagePickBtn.mas_left).offset(-10);
        make.centerY.equalTo(_imagePickBar);
        make.height.with.width.equalTo(@30);
    }];
    
    self.badge =
    ({
        UIButton *badge = [UIButton buttonWithType:UIButtonTypeCustom];
        [badge setTitle:@"0" forState:UIControlStateDisabled];
        badge.titleLabel.font = [UIFont systemFontOfSize:12.5];
        badge.backgroundColor = [UIColor redColor];
        [badge setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        badge.layer.cornerRadius = 8;
        badge.enabled = NO;
        badge.hidden = YES;
        [_imagePickBar addSubview:badge];
        [badge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(@16);
            make.right.equalTo(imagePickBtn).offset(4);
            make.top.equalTo(imagePickBtn).offset(-4);
        }];
        
        badge ;
    });

    self.imagePickerView =
    ({
        BBSUIImagePickerView *imagePickerView = [[BBSUIImagePickerView alloc] init];
        imagePickerView.delegate = self ;
        [_editorView addSubview:imagePickerView];
        [imagePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.left.equalTo(_editorView);
            make.top.equalTo(_imagePickBar.mas_bottom);

        }];
        
        imagePickerView ;
    });
    
    //地址Tag v2.4.0
    self.addressButton = ({
        UIButton *addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressButton setTitle:@"" forState:UIControlStateNormal];
        [addressButton setTitleColor:DZSUIColorFromHex(0x9A9CAA) forState:UIControlStateNormal];
        [addressButton setImage:[UIImage BBSImageNamed:@"/LBS/LBS_max_icon.png"] forState:UIControlStateNormal];
        addressButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [addressButton addTarget:self action:@selector(addressButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        addressButton;
    });
    
    if (_isPortal)
    {
        imagePickBtn.hidden = YES;
        faceButton.hidden = YES;
        _imagePickerView.hidden = YES;
//        lineTop.hidden = YES;
        lineBottom.hidden = YES;

        [self.textEditor mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(@0);
            make.height.equalTo(@100);
        }];
        
        [self.sendBtn removeFromSuperview];
        [self.editorView addSubview:self.sendBtn];
        
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-10);
            make.top.equalTo(self.textEditor.mas_bottom).offset(5);
            make.width.equalTo(@70);
            make.height.equalTo(@30);
        }];
        
        
        [_editorView addSubview:_addressButton];
        [_addressButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_editorView.mas_left).offset(10);
            make.centerY.equalTo(_sendBtn);
            make.height.equalTo(@30);
        }];

    }else{
        [_imagePickBar addSubview:_addressButton];
        [_addressButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imagePickBar.mas_left).offset(10);
            make.centerY.equalTo(_imagePickBar);
            make.height.equalTo(@30);
        }];
        
    }
    
}

- (void)hideToolButton
{
    _isPortal = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textEditor becomeFirstResponder];
}

#pragma mark -  UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat height = [aValue CGRectValue].size.height;
    _keyboardHeight = height;
    
    if (_isPortal)
    {
        [self.editorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-(50+45+height + 50));
        }];
    }
    else
    {
        [self.editorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-(50+45+height));
        }];
    }
    
    
    //表情
//    if (!_expView)
//    {
//        _expView = [[BBSUIExpressionView alloc] initWithFrame:CGRectMake(0, DZSUIScreen_height - _keyboardHeight - 44, DZSUIScreen_width, _keyboardHeight+44)];
//        _expView.delegate = self;
////        [self.view addSubview:_expView];
//    }
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
//    NSDictionary *userInfo = [aNotification userInfo];
//    [self.editorView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_bottom);
//    }];
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    _animationDuration = animationDuration;
//    [UIView animateWithDuration:animationDuration animations:^{
//        [self.view layoutIfNeeded];
//    }];
}

- (void)send:(id)sender
{
    NSString *string = [self.textEditor parseAttributeTextToNormalString:self.textEditor.textStorage];
    
    if (self.handler)
    {
        self.handler(NO, [_imagePickerView selectedImages], string, _locationInfo);
    }
    
    self.window.hidden = YES;
    [self.window resignKeyWindow];
    self.window = nil ;
    _secondShow = YES;
}

- (void)pickImages:(id)sender
{
    [_imagePickerView pickImages];
    [_expView removeFromSuperview];
}

- (void)_faceButtonHandler:(UIButton *)button
{
    [self.textEditor resignFirstResponder];

    if (!_expView)
    {
        _expView = [[BBSUIExpressionView alloc] initWithFrame:CGRectMake(0, DZSUIScreen_height - _keyboardHeight, DZSUIScreen_width, _keyboardHeight)];
        _expView.delegate = self;
    }
    
    [self.view addSubview:_expView];
}

- (void)addressButtonOnClick:(id)sender{
    __weak typeof(self)weakSelf = self;
    BBSUILBSLocationViewController *locationVC = [[BBSUILBSLocationViewController alloc] init];
    locationVC.locationSelectBlock = ^(id locationInfo) {
        NSDictionary *info = (NSDictionary *)locationInfo;
        weakSelf.locationInfo = info;
        if (info == nil) {
            [weakSelf.addressButton setTitle:@"" forState:UIControlStateNormal];
        }else{
            [weakSelf.addressButton setTitle:[info valueForKey:@"name"] forState:UIControlStateNormal];
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationVC];
    locationVC.isPresent = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - iBBSUIImagePickerViewDelegate 

- (void)didBeginPickImages
{
    [self.textEditor setUserInteractionEnabled:NO];
    [self.textEditor resignFirstResponder];
}

- (void)didEndPickImages
{
    [self.textEditor setUserInteractionEnabled:YES];
}

- (void)didResetAutolayout
{
    [self setBadgeNumber:_imagePickerView.selectedImages.count];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self.view];
    
    if (self.editorView.frame.origin.y < location.y)
    {
        return ;
    }
    
    [self.view endEditing:YES];
    
    if (self.handler)
    {
        self.handler(YES, [_imagePickerView selectedImages], _textEditor.text, _locationInfo);
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    self.window.hidden = YES;
    self.window = nil ;
    [self.window resignKeyWindow];
    _secondShow = YES;
    
//    self.window.hidden = NO;
//    });
}

- (void)setBadgeNumber:(NSInteger)badge
{
    self.badge.hidden = !badge ;
    
    [self.badge setTitle:[NSString stringWithFormat:@"%zd",badge] forState:UIControlStateDisabled];
}

#pragma mark BBSUIExpressionViewDelegate

- (void)expressionView:(BBSUIExpressionView *)expressionView didSelectImageName:(NSString *)imageName
{
    [_textEditor setExpressionWithImageName:imageName fontSize:14];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_expView removeFromSuperview];
    
    return YES;
}
@end
