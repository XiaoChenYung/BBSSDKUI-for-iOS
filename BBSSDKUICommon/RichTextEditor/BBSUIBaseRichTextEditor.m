
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "BBSUIBaseRichTextEditor.h"
#import "BBSUIRTEBarButtonItem.h"
#import "BBSUIHRColorUtil.h"
#import "BBSUIRTETextView.h"
#import "UIImage+BBSFunction.h"
#import "NSBundle+BBSSDKUI.h"
#import "BBSUIExpressionViewConfiguration.h"
#import <BBSSDK/BBSSDK.h>

@import JavaScriptCore;


/**
 
 UIWebView modifications for hiding the inputAccessoryView
 
 **/
@interface UIWebView (HackishAccessoryHiding)
@property (nonatomic, assign) BOOL hidesInputAccessoryView;
@end

@implementation UIWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value {
    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
    
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("UIWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end

static BOOL keyBoardHidden = NO;

@interface BBSUIBaseRichTextEditor ()<BBSUIExpressionViewDelegate>

/*
 *  Scroll view containing the toolbar
 */
@property (nonatomic, strong) UIScrollView *toolBarScroll;

/*
 *  Toolbar containing BBSUIBarButtonItems
 */
@property (nonatomic, strong) UIToolbar *toolbar;

/*
 *  Holder for all of the toolbar components
 */
@property (nonatomic, strong) UIView *toolbarHolder;

/*
 *  String for the HTML
 */
@property (nonatomic, strong) NSString *htmlString;

/*
 *  BBSUITextView for displaying the source code for what is displayed in the editor view
 */
@property (nonatomic, strong) BBSUIRTETextView *sourceView;

/*
 *  CGRect for holding the frame for the editor view
 */
@property (nonatomic) CGRect editorViewFrame;

/*
 *  BOOL for holding if the resources are loaded or not
 */
@property (nonatomic) BOOL resourcesLoaded;

/*
 *  Array holding the enabled editor items
 */
@property (nonatomic, strong) NSArray *editorItemsEnabled;

/*
 *  Alert View used when inserting links/images
 */
@property (nonatomic, strong) UIAlertView *alertView;

/*
 *  NSString holding the selected links URL value
 */
@property (nonatomic, strong) NSString *selectedLinkURL;

/*
 *  NSString holding the selected links title value
 */
@property (nonatomic, strong) NSString *selectedLinkTitle;

/*
 *  NSString holding the selected image URL value
 */
@property (nonatomic, strong) NSString *selectedImageURL;

/*
 *  NSString holding the selected image Alt value
 */
@property (nonatomic, strong) NSString *selectedImageAlt;

/*
 *  CGFloat holdign the selected image scale value
 */
@property (nonatomic, assign) CGFloat selectedImageScale;

/*
 *  NSString holding the base64 value of the current image
 */
@property (nonatomic, strong) NSString *imageBase64String;

/**
 costom item for BBSUI
 */
@property (nonatomic, strong) UIBarButtonItem *imagePickItem;

/*
 *  Bar button item for the keyboard dismiss button in the toolbar
 */
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;

@property (nonatomic, strong) UIBarButtonItem *arrowItem;

@property (nonatomic, strong) UIButton *imagePickButton;//图片选择按钮
@property (nonatomic, strong) UIButton *keyboardButton;//键盘按钮
@property (nonatomic, strong) UIButton *arrowButton;//箭头按钮
@property (nonatomic, strong) UIBarButtonItem *expressionItem;//表情按钮
@property (nonatomic, strong) UIBarButtonItem *lbsItem;//LBS定位 按钮
@property (nonatomic, strong) UIButton *lbsTagView;

@property (nonatomic, strong) BBSUIExpressionView *expView;
@property (nonatomic, assign) BOOL showExpView;
@property (nonatomic, assign) BOOL keyboardIsAppear;
@property (nonatomic, assign) BOOL isInputExpression;

@property (nonatomic, assign) CGFloat keyboardHeight;

/*
 *  Array for custom bar button items
 */
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;

/*
 *  Array for custom BBSUIBarButtonItems
 */
@property (nonatomic, strong) NSMutableArray *customBBSUIBarButtonItems;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;

/*
 *  NSString holding the css
 */
@property (nonatomic, strong) NSString *customCSS;

/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

/*
 *  Image Picker for selecting photos from users photo library
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/*
 *  Method for getting a version of the html without quotes
 */
- (NSString *)removeQuotesFromHTML:(NSString *)html;

/*
 *  Method for getting a tidied version of the html
 */
- (NSString *)tidyHTML:(NSString *)html;

/*
 * Method for enablign toolbar items
 */
- (void)enableToolbarItems:(BOOL)enable;

/*
 *  Setter for isIpad BOOL
 */
- (BOOL)isIpad;

@end

/*
 
 BBSUIBaseRichTextEditor
 
 */
@implementation BBSUIBaseRichTextEditor

//Scale image from device
static CGFloat kJPEGCompression = 0.8;
static CGFloat kDefaultScale = 0.5;

#pragma mark - View Did Load Section
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Initialise variables
    self.editorLoaded = NO;
    self.receiveEditorDidChangeEvents = NO;
    self.alwaysShowToolbar = NO;
    self.shouldShowKeyboard = YES;
    self.formatHTML = YES;
    
    //Initalise enabled toolbar items array
    self.enabledToolbarItems = [[NSArray alloc] init];
    
    //Frame for the source view and editor view
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    //Source View
    [self createSourceViewWithFrame:frame];
    
    //Editor View
    [self createEditorViewWithFrame:frame];
    
    //Image Picker used to allow the user insert images from the device (base64 encoded)
    [self setUpImagePicker];
    
    //Scrolling View
    [self createToolBarScroll];
    
    //Toolbar with icons
    [self createToolbar];
    
    //Parent holding view
    [self createParentHoldingView];
    
    //Hide Keyboard
    if (1) {
        
        CGFloat toolbarCropperW = 214;
        
        if (self.uiStyleType == BBSUIRTEStyleTypeTwo) {
            // Toolbar holder used to crop and position toolbar
            UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-toolbarCropperW, 40, toolbarCropperW, 44)];
            toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            toolbarCropper.clipsToBounds = YES;
            
//            self.imagePickButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            [self.imagePickButton setFrame:CGRectMake(0, 0, 44, 44)];
//            [self.imagePickButton setImage:[UIImage BBSImageNamed:@"/RichEditor/PictureSelect.png"] forState:UIControlStateNormal];
//            [toolbarCropper addSubview:self.imagePickButton];
//            
//            self.keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            [self.keyboardButton setFrame:CGRectMake(44, 0, 44, 44)];
//            [self.keyboardButton setImage:[UIImage BBSImageNamed:@"/RichEditor/KeyboardButton.png"] forState:UIControlStateNormal];
//            [toolbarCropper addSubview:self.keyboardButton];
//            
//            self.arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            [self.arrowButton setFrame:CGRectMake(88, 0, 44, 44)];
//            [self.arrowButton setImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIArrowDown.png"] forState:UIControlStateNormal];
//            [toolbarCropper addSubview:self.arrowButton];
            
//            UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -1, toolbarCropperW, 44)];
//            [toolbarCropper addSubview:keyboardToolbar];
            
            UIView *keyboardTollbarView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, toolbarCropperW, 44)];
            [toolbarCropper addSubview:keyboardTollbarView];
            
            
            // 选择地址
            UIButton *lbsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [lbsButton setFrame:CGRectMake(10, 7, 30, 30)];
            [lbsButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [lbsButton setImage:[UIImage BBSImageNamed:@"/LBS/LBS_max_icon@2x.png"] forState:UIControlStateNormal];
            [lbsButton addTarget:self action:@selector(lbsButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.lbsItem = [[UIBarButtonItem alloc] initWithCustomView:lbsButton];
            
            // 表情
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [faceButton setFrame:CGRectMake(50, 7, 30, 30)];
            [faceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [faceButton setImage:[UIImage BBSImageNamed:@"/Thread/Face@2x.png"] forState:UIControlStateNormal];
            [faceButton addTarget:self action:@selector(faceButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.expressionItem = [[UIBarButtonItem alloc] initWithCustomView:faceButton];
            
            
            UIButton *imagePickButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [imagePickButton setFrame:CGRectMake(90, 7, 30, 30)];
            [imagePickButton setImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIPictureSelect@2x.png"] forState:UIControlStateNormal];
            [imagePickButton addTarget:self action:@selector(pickImages:) forControlEvents:UIControlEventTouchUpInside];
            self.imagePickItem = [[UIBarButtonItem alloc] initWithCustomView:imagePickButton];
            
            UIButton *keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [keyboardButton setFrame:CGRectMake(130, 7, 30, 30)];
            [keyboardButton setImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIKeyboardButton@2x.png"] forState:UIControlStateNormal];
            [keyboardButton addTarget:self action:@selector(keyboardButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.keyboardItem = [[UIBarButtonItem alloc] initWithCustomView:keyboardButton];
            
            UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [arrowButton setFrame:CGRectMake(170, 0, 44, 44)];
            [arrowButton setImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIArrowDown@2x.png"] forState:UIControlStateNormal];
            [arrowButton addTarget:self action:@selector(arrowButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.arrowItem = [[UIBarButtonItem alloc] initWithCustomView:arrowButton];
            
//            keyboardToolbar.items = @[self.expressionItem, self.imagePickItem, self.keyboardItem, self.arrowItem];
            [keyboardTollbarView addSubview:self.lbsItem.customView];
            [keyboardTollbarView addSubview:self.expressionItem.customView];
            [keyboardTollbarView addSubview:self.imagePickItem.customView];
            [keyboardTollbarView addSubview:self.keyboardItem.customView];
            [keyboardTollbarView addSubview:self.arrowItem.customView];
            
            [self.toolbarHolder addSubview:toolbarCropper];
            
        }else{
            CGFloat toolbarCropperW = 170;
            
            // Toolbar holder used to crop and position toolbar
            UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-toolbarCropperW, 40, toolbarCropperW, 44)];
            toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            toolbarCropper.clipsToBounds = YES;
            
            // Use a toolbar so that we can tint
            UIView *keyboardTollbarView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, toolbarCropperW, 44)];
            [toolbarCropper addSubview:keyboardTollbarView];
            
            // 选择地址
            UIButton *lbsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [lbsButton setFrame:CGRectMake(10, 7, 30, 30)];
            [lbsButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [lbsButton setImage:[UIImage BBSImageNamed:@"/LBS/LBS_max_icon@2x.png"] forState:UIControlStateNormal];
            [lbsButton addTarget:self action:@selector(lbsButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.lbsItem = [[UIBarButtonItem alloc] initWithCustomView:lbsButton];
            
            // 表情
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [faceButton setFrame:CGRectMake(50, 7, 30, 30)];
            [faceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [faceButton setImage:[UIImage BBSImageNamed:@"/Thread/Face@2x.png"] forState:UIControlStateNormal];
            [faceButton addTarget:self action:@selector(faceButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
            self.expressionItem = [[UIBarButtonItem alloc] initWithCustomView:faceButton];
            
            UIButton *imagePickButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [imagePickButton setFrame:CGRectMake(90, 7, 30, 30)];
            [imagePickButton setImage:[UIImage BBSImageNamed:@"/Common/selectImage@2x.png"] forState:UIControlStateNormal];
            [imagePickButton addTarget:self action:@selector(pickImages:) forControlEvents:UIControlEventTouchUpInside];
            self.imagePickItem = [[UIBarButtonItem alloc] initWithCustomView:imagePickButton];
            
//            self.imagePickItem = [[UIBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/Common/selectImage@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pickImages:)];
            
            UIButton *keyboardItem = [UIButton buttonWithType:UIButtonTypeCustom];
            keyboardItem.frame = CGRectMake(130, 7, 30 , 30);
            [keyboardItem setImage:[UIImage BBSImageNamed:@"/RichEditor/keyboard@2x.png"] forState:UIControlStateNormal];
            [keyboardItem addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
            
            self.keyboardItem = [[UIBarButtonItem alloc] initWithCustomView:keyboardItem];
            
            //keyboardToolbar.items = @[self.expressionItem, self.imagePickItem,self.keyboardItem];
            
            if (![BBSSDK isUsePlug]) {
                [keyboardTollbarView addSubview:self.lbsItem.customView];
            }
            
            [keyboardTollbarView addSubview:self.expressionItem.customView];
            [keyboardTollbarView addSubview:self.imagePickItem.customView];
            [keyboardTollbarView addSubview:self.keyboardItem.customView];
            //[keyboardTollbarView addSubview:self.arrowItem.customView];
            
            [self.toolbarHolder addSubview:toolbarCropper];
            
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
//            line.backgroundColor = [UIColor lightGrayColor];
//            line.alpha = 0.7f;
//            [toolbarCropper addSubview:line];
            
            
            
            
            
        }
        
        _lbsTagView = [UIButton buttonWithType:UIButtonTypeCustom];
        _lbsTagView.frame = CGRectMake(16, 10, 60, 20);
        [_lbsTagView setBackgroundColor:[UIColor colorWithRed:234.0/255.0 green:237.0/255.0 blue:242.0/255.0 alpha:1.0]];
        [_lbsTagView setTitle:@"  地址" forState:UIControlStateNormal];
        [_lbsTagView setTitleColor:[UIColor colorWithRed:154.0/255.0 green:156.0/255.0 blue:170.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_lbsTagView setImage:[UIImage BBSImageNamed:@"/LBS/LBS_min_icon@2x.png"] forState:UIControlStateNormal];
        [_lbsTagView addTarget:self action:@selector(showLbsButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        _lbsTagView.titleLabel.font = [UIFont systemFontOfSize:11];
        [_lbsTagView.layer setCornerRadius:2];
        [_lbsTagView.layer setMasksToBounds:YES];
        _lbsTagView.hidden = YES;
        // 光栅化
        _lbsTagView.layer.shouldRasterize = true;
        _lbsTagView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [_lbsTagView setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        [self.toolbarHolder addSubview:_lbsTagView];
    }
    
    [self.view addSubview:self.toolbarHolder];
    
    //Build the toolbar
    [self buildToolbar];
    
    //Load Resources
    if (!self.resourcesLoaded) {
        
        [self loadResources];
        
    }
    
}

#pragma mark - View Will Appear Section
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Add observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];

}

#pragma mark - View Will Disappear Section
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //Remove observers for keyboard showing or hiding notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    keyBoardHidden = NO;
}

#pragma mark - Setter
- (void)setAddressTag:(NSString *)addressTag{
    _addressTag = addressTag;
    NSString *text = @"";
    if (addressTag == nil || [addressTag isEqualToString:@""]) {
        [_lbsTagView setHidden:YES];
    }else{
        text = [NSString stringWithFormat:@"  %@",addressTag];
        [_lbsTagView setHidden:NO];
    }
    if (_lbsTagView) {
        [_lbsTagView setTitle:text forState:UIControlStateNormal];
        CGSize titleSize = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_lbsTagView.titleLabel.font.fontName size:_lbsTagView.titleLabel.font.pointSize]}];
        CGRect frame = _lbsTagView.frame;
        frame.size.width = titleSize.width + 8 * 2 + 16;
        _lbsTagView.frame = frame;
    }
}

- (void)setIsHiddenLBSMenu:(BOOL)isHiddenLBSMenu{
    _isHiddenLBSMenu = isHiddenLBSMenu;
    if (isHiddenLBSMenu == YES) {
        self.lbsItem.customView.hidden = YES;
    }else{
        self.lbsItem.customView.hidden = NO;
    }
}

#pragma mark - Set Up View Section

- (void)createSourceViewWithFrame:(CGRect)frame {
    
    self.sourceView = [[BBSUIRTETextView alloc] initWithFrame:frame];
    self.sourceView.hidden = YES;
    self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.sourceView.font = [UIFont fontWithName:@"Courier" size:13.0];
    self.sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sourceView.autoresizesSubviews = YES;
    self.sourceView.delegate = self;
    [self.view addSubview:self.sourceView];
    
}

- (void)createEditorViewWithFrame:(CGRect)frame {
    
    self.editorView = [[UIWebView alloc] initWithFrame:frame];
    self.editorView.delegate = self;
    self.editorView.hidesInputAccessoryView = YES;
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    self.editorView.scalesPageToFit = YES;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editorView.scrollView.bounces = NO;
    self.editorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editorView];
    
}

- (void)setUpImagePicker {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.allowsEditing = YES;
    self.selectedImageScale = kDefaultScale; //by default scale to half the size
    
}

- (void)createToolBarScroll {
    
    self.toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, [self isIpad] ? self.view.frame.size.width : self.view.frame.size.width - 90, 44)];
    self.toolBarScroll.backgroundColor = [UIColor clearColor];
    self.toolBarScroll.showsHorizontalScrollIndicator = NO;
    
}

- (void)createToolbar {
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.backgroundColor = [UIColor clearColor];
    [self.toolBarScroll addSubview:self.toolbar];
    self.toolBarScroll.autoresizingMask = self.toolbar.autoresizingMask;
    
}

- (void)createParentHoldingView {
    
    //Background Toolbar
    UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 44)];
    backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Parent holding view
    self.toolbarHolder = [[UIView alloc] init];
    
    if (_alwaysShowToolbar) {
        self.toolbarHolder.frame = CGRectMake(0, self.view.frame.size.height - 44 - 40, self.view.frame.size.width, 44 + 40);
    } else {
        self.toolbarHolder.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44 + 40);
    }
    
    self.toolbarHolder.autoresizingMask = self.toolbar.autoresizingMask;
    [self.toolbarHolder addSubview:self.toolBarScroll];
    [self.toolbarHolder insertSubview:backgroundToolbar atIndex:0];
    self.toolbarHolder.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Resources Section

- (void)loadResources {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bbsLoadBundle];
    
    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"/RichEditor/Files/editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [bundle pathForResource:@"/RichEditor/Files/jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [bundle pathForResource:@"/RichEditor/Files/JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add BBSUIRichTextEditor.js to the html file
    NSString *source = [bundle pathForResource:@"/RichEditor/Files/BBSUIRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    self.baseURL = [NSURL URLWithString:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
    [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
    self.resourcesLoaded = YES;
    
}

#pragma mark - Toolbar Section

- (void)setEnabledToolbarItems:(NSArray *)enabledToolbarItems {
    
    _enabledToolbarItems = enabledToolbarItems;
    [self buildToolbar];
    
}


- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor {
    
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
    for (BBSUIRTEBarButtonItem *item in self.toolbar.items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    self.keyboardItem.tintColor = toolbarItemTintColor;
    self.imagePickItem.tintColor = toolbarItemTintColor;
}


- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor {
    
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
    
}

- (NSArray *)itemsForToolbar {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[BBSUIBaseRichTextEditor class]];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // None
    if(_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarNone])
    {
        return items;
    }
    
    BOOL customOrder = NO;
    if (_enabledToolbarItems && ![_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll]){
        customOrder = YES;
        for(int i=0; i < _enabledToolbarItems.count;i++){
            [items addObject:@""];
        }
    }
    
    // Bold
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarBold]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *bold = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIbold@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setBold)];
        bold.label = @"bold";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarBold] withObject:bold];
        } else {
            [items addObject:bold];
        }
    }
    
    // Italic
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarItalic]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *italic = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIitalic@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setItalic)];
        italic.label = @"italic";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarItalic] withObject:italic];
        } else {
            [items addObject:italic];
        }
    }
    
    // Subscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarSubscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *subscript = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIsubscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSubscript)];
        subscript.label = @"subscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarSubscript] withObject:subscript];
        } else {
            [items addObject:subscript];
        }
    }
    
    // Superscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarSuperscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *superscript = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIsuperscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
        superscript.label = @"superscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarSuperscript] withObject:superscript];
        } else {
            [items addObject:superscript];
        }
    }
    
    // Strike Through
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarStrikeThrough]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *strikeThrough = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIstrikethrough@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setStrikethrough)];
        strikeThrough.label = @"strikeThrough";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarStrikeThrough] withObject:strikeThrough];
        } else {
            [items addObject:strikeThrough];
        }
    }
    
    // Underline
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarUnderline]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *underline = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIunderline@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnderline)];
        underline.label = @"underline";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarUnderline] withObject:underline];
        } else {
            [items addObject:underline];
        }
    }
    
    // Remove Format
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarRemoveFormat]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *removeFormat = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIclearstyle.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(removeFormat)];
        removeFormat.label = @"removeFormat";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarRemoveFormat] withObject:removeFormat];
        } else {
            [items addObject:removeFormat];
        }
    }
    
    //  Fonts
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarFonts]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        
        BBSUIRTEBarButtonItem *fonts = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIfonts.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(showFontsPicker)];
        fonts.label = @"fonts";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarFonts] withObject:fonts];
        } else {
            [items addObject:fonts];
        }
        
    }
    
    // Undo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarUndo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *undoButton = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIundo.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
        undoButton.label = @"undo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarUndo] withObject:undoButton];
        } else {
            [items addObject:undoButton];
        }
    }
    
    // Redo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarRedo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *redoButton = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIredo.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
        redoButton.label = @"redo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarRedo] withObject:redoButton];
        } else {
            [items addObject:redoButton];
        }
    }
    
    // Align Left
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarJustifyLeft]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *alignLeft = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIleftjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeft)];
        alignLeft.label = @"justifyLeft";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarJustifyLeft] withObject:alignLeft];
        } else {
            [items addObject:alignLeft];
        }
    }
    
    // Align Center
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarJustifyCenter]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *alignCenter = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIcenterjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenter)];
        alignCenter.label = @"justifyCenter";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarJustifyCenter] withObject:alignCenter];
        } else {
            [items addObject:alignCenter];
        }
    }
    
    // Align Right
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarJustifyRight]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *alignRight = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIrightjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignRight)];
        alignRight.label = @"justifyRight";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarJustifyRight] withObject:alignRight];
        } else {
            [items addObject:alignRight];
        }
    }
    
    // Align Justify
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarJustifyFull]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *alignFull = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIforcejustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignFull)];
        alignFull.label = @"justifyFull";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarJustifyFull] withObject:alignFull];
        } else {
            [items addObject:alignFull];
        }
    }
    
    // Paragraph
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarParagraph]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *paragraph = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIparagraph.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(paragraph)];
        paragraph.label = @"p";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarParagraph] withObject:paragraph];
        } else {
            [items addObject:paragraph];
        }
    }
    
    // Header 1
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH1]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h1 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIh1@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading1)];
        h1.label = @"h1";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH1] withObject:h1];
        } else {
            [items addObject:h1];
        }
    }
    
    // Header 2
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH2]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h2 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIh2@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading2)];
        h2.label = @"h2";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH2] withObject:h2];
        } else {
            [items addObject:h2];
        }
    }
    
    // Header 3
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH3]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h3 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIh3@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading3)];
        h3.label = @"h3";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH3] withObject:h3];
        } else {
            [items addObject:h3];
        }
    }
    
    // Heading 4
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH4]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h4 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIh4@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading4)];
        h4.label = @"h4";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH4] withObject:h4];
        } else {
            [items addObject:h4];
        }
    }
    
    // Header 5
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH5]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h5 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIh5.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading5)];
        h5.label = @"h5";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH5] withObject:h5];
        } else {
            [items addObject:h5];
        }
    }
    
    // Heading 6
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarH6]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *h6 = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIh6.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading6)];
        h6.label = @"h6";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarH6] withObject:h6];
        } else {
            [items addObject:h6];
        }
    }
    
    // Text Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarTextColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *textColor = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUItextcolor.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(textColor)];
        textColor.label = @"textColor";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarTextColor] withObject:textColor];
        } else {
            [items addObject:textColor];
        }
    }
    
    // Background Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarBackgroundColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *bgColor = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIbgcolor.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(bgColor)];
        bgColor.label = @"backgroundColor";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarBackgroundColor] withObject:bgColor];
        } else {
            [items addObject:bgColor];
        }
    }
    
    // Unordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarUnorderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *ul = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage BBSImageNamed:@"/RichEditor/BBSUIunorderedlist@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnorderedList)];
        ul.label = @"unorderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarUnorderedList] withObject:ul];
        } else {
            [items addObject:ul];
        }
    }
    
    // Ordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarOrderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *ol = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOrderedList)];
        ol.label = @"orderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarOrderedList] withObject:ol];
        } else {
            [items addObject:ol];
        }
    }
    
    // Horizontal Rule
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarHorizontalRule]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *hr = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIhorizontalrule.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setHR)];
        hr.label = @"horizontalRule";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarHorizontalRule] withObject:hr];
        } else {
            [items addObject:hr];
        }
    }
    
    // Indent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarIndent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *indent = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIindent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setIndent)];
        indent.label = @"indent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarIndent] withObject:indent];
        } else {
            [items addObject:indent];
        }
    }
    
    // Outdent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarOutdent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *outdent = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIoutdent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOutdent)];
        outdent.label = @"outdent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarOutdent] withObject:outdent];
        } else {
            [items addObject:outdent];
        }
    }
    
    // Image
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarInsertImage]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *insertImage = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIimage.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertImage)];
        insertImage.label = @"image";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarInsertImage] withObject:insertImage];
        } else {
            [items addObject:insertImage];
        }
    }
    
    // Image From Device
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarInsertImageFromDevice]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *insertImageFromDevice = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIimageDevice.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertImageFromDevice)];
        insertImageFromDevice.label = @"imageFromDevice";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarInsertImageFromDevice] withObject:insertImageFromDevice];
        } else {
            [items addObject:insertImageFromDevice];
        }
    }
    
    // Insert Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarInsertLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *insertLink = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIlink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        insertLink.label = @"link";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarInsertLink] withObject:insertLink];
        } else {
            [items addObject:insertLink];
        }
    }
    
    // Remove Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarRemoveLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *removeLink = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIunlink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(removeLink)];
        removeLink.label = @"removeLink";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarRemoveLink] withObject:removeLink];
        } else {
            [items addObject:removeLink];
        }
    }
    
    // Quick Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarQuickLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *quickLink = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIquicklink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(quickLink)];
        quickLink.label = @"quickLink";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarQuickLink] withObject:quickLink];
        } else {
            [items addObject:quickLink];
        }
    }
    
    // Show Source
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarViewSource]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarAll])) {
        BBSUIRTEBarButtonItem *showSource = [[BBSUIRTEBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BBSUIviewsource.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(showHTMLSource:)];
        showSource.label = @"source";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:BBSUIRichTextEditorToolbarViewSource] withObject:showSource];
        } else {
            [items addObject:showSource];
        }
    }
    
    return [NSArray arrayWithArray:items];
    
}


