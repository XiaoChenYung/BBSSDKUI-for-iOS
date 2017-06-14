//
//  BBSUIFastPostViewController.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIFastPostViewController.h"
#import "BBSUIRichTextEditor.h"
#import "Masonry.h"
#import "BBSUIThreadForumListSelectViewController.h"
#import <BBSSDK/BBSSDK.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "BBSUIReplyEditor.h"
#import "BBSForum+BBSUI.h"
#import "BBSUIProcessHUD.h"
#import "BBSUIContext.h"
#import "BBSUIThreadDraft.h"

@interface BBSUIFastPostViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
{
    JSContext *_context ;
    BOOL _isRichTextEditor ;
}

@property(nonatomic ,strong) UIImageView *headImageView;
@property(nonatomic ,strong) UILabel *userNameLabel;
@property(nonatomic ,strong) UIButton *forumSelectBtn;
@property(nonatomic ,strong) UITextField *titleTextField;
@property(nonatomic ,strong) BBSUIRichTextEditor *editor;
@property(nonatomic ,strong) BBSForum *forum;
@property(nonatomic ,strong) NSMutableArray *images;
@property(nonatomic ,strong) NSString *avatarUrl;
@property(nonatomic ,strong) NSMutableArray <id<iBBSUIFastPostViewControllerDelegate>> *delegates ;

@end

@implementation BBSUIFastPostViewController

+ (instancetype)shareInstance
{
    static BBSUIFastPostViewController *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BBSUIFastPostViewController alloc] init];
    });
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _delegates = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    _images = [NSMutableArray array];

    [self configUI];
    [self.titleTextField becomeFirstResponder];
    [self setupAsDraft];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *url = [BBSUIContext shareInstance].currentUser.avatar ;
    url = [url stringByAppendingFormat:@"&timestamp=%f", [NSDate date].timeIntervalSince1970];
    if ([url isKindOfClass:NSString.class] && ![_avatarUrl isEqualToString:url])
    {
        [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:url] result:^(UIImage *image, NSError *error) {
            if (error)
            {
                BBSUILog(@"%@",error);
            }
            else
            {
                _headImageView.image = image;
            }
        }];
        
        _userNameLabel.text = [BBSUIContext shareInstance].currentUser.userName;
    }
}

- (void)configUI
{
    self.title = @"快速发帖";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    
    self.headImageView =
    ({
        UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage BBSImageNamed:@"/User/AvatarDefault.png"]];
        headImageView.layer.cornerRadius = 15.5;
        headImageView.clipsToBounds = YES;
        headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(11);
            make.width.height.equalTo(@31);
        }];
        headImageView ;
    });

    self.userNameLabel =
    ({
        UILabel *userNameLabel = [[UILabel alloc] init];
        userNameLabel.textColor = [UIColor blackColor];
        userNameLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:userNameLabel];
        [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImageView.mas_right).offset(10);
            make.centerY.equalTo(_headImageView);
        }];
        userNameLabel ;
    });
    
    self.forumSelectBtn =
    ({
        UIButton *forumSelectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        forumSelectBtn.layer.borderWidth = 1.0;
        forumSelectBtn.layer.cornerRadius = 2.0;
        forumSelectBtn.layer.borderColor = DZSUIColorFromHex(0x007aff).CGColor;
        [forumSelectBtn setTitle:@" 选择版块 " forState:UIControlStateNormal];
        [forumSelectBtn addTarget:self action:@selector(selectForum:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:forumSelectBtn];
        [forumSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view).offset(13);
            make.height.equalTo(@26);
//            make.width.equalTo(@75);
        }];
        forumSelectBtn ;
    });

    self.titleTextField =
    ({
        UITextField *titleTextField = [[UITextField alloc] init];
        titleTextField.placeholder = @"请输入帖子标题";
        titleTextField.delegate = self;
        [self.view addSubview:titleTextField];
        [titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(_headImageView.mas_bottom).offset(11);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@50);
        }];
        
        titleTextField ;
    });
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor darkGrayColor];
    line.alpha = 0.25 ;
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_titleTextField.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    self.editor =
    ({
        BBSUIRichTextEditor *editor = [[BBSUIRichTextEditor alloc] init];
        [self addChildViewController:editor];
        [self.view addSubview:editor.view];
        [editor.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(line.mas_bottom).offset(5);
        }];
        editor ;
    });
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //Dismiss the Image Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage *scaleImage = [selectedImage scaleImage];
    
    NSString *cachePath = [self pathOfsavedImage:scaleImage];

    NSString *trigger = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" style=\"max-width:%fpx;\"/>",cachePath,@"BBSUI",self.view.frame.size.width - 27];
    
    [self.editor focusTextEditor];
    [self.editor insertHTML:trigger];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickImages
{
    if (!_isRichTextEditor)
    {
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *pickImg = [UIAlertAction actionWithTitle:@"从手机相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImgInAlbum];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:takePhoto];
    [alertVC addAction:pickImg];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        BBSUIAlert(@"相机不可用,设置开启相机权限才能继续使用哦");
        return ;
    }
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraVc.delegate = self;
    [self presentViewController:cameraVc animated:YES completion:nil];
}

- (void)pickImgInAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        BBSUIAlert(@"图库不可用,设置开启图库权限才能继续使用哦");
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraVc.delegate = self;
    [self presentViewController:cameraVc animated:YES completion:nil];
}

