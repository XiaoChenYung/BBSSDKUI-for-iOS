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
#import "BBSUIExpressionViewConfiguration.h"
#import "BBSUILBSLocationViewController.h"
#import "BBSUIForumViewController.h"
#import "BBSUILBSShowLocationViewController.h"
#import "BBSUILBSLocationProxy.h"


@interface BBSUIFastPostViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
{
    JSContext *_context ;
    BOOL _isRichTextEditor ;
}

//@property(nonatomic ,strong) UIImageView *headImageView;
//@property(nonatomic ,strong) UILabel *userNameLabel;
@property(nonatomic ,strong) UIButton *forumSelectBtn;
@property(nonatomic ,strong) UITextField *titleTextField;
@property(nonatomic ,strong) BBSUIRichTextEditor *editor;

@property(nonatomic ,strong) NSMutableArray *images;
@property(nonatomic ,strong) NSString *avatarUrl;
@property(nonatomic ,strong) NSMutableArray <id<iBBSUIFastPostViewControllerDelegate>> *delegates ;
@property(nonatomic, strong) NSMutableDictionary <NSString *, NSString *>*mdicExpression;

@property (nonatomic, strong) UIButton *publishButton;

@property (nonatomic, strong) UIButton *hideNameButton;

@property (nonatomic, strong) UIButton *checkMasterButton;

@property (nonatomic, strong) UIBarButtonItem *publishButtonItem;
@property (nonatomic, strong) UIBarButtonItem *hideNameButtonItem;
@property (nonatomic, strong) UIBarButtonItem *checkMasterButtonItem;

@property (nonatomic, strong) NSDictionary *locationInfo;

@property (nonatomic, strong) BBSUILBSLocationViewController *locationVC;
@property (nonatomic, strong) UINavigationController *locationNav;

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
        _mdicExpression = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"快速发帖";
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    _images = [NSMutableArray array];

    [self configUI];
    [self.titleTextField becomeFirstResponder];
    [self setupAsDraft];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.titleTextField becomeFirstResponder];
    
    BBSUser *currentUser = [BBSUIContext shareInstance].currentUser;
    if ([currentUser.allowAnonymous integerValue] == 0 && self.forum.allowAnonymous == 0)
    {
        self.hideNameButton.hidden = YES;
    }
    else
    {
        self.hideNameButton.hidden = NO;
    }
    
    self.hideNameButton.selected = NO;
}