- (void)buildToolbar {
    
    // Check to see if we have any toolbar items, if not, add them all
    NSArray *items = [self itemsForToolbar];
    if (items.count == 0 && !(_enabledToolbarItems && [_enabledToolbarItems containsObject:BBSUIRichTextEditorToolbarNone])) {
        _enabledToolbarItems = @[BBSUIRichTextEditorToolbarAll];
        items = [self itemsForToolbar];
    }
    
    if (self.customBBSUIBarButtonItems != nil) {
        items = [items arrayByAddingObjectsFromArray:self.customBBSUIBarButtonItems];
    }
    
    // get the width before we add custom buttons
    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 39) - 10;
    
    if(self.customBarButtonItems != nil)
    {
        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
        for(BBSUIRTEBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
        }
    }
    
    self.toolbar.items = items;
    for (BBSUIRTEBarButtonItem *item in items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    
    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth + 50, 44);
    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
}


#pragma mark - Editor Modification Section

- (void)setCSS:(NSString *)css {
    
    self.customCSS = css;
    
    if (self.editorLoaded) {
        [self updateCSS];
    }
    
}

- (void)updateCSS {
    
    if (self.customCSS != NULL && [self.customCSS length] != 0) {
        
        NSString *js = [NSString stringWithFormat:@"bbsui_editor.setCustomCSS(\"%@\");", self.customCSS];
        [self.editorView stringByEvaluatingJavaScriptFromString:js];
        
    }
    
}