#pragma mark - click event

- (void)selectForum:(id)sender
{
    BBSUIThreadForumListSelectViewController * vc = [[BBSUIThreadForumListSelectViewController alloc] initWithResult:^(BBSForum *selectedForum) {
        if([selectedForum isKindOfClass:[BBSForum class]])
        {
            self.forum = selectedForum ;
        }
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)confirm
{
    if (!_forum)
    {
        [BBSUIProcessHUD showFailInfo:@"请选择版块"];
        return;
    }
    
    if (!_titleTextField.text.length)
    {
        [BBSUIProcessHUD showFailInfo:@"请填写标题"];
        return;
    }
    
    NSString *originHtml = [self.editor getHTML];
    
    if (!originHtml.length || [originHtml isEqualToString:@"<br />"])
    {
        [BBSUIProcessHUD showFailInfo:@"请填写内容"];
        return;
    }
    
    [self.view endEditing:YES];
    
    for (id<iBBSUIFastPostViewControllerDelegate> obj in _delegates)
    {
        if ([obj respondsToSelector:@selector(didBeginPostThread)])
        {
            [obj didBeginPostThread];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self postThread];
    
 }

- (void)postThread
{
    NSMutableString *urlHtml = [self.editor getHTML].mutableCopy;
    
    NSString *title = self.titleTextField.text;
    
    static dispatch_semaphore_t seamphore;
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    
    dispatch_once(&onceToken, ^{
        seamphore = dispatch_semaphore_create(1);
        queue = dispatch_queue_create("uploadImage", DISPATCH_QUEUE_CONCURRENT);
    });
    
    _context = [self.editor.editorView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *value = [_context evaluateScript:@"zss_editor.getImages()"];
    NSArray *imageJsons = value.toArray ;
    
    if (!imageJsons.count)
    {
        [self postThreadWithHTML:urlHtml];
        return ;
    }
    
    __block NSError *uploadError;

    for (NSInteger i=0; i<imageJsons.count;i++)
    {
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(seamphore, DISPATCH_TIME_FOREVER);
        
            NSString *imageTag = imageJsons[i];
            
            if ([imageTag rangeOfString:@"/var/mobile"].location == NSNotFound)
            {
                if (i==imageJsons.count-1)
                {
                    if (uploadError)
                    {
                        [self postError:uploadError title:title html:urlHtml];
                    }
                    else
                    {
                        [self postThreadWithHTML:urlHtml];
                    }
                }
                
                dispatch_semaphore_signal(seamphore);
            }
            else
            {
                [BBSSDK uploadImageWithContentPath:imageTag result:^(NSString *url, NSError *error) {
                    
                    if (!error && url)
                    {
                        NSRange range = [urlHtml rangeOfString:[imageTag substringFromIndex:7]];
                        [urlHtml replaceCharactersInRange:range withString:url];
                    }
                    else
                    {
                        BBSUILog(@"%@",error);
                        uploadError = error;
                    }
                    
                    dispatch_semaphore_signal(seamphore);
                    
                    if (i==imageJsons.count-1)
                    {
                        if (uploadError)
                        {
                            [self postError:error title:title html:urlHtml];
                        }
                        else
                        {
                            [self postThreadWithHTML:urlHtml];
                        }
                    }
                }];
            }
        });
    }

}

- (void)postThreadWithHTML:(NSString *)html
{
    [BBSSDK postThreadWithFid:_forum.fid subject:_titleTextField.text message:html token:[BBSUIContext shareInstance].currentUser.token result:^(NSError *error) {
        
        if (!error)
        {
            [self postSuccess];
        }
        else
        {
            [self postError:error title:_titleTextField.text html:html];
        }
    }];

}

- (void)postSuccess
{
    for (id<iBBSUIFastPostViewControllerDelegate> obj in _delegates)
    {
        if ([obj respondsToSelector:@selector(didPostSuccess)])
        {
            [obj didPostSuccess];
        }
    }
    
    [BBSUIThreadDraft deleteCachedDraft];
    
    [self.editor setHTML:@""];
    self.titleTextField.text = @"";
    self.forum = nil;
}

- (void)postError:(NSError *)error title:(NSString *)title html:(NSString *)html
{
    BBSUILog(@"%@",error);
    
    if (error.code == 9001200)
    {
        [BBSUIContext shareInstance].currentUser = nil;
    }
    
    for (id<iBBSUIFastPostViewControllerDelegate> obj in _delegates)
    {
        if ([obj respondsToSelector:@selector(didPostFailWithError:)])
        {
            [obj didPostFailWithError:error];
        }
    }
        
    if (title.length && html.length)
    {
        BBSUIThreadDraft *draft = [[BBSUIThreadDraft alloc] init];
        draft.title = title;
        draft.html = html;
        draft.forum = _forum;
        BBSUILog(@"saving draft:%@",draft);
        [draft save];
        [self setupAsDraft];
    }
    
    [self alertError:error];
}

- (void)alertError:(NSError *)error
{
    NSString *des = [NSString stringWithFormat:@"前一个发帖失败，失败原因:%@",error.userInfo[@"description"]];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:des preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancel];
    
    UIAlertAction *repost = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self postThread];
    }];
    [vc addAction:repost];
    
    UIViewController *baseVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [baseVC presentViewController:vc animated:YES completion:nil];
}