- (void)setNavigationItems
{
    //取消
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -8;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(0, 0, 44, 44)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelButton setTitleColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems = @[fixedButton, [[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
    
    //发布
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [publishButton setFrame:CGRectMake(0, 0, 44, 44)];
    [publishButton setTitle:@"发布" forState:UIControlStateNormal];
    [publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(publishButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [publishButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    BBSUser *currentUser = [BBSUIContext shareInstance].currentUser;
//    if ([currentUser.allowAnonymous integerValue])
//    {
        //匿名
        UIButton *hideNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideNameBtn setFrame:CGRectMake(0, 0, 64, 44)];
        [hideNameBtn setTitle:@" 匿名" forState:UIControlStateNormal];
        [hideNameBtn setImage:[UIImage BBSImageNamed:@"/Thread/hideName@3x.png"] forState: UIControlStateNormal];
        [hideNameBtn setImage:[UIImage BBSImageNamed:@"/Thread/hideNameSelect@3x.png"] forState: UIControlStateSelected];
        [hideNameBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        hideNameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [hideNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [hideNameBtn addTarget:self action:@selector(hideNamebtnHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.hideNameButton = hideNameBtn;
    
    //楼主
    UIButton *checkMasterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkMasterButton.frame = CGRectMake(0, 0, 130, 44);
    [checkMasterButton setTitle:@" 回贴仅楼主可见" forState:UIControlStateNormal];
    [checkMasterButton setImage:[UIImage BBSImageNamed:@"/Thread/hideName@3x.png"] forState: UIControlStateNormal];
    [checkMasterButton setImage:[UIImage BBSImageNamed:@"/Thread/hideNameSelect@3x.png"] forState: UIControlStateSelected];
    [checkMasterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    checkMasterButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [checkMasterButton addTarget:self action:@selector(checkMasterbtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.checkMasterButton = checkMasterButton;
    
    self.publishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    self.hideNameButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hideNameBtn];
    self.checkMasterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkMasterButton];
    
        self.navigationItem.rightBarButtonItems = @[self.publishButtonItem, self.hideNameButtonItem,self.checkMasterButtonItem];
//    }
//    else
//    {
//        self.navigationItem.rightBarButtonItems = @[fixedButton, [[UIBarButtonItem alloc] initWithCustomView:publishButton]];
//    }
    
    if ([currentUser.allowAnonymous integerValue] == 0 && self.forum.allowAnonymous == 0)
    {
        self.hideNameButton.hidden = YES;
        self.navigationItem.rightBarButtonItems = @[self.publishButtonItem,self.checkMasterButtonItem];
    }
}

#pragma mark - 取消
- (void)cancelButtonHandler:(UIButton *)button
{
    self.checkMasterButton.selected = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configUI
{
    [self setNavigationItems];
    self.forumSelectBtn =
    ({
        UIButton *forumSelectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        forumSelectBtn.layer.borderWidth = 1.0;
        forumSelectBtn.layer.cornerRadius = 3.0;
        forumSelectBtn.layer.borderColor = DZSUIColorFromHex(0x5B7EF0).CGColor;
        [forumSelectBtn setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
        [forumSelectBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        if (_forum)
        {
            [forumSelectBtn setTitle:[NSString stringWithFormat:@" %@ ",_forum.name] forState:UIControlStateNormal];
        }
        else
        {
            [forumSelectBtn setTitle:@" 选择版块 " forState:UIControlStateNormal];
        }
        [forumSelectBtn addTarget:self action:@selector(selectForum:) forControlEvents:UIControlEventTouchUpInside];
        [forumSelectBtn setContentEdgeInsets:UIEdgeInsetsMake(3.5, 18, 3.5, 18)];
        [self.view addSubview:forumSelectBtn];
        [forumSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(14);
            make.height.equalTo(@26);
//            make.width.equalTo(@75);
        }];
        forumSelectBtn ;
    });
    
    UIView *seperateView = [UIView new];
    [self.view addSubview:seperateView];
    [seperateView setBackgroundColor:[UIColor darkGrayColor]];
    [seperateView setAlpha:0.25];
    [seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forumSelectBtn.mas_bottom).with.offset(13);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(@1);
    }];

    self.titleTextField =
    ({
        UITextField *titleTextField = [[UITextField alloc] init];
        titleTextField.placeholder = @"请输入帖子标题";
        titleTextField.delegate = self;
        [titleTextField setFont:[UIFont systemFontOfSize:18]];
        [self.view addSubview:titleTextField];
        [titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.forumSelectBtn.mas_bottom).offset(11);
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
        
        if ([[BBSUILBSLocationProxy sharedInstance] isLBSUsable]) {
            editor.isHiddenLBSMenu = NO;
        }else
        {
            editor.isHiddenLBSMenu = YES;
        }
        
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
    [self.view endEditing:YES];
    
    if (!_isRichTextEditor)
    {
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popoverController = alertVC.popoverPresentationController;
    popoverController.sourceView = self.view;
    popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,DZSUIScreen_height - 112,1.0,1.0);
    
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

- (void)expressionView:(BBSUIExpressionView *)expressionView didSelectImageName:(NSString *)imageName
{
    NSString *originHtml = [self.editor getHTML];
    
    NSString *expKey = [BBSUIExpressionTool getExpressionStringWithImageName:imageName];
    
    NSString *name = imageName;
    if ([name hasSuffix:@".gif"])
    {
        name = [imageName substringToIndex:imageName.length - 4];
    }
    name = [NSString stringWithFormat:@"BBSSDKUI.bundle/Emoji/%@",name];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    
    NSString *trigger = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" style=\"max-width:%fpx;\"/>",path,@"emoji",20.0];
    
    [self.editor focusTextEditor];
    [self.editor insertHTML:trigger];
    [self.view endEditing:YES];
    
    NSString *nowHtml = [self.editor getHTML];
    
    [_mdicExpression setObject:[nowHtml substringFromIndex:originHtml.length] forKey:expKey];
}

- (void)openLBS
{
    __weak typeof(self)weakSelf = self;
    if (_locationVC == nil) {
        _locationVC = [[BBSUILBSLocationViewController alloc] init];
    }
    _locationVC.locationSelectBlock = ^(id locationInfo) {
        NSDictionary *info = (NSDictionary *)locationInfo;
        weakSelf.locationInfo = info;
        if (info == nil) {
            weakSelf.editor.addressTag = nil;
        }else{
            weakSelf.editor.addressTag = [info valueForKey:@"name"];
        }
    };
    _locationVC.preLocationDic = self.locationInfo;
    if (_locationNav == nil) {
         _locationNav = [[UINavigationController alloc] initWithRootViewController:_locationVC];
    }
    _locationVC.isPresent = YES;
    [self presentViewController:_locationNav animated:YES completion:nil];

}

- (void)showLBS
{
    NSString *poiTitle = self.locationInfo[@"name"];
    CGFloat lat = 0;
    CGFloat lon = 0;
    NSArray *arr = [self.locationInfo[@"location"] componentsSeparatedByString:@","];
    if ([arr count] == 2) {
        lat = [[self.locationInfo[@"location"] componentsSeparatedByString:@","].firstObject floatValue];
        lon = [[self.locationInfo[@"location"] componentsSeparatedByString:@","].lastObject floatValue];
    }
    
    CLLocationCoordinate2D coordinate = {lat,lon};
    BBSUILBSShowLocationViewController *showLocationVC = [[BBSUILBSShowLocationViewController alloc] initWithCoordinate:coordinate title:poiTitle];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showLocationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 选择版块
- (void)selectForum:(id)sender
{
    __weak typeof(self)weakSelf = self;
    BBSUIThreadForumListSelectViewController * vc = [[BBSUIThreadForumListSelectViewController alloc] initWithResult:^(BBSForum *selectedForum) {
        if([selectedForum isKindOfClass:[BBSForum class]])
        {
            weakSelf.forum = selectedForum ;
            
            BBSUser *currentUser = [BBSUIContext shareInstance].currentUser;
            if ([currentUser.allowAnonymous integerValue] || selectedForum.allowAnonymous)
            {
                weakSelf.hideNameButton.hidden = NO;
                weakSelf.navigationItem.rightBarButtonItems = @[weakSelf.publishButtonItem,weakSelf.hideNameButtonItem,weakSelf.checkMasterButtonItem];
            }
            else
            {
                weakSelf.hideNameButton.hidden = YES;
                weakSelf.navigationItem.rightBarButtonItems = @[weakSelf.publishButtonItem,weakSelf.checkMasterButtonItem];
            }
        }
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 发布
- (void)publishButtonHandler:(UIButton *)button
{
    [self.editor hideKeyboard];
    
    // 验证发帖间隔是否符合要求
    NSDictionary *settings = [BBSUIContext shareInstance].settings;
    if (settings[@"floodctrl"] && [settings[@"floodctrl"] integerValue] != 0)
    {
        NSInteger timeOffset = [settings[@"floodctrl"] integerValue];
        
        NSInteger lastime = [BBSUIContext shareInstance].lastFastPostTime;
        NSLog(@"lastTime = %lu",lastime);
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        
        
        if (currentTime - lastime < timeOffset)
        {
            [BBSUIProcessHUD showFailInfo:[NSString stringWithFormat:@"发帖间隔小于%lu秒",timeOffset] delay:2];
            return;
        }
    }
    
    if (!_forum)
    {
        [BBSUIProcessHUD showFailInfo:@"请选择版块" delay:2];
        return;
    }
    
    if (_titleTextField.text.length < 2)
    {
        [BBSUIProcessHUD showFailInfo:@"标题不少于2个字" delay:2];
        return;
    }
    
    NSString *originHtml = [self.editor getHTML];
    
    if (originHtml.length < 5 || [originHtml isEqualToString:@"<br />"])
    {
        [BBSUIProcessHUD showFailInfo:@"内容不少于5个字" delay:2];
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
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self postThread];
    self.checkMasterButton.selected = NO;
 }

- (void)hideNamebtnHandler:(UIButton *)button
{
    button.selected = !button.selected;
    
}

- (void)checkMasterbtnHandler:(UIButton *)button
{
    button.selected = !button.selected;
}

- (NSString *)_replaceExpressionWithUrl:(NSMutableString *)url key:(NSString *)key obj:(NSString *)obj
{
    NSMutableString *urlHtml = url;
    
    NSRange range = [urlHtml rangeOfString:obj];
    if (range.location != NSNotFound) {
        [urlHtml replaceOccurrencesOfString:obj withString:key options:NSLiteralSearch  range:range];
        
        [self _replaceExpressionWithUrl:urlHtml key:key obj:obj];
    }
    
    return urlHtml;
}

- (void)postThread
{
    __block NSMutableString *urlHtml = [self.editor getHTML].mutableCopy;
    
    [_mdicExpression enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        
        //        [urlHtml stringByReplacingOccurrencesOfString:obj withString:key];
        
        urlHtml.string = [self _replaceExpressionWithUrl:urlHtml.mutableCopy key:key obj:obj];
        
        //        NSRange range = [urlHtml rangeOfString:obj];
        //        if (range.location != NSNotFound) {
        //            [urlHtml replaceOccurrencesOfString:obj withString:key options:NSLiteralSearch  range:range];
        //
        //            [_mdicExpression removeObjectForKey:key];
        //        }
        
        NSString *obj2 = [obj substringFromIndex:1];
        urlHtml.string = [self _replaceExpressionWithUrl:urlHtml.mutableCopy key:key obj:obj2];
        
        //        NSRange range2 = [urlHtml rangeOfString:[obj substringFromIndex:2]];
        //        if (range2.location != NSNotFound) {
        //            [urlHtml replaceOccurrencesOfString:obj withString:key options:NSLiteralSearch  range:range2];
        //            [_mdicExpression removeObjectForKey:key];
        //        }
    }];
    
    NSString *title = self.titleTextField.text;
    
    static dispatch_semaphore_t seamphore;
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    
    dispatch_once(&onceToken, ^{
        seamphore = dispatch_semaphore_create(1);
        queue = dispatch_queue_create("uploadImage", DISPATCH_QUEUE_CONCURRENT);
    });
    
    _context = [self.editor.editorView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *value = [_context evaluateScript:@"bbsui_editor.getImages()"];
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
                        NSLog(@"%@",error);
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
    // 是否匿名发帖
    NSInteger isanonymous = 0;
    if (self.hideNameButton.isSelected && self.hideNameButton.isHidden == NO)
    {
        isanonymous = 1;
    }
    
    NSInteger hiddenreplies = 0;
    if (self.checkMasterButton.isSelected) {
        hiddenreplies = 1;
    }
    
    [BBSUIContext shareInstance].lastFastPostTime = [[NSDate date]timeIntervalSince1970];
    
    NSString *address = @"";
    NSString *poiTitle = @"";
    float lat = 0;
    float lng = 0;
    BBSLocation *location = nil;
    if (self.locationInfo) {
        poiTitle = self.locationInfo[@"name"];
        address = self.locationInfo[@"address"];
        NSArray *arr = [self.locationInfo[@"location"] componentsSeparatedByString:@","];
        if ([arr count] == 2) {
            lat = [[self.locationInfo[@"location"] componentsSeparatedByString:@","].firstObject floatValue];
            lng = [[self.locationInfo[@"location"] componentsSeparatedByString:@","].lastObject floatValue];
        }
        location = [[BBSLocation alloc] initWithPOITitle:poiTitle address:address latitude:lat longitude:lng];
    }

    [BBSSDK postThreadWithFid:_forum.fid subject:_titleTextField.text message:html isanonymous:isanonymous hiddenreplies:hiddenreplies location:location result:^(NSError *error) {
        
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
    
    self.editor.addressTag = nil;
    self.locationInfo = nil;
    self.locationNav = nil;
    self.locationVC = nil;
}

- (void)postError:(NSError *)error title:(NSString *)title html:(NSString *)html
{
    NSLog(@"%@",error);
    
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
        NSLog(@"saving draft:%@",draft);
        [draft save];
        [self setupAsDraft];
    }
    
    [self alertError:error];
}

- (void)alertError:(NSError *)error
{
    NSString *des = [NSString stringWithFormat:@"前一个发帖失败，失败原因:%@",error.userInfo[@"description"]];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:des preferredStyle:UIAlertControllerStyleAlert];
    UIPopoverPresentationController *popoverController = vc.popoverPresentationController;
    popoverController.sourceView = self.view;
    popoverController.sourceRect = CGRectMake(DZSUIScreen_width/2,self.view.frame.size.height,1.0,1.0);
    
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
//    if (![self.currentForum.name isEqualToString:@"全部"] && self.currentForum.fid != 0)
//    {
//        [editVC setForum:_currentForum];
//    }
    if (forum && forum.fid != 0)
    {
        _forum = forum ;
        [self.forumSelectBtn setTitle:[NSString stringWithFormat:@" %@ ",forum.name] forState:UIControlStateNormal];
        [self.forumSelectBtn sizeToFit];
    }
    else
    {
        _forum = nil;
        [self.forumSelectBtn setTitle:@" 选择版块 " forState:UIControlStateNormal];
        [self.forumSelectBtn sizeToFit];
    }
}

- (void)setupAsDraft
{
    BBSUIThreadDraft *cachedThread = [BBSUIThreadDraft savedDraft];
    
    NSLog(@"cached draft : %@",cachedThread);
    
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