- (void)setPlaceholderText {
    
    //Call the setPlaceholder javascript method if a placeholder has been set
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
    
        NSString *js = [NSString stringWithFormat:@"bbsui_editor.setPlaceholder(\"%@\");", self.placeholder];
        [self.editorView stringByEvaluatingJavaScriptFromString:js];
        
    }
    
}

- (void)setFooterHeight:(float)footerHeight {
    
    //Call the setFooterHeight javascript method
    NSString *js = [NSString stringWithFormat:@"bbsui_editor.setFooterHeight(\"%f\");", footerHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
    
}

- (void)setContentHeight:(float)contentHeight {
    
    //Call the contentHeight javascript method
    NSString *js = [NSString stringWithFormat:@"bbsui_editor.contentHeight = %f;", contentHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
    
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    NSString *js = [NSString stringWithFormat:@"bbsui_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"bbsui_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    
    NSString *html = self.internalHTML;
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (NSString *)getHTML {
    
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
    return html;
    
}


- (void)insertHTML:(NSString *)html {
    
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (NSString *)getText {
    
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.getText();"];
    
}

- (void)dismissKeyboard {
    
    if (_showExpView)
    {
        _showExpView = NO;
        [_expView removeFromSuperview];
        
        UIButton *btn = self.keyboardItem.customView;
        
        [UIView animateWithDuration:0.25 animations:^{
            btn.imageView.transform = CGAffineTransformIdentity;
        }];
        
        [self focusTextEditor];//可能
        
        keyBoardHidden = NO;
    }
    
    else if (keyBoardHidden)
    {
        UIButton *btn = self.keyboardItem.customView;
        
        [UIView animateWithDuration:0.25 animations:^{
            btn.imageView.transform = CGAffineTransformIdentity;
        }];
        
        [self focusTextEditor];//可能
        
        keyBoardHidden = NO;
    }
    else
    {
        UIButton *btn = self.keyboardItem.customView;
        
        [UIView animateWithDuration:0.25 animations:^{
            btn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
        
        [self.parentViewController.view endEditing:YES];
        [self.view endEditing:YES];
        
        [self _fallingToolbarHolder];
        
        keyBoardHidden = YES;
    }
    
//    keyBoardHidden = !keyBoardHidden;
}

- (void)keyboardButtonHandler:(UIButton *)button
{
    keyBoardHidden = NO;
    
    [self removeExpView];
    [self focusTextEditor];
}

- (void)arrowButtonHandler:(UIButton *)button
{
 
    [self removeExpView];
    
    if (!keyBoardHidden || _keyboardIsAppear)
    {
        [self.parentViewController.view endEditing:YES];
        [self.view endEditing:YES];
        [self _fallingToolbarHolder];
    }
    
    else
    {
        [self focusTextEditor];//可能
    }
    
    keyBoardHidden = !keyBoardHidden;
}

- (void)showHTMLSource:(BBSUIRTEBarButtonItem *)barButtonItem {
    if (self.sourceView.hidden) {
        self.sourceView.text = [self getHTML];
        self.sourceView.hidden = NO;
        barButtonItem.tintColor = [UIColor blackColor];
        self.editorView.hidden = YES;
        [self enableToolbarItems:NO];
    } else {
        [self setHTML:self.sourceView.text];
        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
        [self enableToolbarItems:YES];
    }
}

- (void)removeFormat {
    NSString *trigger = @"bbsui_editor.removeFormating();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignLeft {
    NSString *trigger = @"bbsui_editor.setJustifyLeft();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignCenter {
    NSString *trigger = @"bbsui_editor.setJustifyCenter();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignRight {
    NSString *trigger = @"bbsui_editor.setJustifyRight();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignFull {
    NSString *trigger = @"bbsui_editor.setJustifyFull();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setBold {
    NSString *trigger = @"bbsui_editor.setBold();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setItalic {
    NSString *trigger = @"bbsui_editor.setItalic();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSubscript {
    NSString *trigger = @"bbsui_editor.setSubscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnderline {
    NSString *trigger = @"bbsui_editor.setBlockquote();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSuperscript {
    NSString *trigger = @"bbsui_editor.setSuperscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setStrikethrough {
    NSString *trigger = @"bbsui_editor.setStrikeThrough();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnorderedList {
    NSString *trigger = @"bbsui_editor.setUnorderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOrderedList {
    NSString *trigger = @"bbsui_editor.setOrderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setHR {
    NSString *trigger = @"bbsui_editor.setHorizontalRule();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setIndent {
    NSString *trigger = @"bbsui_editor.setIndent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"bbsui_editor.setOutdent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading1 {
    NSString *trigger = @"bbsui_editor.setHeading('h1');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading2 {
    NSString *trigger = @"bbsui_editor.setHeading('h2');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading3 {
    NSString *trigger = @"bbsui_editor.setHeading('h3');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading4 {
    NSString *trigger = @"bbsui_editor.setHeading('h4');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading5 {
    NSString *trigger = @"bbsui_editor.setHeading('h5');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading6 {
    NSString *trigger = @"bbsui_editor.setHeading('h6');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)paragraph {
    NSString *trigger = @"bbsui_editor.setParagraph();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)showFontsPicker {
        
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    //Call picker
    BBSUIRTEFontsViewController *fontPicker = [BBSUIRTEFontsViewController cancelableFontPickerViewControllerWithFontFamily:BBSUIRTEFontFamilyDefault];
    fontPicker.delegate = self;
    [self.navigationController pushViewController:fontPicker animated:YES];
    
}

- (void)setSelectedFontFamily:(BBSUIRTEFontFamily)fontFamily {
    
    NSString *fontFamilyString;
    
    switch (fontFamily) {
        case BBSUIRTEFontFamilyDefault:
            fontFamilyString = @"Arial, Helvetica, sans-serif";
            break;
        
        case BBSUIRTEFontFamilyGeorgia:
            fontFamilyString = @"Georgia, serif";
            break;
        
        case BBSUIRTEFontFamilyPalatino:
            fontFamilyString = @"Palatino Linotype, Book Antiqua, Palatino, serif";
            break;
        
        case BBSUIRTEFontFamilyTimesNew:
            fontFamilyString = @"Times New Roman, Times, serif";
            break;
        
        case BBSUIRTEFontFamilyTrebuchet:
            fontFamilyString = @"Trebuchet MS, Helvetica, sans-serif";
            break;
        
        case BBSUIRTEFontFamilyVerdana:
            fontFamilyString = @"Verdana, Geneva, sans-serif";
            break;
        
        case BBSUIRTEFontFamilyCourierNew:
            fontFamilyString = @"Courier New, Courier, monospace";
            break;
        
        default:
            fontFamilyString = @"Arial, Helvetica, sans-serif";
            break;
    }
    
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.setFontFamily(\"%@\");", fontFamilyString];

    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (void)textColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    // Call the picker
    BBSUIHRColorPickerViewController *colorPicker = [BBSUIHRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)bgColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    // Call the picker
    BBSUIHRColorPickerViewController *colorPicker = [BBSUIHRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {
    
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"bbsui_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"bbsui_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (void)undo:(BBSUIRTEBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.undo();"];
}

- (void)redo:(BBSUIRTEBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.redo();"];
}

- (void)insertLink {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
    
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"BBSUIpicker.png" inBundle:[NSBundle bundleForClass:[BBSUIBaseRichTextEditor class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (title) {
                textField.text = title;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *linkURL = [alertController.textFields objectAtIndex:0];
            UITextField *title = [alertController.textFields objectAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 2;
        UITextField *linkURL = [self.alertView textFieldAtIndex:0];
        linkURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            linkURL.text = url;
        }
        
        linkURL.rightView = am;
        linkURL.rightViewMode = UITextFieldViewModeAlways;
        
        UITextField *alt = [self.alertView textFieldAtIndex:1];
        alt.secureTextEntry = NO;
        alt.placeholder = NSLocalizedString(@"Title", nil);
        if (title) {
            alt.text = title;
        }
        
        [self.alertView show];
    }
    
}


- (void)insertLink:(NSString *)url title:(NSString *)title {
    
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}


- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)dismissAlertView {
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)addCustomToolbarItemWithButton:(UIButton *)button {
    
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.5f];
    [button setTitleColor:[self barButtonItemDefaultColor] forState:UIControlStateNormal];
    [button setTitleColor:[self barButtonItemSelectedDefaultColor] forState:UIControlStateHighlighted];
    
    BBSUIRTEBarButtonItem *barButtonItem = [[BBSUIRTEBarButtonItem alloc] initWithCustomView:button];
    
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self buildToolbar];
}

- (void)addCustomToolbarItem:(BBSUIRTEBarButtonItem *)item {
    
    if(self.customBBSUIBarButtonItems == nil)
    {
        self.customBBSUIBarButtonItems = [NSMutableArray array];
    }
    [self.customBBSUIBarButtonItems addObject:item];
    
    [self buildToolbar];
}


- (void)removeLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.unlink();"];
}

- (void)quickLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.quickLink();"];
}

- (void)insertImage {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
    
}

- (void)insertImageFromDevice {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    
    [self showInsertImageDialogFromDeviceWithScale:self.selectedImageScale alt:self.selectedImageAlt];
    
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"BBSUIpicker.png" inBundle:[NSBundle bundleForClass:[BBSUIBaseRichTextEditor class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *imageURL = [alertController.textFields objectAtIndex:0];
            UITextField *alt = [alertController.textFields objectAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 1;
        UITextField *imageURL = [self.alertView textFieldAtIndex:0];
        imageURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            imageURL.text = url;
        }
        
        imageURL.rightView = am;
        imageURL.rightViewMode = UITextFieldViewModeAlways;
        imageURL.clearButtonMode = UITextFieldViewModeAlways;
        
        UITextField *alt1 = [self.alertView textFieldAtIndex:1];
        alt1.secureTextEntry = NO;
        alt1.placeholder = NSLocalizedString(@"Alt", nil);
        alt1.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            alt1.text = alt;
        }
        
        [self.alertView show];
    }
    
}

- (void)showInsertImageDialogFromDeviceWithScale:(CGFloat)scale alt:(NSString *)alt {
    
    // Insert button title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Pick Image", nil) : NSLocalizedString(@"Pick New Image", nil);
    
    //If the OS version supports the new UIAlertController go for it. Otherwise use the old UIAlertView
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image From Device", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        //Add alt text field
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        
        //Add scale text field
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            textField.placeholder = NSLocalizedString(@"Image scale, 0.5 by default", nil);
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }];
        
        //Cancel action
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        
        //Insert action
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textFieldAlt = [alertController.textFields objectAtIndex:0];
            UITextField *textFieldScale = [alertController.textFields objectAtIndex:1];

            self.selectedImageScale = [textFieldScale.text floatValue]?:kDefaultScale;
            self.selectedImageAlt = textFieldAlt.text?:@"";
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];

        }]];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 3;
        
        UITextField *textFieldAlt = [self.alertView textFieldAtIndex:0];
        textFieldAlt.secureTextEntry = NO;
        textFieldAlt.placeholder = NSLocalizedString(@"Alt", nil);
        textFieldAlt.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            textFieldAlt.text = alt;
        }
        
        UITextField *textFieldScale = [self.alertView textFieldAtIndex:1];
        textFieldScale.placeholder = NSLocalizedString(@"Image scale, 0.5 by default", nil);
        textFieldScale.keyboardType = UIKeyboardTypeDecimalPad;
        
        [self.alertView show];
    }
    
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    
    [self.editorView stringByEvaluatingJavaScriptFromString:@"bbsui_editor.prepareInsert();"];
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.insertImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"bbsui_editor.updateImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)updateToolBarWithButtonName:(NSString *)name {
    
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    
    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([linkItem hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([linkItem hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        } else {
            self.selectedImageURL = nil;
            self.selectedImageAlt = nil;
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }
    itemNames = [NSArray arrayWithArray:itemsModified];
    
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (BBSUIRTEBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }
    
}


#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
    
}


#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    NSString *urlString = [[request URL] absoluteString];
    //NSLog(@"web request");
    //NSLog(@"%@", urlString);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        NSLog(@"Debug Found");
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"%@", debug);
        
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        [self editorDidScrollWithPosition:position];
        
    }
    
    return YES;
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.editorLoaded = YES;

    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];

    if(self.placeholder) {
        [self setPlaceholderText];
    }
    
    if (self.customCSS) {
        [self updateCSS];
    }

    if (self.shouldShowKeyboard) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    }
    

    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"contentUpdateCallback"] = ^(JSValue *msg) {
        
        if (_receiveEditorDidChangeEvents) {
            
            [self editorDidChangeWithText:[self getText] andHTML:[self getHTML]];
            
        }
        
        [self checkForMentionOrHashtagInText:[self getText]];
        
    };
    [ctx evaluateScript:@"document.getElementById('bbsui_editor_content').addEventListener('input', contentUpdateCallback, false);"];
    
}

