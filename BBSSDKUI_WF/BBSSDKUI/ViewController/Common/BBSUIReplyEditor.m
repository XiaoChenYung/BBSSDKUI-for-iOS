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

@interface BBSUIReplyEditor ()<iBBSUIImagePickerViewDelegate>
{
    NSTimeInterval _animationDuration;
}

@property (nonatomic ,strong) UIView *editorView;
@property (nonatomic ,strong) UITextField *textEditor ;
@property (nonatomic ,strong) UIButton *sendBtn;
@property (nonatomic ,strong) UIView *imagePickBar;
@property (nonatomic ,strong) UIButton *imagePickBtn;
@property (nonatomic ,strong) BBSUIImagePickerView *imagePickerView ;
@property (nonatomic ,copy) NSString *userName ;
@property (nonatomic ,strong) UIWindow *window ;
@property (nonatomic ,copy) FinishEditHandler handler ;
@property (nonatomic ,strong) UIButton *badge;

@end

@implementation BBSUIReplyEditor

- (void)showWithUserName:(NSString *)userName finishEdit:(FinishEditHandler)handler
{
    self.userName = userName ;
    self.handler = handler ;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelAlert - 1 ;
    UIView *backGroundView = [[UIView alloc] initWithFrame:self.window.bounds];
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0.25 ;
    [self.window addSubview:backGroundView];
    self.view.frame = self.window.bounds ;
    [self.window addSubview:self.view];
    [self.window makeKeyAndVisible];
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
        
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        sendBtn.backgroundColor = DZSUIColorFromHex(0x56BC8A);
        
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
        UITextField *textEditor = [[UITextField alloc] init];
        textEditor.placeholder = [@"回复: " stringByAppendingFormat:@"%@",_userName];
        
        [textFieldContainer addSubview:textEditor];
        
        [textEditor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(textFieldContainer).offset(15);
            make.right.equalTo(_sendBtn.mas_left).offset(-15);
            make.centerY.equalTo(textFieldContainer);
            make.height.equalTo(@49);
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
    
    [self.editorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-(50+45+height));
    }];
    
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
    if (self.handler)
    {
        self.handler(NO, [_imagePickerView selectedImages], _textEditor.text);
    }
    
    [self.window resignKeyWindow];
    self.window = nil ;
}

- (void)pickImages:(id)sender
{
    [_imagePickerView pickImages];
}

#pragma mark - iBBSUIImagePickerViewDelegate 

- (void)didBeginPickImages
{
    [self.textEditor setEnabled:NO];
    [self.textEditor resignFirstResponder];
}

- (void)didEndPickImages
{
    [self.textEditor setEnabled:YES];
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
        self.handler(YES, [_imagePickerView selectedImages], _textEditor.text);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.window resignKeyWindow];
        self.window = nil ;
    });
}

- (void)setBadgeNumber:(NSInteger)badge
{
    self.badge.hidden = !badge ;
    
    [self.badge setTitle:[NSString stringWithFormat:@"%zd",badge] forState:UIControlStateDisabled];
}

@end