- (NSString *)pathOfsavedImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imageMd5 = [MOBFData stringByMD5Data:data];
    
    NSString *path = [imageMd5 stringByAppendingString:@".JPEG"];
    
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createFileAtPath:cachePath contents:nil attributes:nil];
        [data writeToFile:cachePath atomically:NO];
    }
    return cachePath ;
}

- (void)setForum:(BBSForum *)forum
{
    _forum = forum ;
    
    if (_forum)
    {
        [self.forumSelectBtn setTitle:[NSString stringWithFormat:@" %@ ",forum.name] forState:UIControlStateNormal];
        [self.forumSelectBtn sizeToFit];
    }
    else
    {
        [self.forumSelectBtn setTitle:@" 选择版块 " forState:UIControlStateNormal];
        [self.forumSelectBtn sizeToFit];
    }
}

- (void)setupAsDraft
{
    BBSUIThreadDraft *cachedThread = [BBSUIThreadDraft savedDraft];
    
    BBSUILog(@"cached draft : %@",cachedThread);
    
    if (cachedThread)
    {
        if (cachedThread.html)
        {
            [self.editor setHTML:cachedThread.html];
        }
        self.titleTextField.text = cachedThread.title;
        self.forum = cachedThread.forum;
    }
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _isRichTextEditor = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _isRichTextEditor = YES;
}

- (void)addPostThreadObserver:(id<iBBSUIFastPostViewControllerDelegate>) observer
{
    if (![_delegates containsObject:observer])
    {
        [self.delegates addObject:observer];
    }
}

- (void)removePostThreadObserver:(id<iBBSUIFastPostViewControllerDelegate>) observer
{
    if ([_delegates containsObject:observer])
    {
        [self.delegates removeObject:observer];
    }
}

@end