#pragma mark - Mention & Hashtag Support Section

- (void)checkForMentionOrHashtagInText:(NSString *)text {
    
    if ([text containsString:@" "] && [text length] > 0) {
        
        NSString *lastWord = nil;
        NSString *matchedWord = nil;
        BOOL ContainsHashtag = NO;
        BOOL ContainsMention = NO;
        
        NSRange range = [text rangeOfString:@" " options:NSBackwardsSearch];
        lastWord = [text substringFromIndex:range.location];
        
        if (lastWord != nil) {
        
            //Check if last word typed starts with a #
            NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];
            NSArray *hashtagMatches = [hashtagRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];
            
            for (NSTextCheckingResult *match in hashtagMatches) {
                
                NSRange wordRange = [match rangeAtIndex:1];
                NSString *word = [lastWord substringWithRange:wordRange];
                matchedWord = word;
                ContainsHashtag = YES;
                
            }
            
            if (!ContainsHashtag) {
                
                //Check if last word typed starts with a @
                NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:nil];
                NSArray *mentionMatches = [mentionRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];
                
                for (NSTextCheckingResult *match in mentionMatches) {
                    
                    NSRange wordRange = [match rangeAtIndex:1];
                    NSString *word = [lastWord substringWithRange:wordRange];
                    matchedWord = word;
                    ContainsMention = YES;
                    
                }
                
            }
            
        }
        
        if (ContainsHashtag) {
            
            [self hashtagRecognizedWithWord:matchedWord];
            
        }
        
        if (ContainsMention) {
            
            [self mentionRecognizedWithWord:matchedWord];
            
        }
        
    }
    
}

#pragma mark - Callbacks

//Blank implementation
- (void)editorDidScrollWithPosition:(NSInteger)position {}

//Blank implementation
- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html  {}

//Blank implementation
- (void)hashtagRecognizedWithWord:(NSString *)word {}

//Blank implementation
- (void)mentionRecognizedWithWord:(NSString *)word {}


#pragma mark - AlertView

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if (alertView.tag == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        if ([textField.text length] == 0 || [textField2.text length] == 0) {
            return NO;
        }
    } else if (alertView.tag == 2) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *imageURL = [alertView textFieldAtIndex:0];
            UITextField *alt = [alertView textFieldAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            UITextField *linkURL = [alertView textFieldAtIndex:0];
            UITextField *title = [alertView textFieldAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
        }
    } else if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            UITextField *textFieldAlt = [alertView textFieldAtIndex:0];
            UITextField *textFieldScale = [alertView textFieldAtIndex:1];
            
            self.selectedImageScale = [textFieldScale.text floatValue]?:kDefaultScale;
            self.selectedImageAlt = textFieldAlt.text?:@"";
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];

        }
    }
}


#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}


- (void)showInsertImageAlternatePicker {
    // Blank method. User should implement this in their subclass
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //Dismiss the Image Picker
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info{

    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
    
    //Scale the image
    CGSize targetSize = CGSizeMake(selectedImage.size.width * self.selectedImageScale, selectedImage.size.height * self.selectedImageScale);
    UIGraphicsBeginImageContext(targetSize);
    [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //Compress the image, as it is going to be encoded rather than linked
    NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, kJPEGCompression);
    
    //Encode the image data as a base64 string
    NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
    
    //Decide if we have to insert or update
    if (!self.imageBase64String) {
        [self insertImageBase64String:imageBase64String alt:self.selectedImageAlt];
    } else {
        [self updateImageBase64String:imageBase64String alt:self.selectedImageAlt];
    }
    
    self.imageBase64String = imageBase64String;

    //Dismiss the Image Picker
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard status

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Toolbar Sizes
    CGFloat sizeOfToolbar = self.toolbarHolder.frame.size.height;
    
    // Keyboard Size
    //Checks if IOS8, gets correct keyboard height
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    
//    _keyboardHeight = keyboardHeight;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    const int extraHeight = 10;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        _keyboardIsAppear = YES;
        
        if (_isInputExpression)
        {
            _isInputExpression = NO;
        }else
        {
            _showExpView = NO;
            [_expView removeFromSuperview];
        }
        
        
        if (self.uiStyleType == BBSUIRTEStyleTypeOne)
        {
            UIButton *btn = self.keyboardItem.customView;
            
            [UIView animateWithDuration:0.25 animations:^{
                btn.imageView.transform = CGAffineTransformIdentity;
            }];
//            [self focusTextEditor];//可能
            keyBoardHidden = NO;
        }
        
        
        // 存储键盘高度
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        _keyboardHeight = keyboardSize.height;
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            // Toolbar
            CGRect frame = self.toolbarHolder.frame;
            if (_expView)
            {
                frame.origin.y = _expView.frame.origin.y - sizeOfToolbar;
            }
            else
            {
                frame.origin.y = self.view.frame.size.height - (keyboardHeight + sizeOfToolbar);
            }
            
            self.toolbarHolder.frame = frame;
            
            // Editor View
            CGRect editorFrame = self.editorView.frame;
            editorFrame.size.height = (self.view.frame.size.height - keyboardHeight) - sizeOfToolbar - extraHeight;
            self.editorView.frame = editorFrame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            CGRect sourceFrame = self.sourceView.frame;
            sourceFrame.size.height = (self.view.frame.size.height - keyboardHeight) - sizeOfToolbar - extraHeight;
            self.sourceView.frame = sourceFrame;
            
            // Provide editor with keyboard height and editor view height
            [self setFooterHeight:(keyboardHeight - 8)];
            [self setContentHeight: self.editorViewFrame.size.height];
            
        } completion:nil];
        
    } else {
        _keyboardIsAppear = NO;
       
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
//            CGRect frame = self.toolbarHolder.frame;

            if (!_showExpView && !_isInputExpression)
            {
                [self hideKeyboard];
            }

////            else
//            if (_alwaysShowToolbar) {
//                frame.origin.y = self.view.frame.size.height - sizeOfToolbar;
//            } else {
//                frame.origin.y = self.view.frame.size.height + keyboardHeight;
//            }
//
//            self.toolbarHolder.frame = frame;
            
            // Editor View
            CGRect editorFrame = self.editorView.frame;
            
            if (_alwaysShowToolbar) {
                editorFrame.size.height = ((self.view.frame.size.height - sizeOfToolbar) - extraHeight);
            } else {
                editorFrame.size.height = self.view.frame.size.height;
            }
            
            self.editorView.frame = editorFrame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            CGRect sourceFrame = self.sourceView.frame;
            
            if (_alwaysShowToolbar) {
                sourceFrame.size.height = ((self.view.frame.size.height - sizeOfToolbar) - extraHeight);
            } else {
                sourceFrame.size.height = self.view.frame.size.height;
            }
            
            self.sourceView.frame = sourceFrame;
            
            [self setFooterHeight:0];
            [self setContentHeight:self.editorViewFrame.size.height];
            
        } completion:nil];
        
    }
    
}


#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}


- (UIColor *)barButtonItemDefaultColor {
    
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    
    return [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}


- (UIColor *)barButtonItemSelectedDefaultColor {
    
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    
    return [UIColor blackColor];
}


- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (void)enableToolbarItems:(BOOL)enable {
    NSArray *items = self.toolbar.items;
    for (BBSUIRTEBarButtonItem *item in items) {
        if (![item.label isEqualToString:@"source"]) {
            item.enabled = enable;
        }
    }
}

// 设置父控制器并实现pickImage 否则崩溃
- (void)pickImages:(id)sender
{
    if ([self.parentViewController respondsToSelector:@selector(pickImages)]) {
        [self removeExpView];
        keyBoardHidden = YES;
        [self _fallingToolbarHolder];
        
        [self.parentViewController performSelector:@selector(pickImages) withObject:nil];
    }
}

- (void)lbsButtonHandler:(id)sender
{
    if ([self.parentViewController respondsToSelector:@selector(openLBS)]) {
        [self.parentViewController performSelector:@selector(openLBS) withObject:nil];
    }
}

- (void)showLbsButtonHandler:(id)sender
{
//    if ([self.parentViewController respondsToSelector:@selector(showLBS)]) {
//        [self.parentViewController performSelector:@selector(showLBS) withObject:nil];
//    }
    //===openLBS
    if ([self.parentViewController respondsToSelector:@selector(openLBS)]) {
        [self.parentViewController performSelector:@selector(openLBS) withObject:nil];
    }
    
}

- (void)faceButtonHandler:(id)sender
{
    _showExpView = YES;
    keyBoardHidden = NO;
    
    if (!_expView)
    {
        _expView = [[BBSUIExpressionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - _keyboardHeight, self.view.frame.size.width, _keyboardHeight)];
        _expView.delegate = self;
    }
    
    if (self.uiStyleType == BBSUIRTEStyleTypeOne)
    {
        UIButton *btn = self.keyboardItem.customView;
        
        [UIView animateWithDuration:0.25 animations:^{
            btn.imageView.transform = CGAffineTransformIdentity;
        }];
    }
    
    [self.parentViewController.view endEditing:YES];
    [self.view endEditing:YES];
    
    CGRect toolBarFrame = self.toolbarHolder.frame;
    toolBarFrame.origin.y = self.view.frame.size.height - _keyboardHeight - toolBarFrame.size.height;
    
    self.toolbarHolder.frame = toolBarFrame;
    
    [self.view addSubview:_expView];
    
//    [self.parentViewController performSelector:@selector(faceButtonHandler) withObject:nil withObject:nil];
}

- (void)removeExpView
{
    [_expView removeFromSuperview];
    _showExpView = NO;
}

- (void)_fallingToolbarHolder
{
    
    CGRect frame = self.toolbarHolder.frame;
    
    //            if (_showExpView)
    //            {
    //                frame.origin.y = self.view.frame.size.height - _keyboardHeight - sizeOfToolbar;
    //                _showExpView = NO;
    //            }
    //            else
    if (_alwaysShowToolbar) {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
    } else {
        frame.origin.y = self.view.frame.size.height + _keyboardHeight;
    }
    
    self.toolbarHolder.frame = frame;
}

#pragma mark BBSUIExpressionViewDelegate

- (void)expressionView:(BBSUIExpressionView *)expressionView didSelectImageName:(NSString *)imageName
{
    _isInputExpression = YES;
//    if ([self.editorView isFirstResponder])
//    {
//        <#statements#>
//    }
    [self.parentViewController performSelector:@selector(expressionView:didSelectImageName:) withObject:expressionView withObject:imageName];
//    [self.parentViewController performSelector:@selector(faceButtonHandlerWithImageName:) withObject:imageName withObject:@"14"];
//    [_countNumTextView setExpressionWithImageName:imageName fontSize:_countNumTextView.defaultFontSize];
}

- (void)hideKeyboard
{
    if (self.uiStyleType == BBSUIRTEStyleTypeOne)
    {
        if (keyBoardHidden == NO || !_showExpView)
        {
            [self dismissKeyboard];
        }
    }
    else
    {
        if (!keyBoardHidden || _keyboardIsAppear)
        {
            [self keyboardButtonHandler:nil];
        }
    }
}

@end
