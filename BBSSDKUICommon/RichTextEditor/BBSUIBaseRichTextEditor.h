
#import <UIKit/UIKit.h>
#import "BBSUIHRColorPickerViewController.h"
#import "BBSUIRTEFontsViewController.h"

typedef NS_ENUM(NSInteger, BBSUIRTEStyleType)
{
    BBSUIRTEStyleTypeOne,
    BBSUIRTEStyleTypeTwo
};

/**
 *  The types of toolbar items that can be added
 */
static NSString * const BBSUIRichTextEditorToolbarBold = @"com.zedsaid.toolbaritem.bold";
static NSString * const BBSUIRichTextEditorToolbarItalic = @"com.zedsaid.toolbaritem.italic";
static NSString * const BBSUIRichTextEditorToolbarSubscript = @"com.zedsaid.toolbaritem.subscript";
static NSString * const BBSUIRichTextEditorToolbarSuperscript = @"com.zedsaid.toolbaritem.superscript";
static NSString * const BBSUIRichTextEditorToolbarStrikeThrough = @"com.zedsaid.toolbaritem.strikeThrough";
static NSString * const BBSUIRichTextEditorToolbarUnderline = @"com.zedsaid.toolbaritem.underline";
static NSString * const BBSUIRichTextEditorToolbarRemoveFormat = @"com.zedsaid.toolbaritem.removeFormat";
static NSString * const BBSUIRichTextEditorToolbarJustifyLeft = @"com.zedsaid.toolbaritem.justifyLeft";
static NSString * const BBSUIRichTextEditorToolbarJustifyCenter = @"com.zedsaid.toolbaritem.justifyCenter";
static NSString * const BBSUIRichTextEditorToolbarJustifyRight = @"com.zedsaid.toolbaritem.justifyRight";
static NSString * const BBSUIRichTextEditorToolbarJustifyFull = @"com.zedsaid.toolbaritem.justifyFull";
static NSString * const BBSUIRichTextEditorToolbarH1 = @"com.zedsaid.toolbaritem.h1";
static NSString * const BBSUIRichTextEditorToolbarH2 = @"com.zedsaid.toolbaritem.h2";
static NSString * const BBSUIRichTextEditorToolbarH3 = @"com.zedsaid.toolbaritem.h3";
static NSString * const BBSUIRichTextEditorToolbarH4 = @"com.zedsaid.toolbaritem.h4";
static NSString * const BBSUIRichTextEditorToolbarH5 = @"com.zedsaid.toolbaritem.h5";
static NSString * const BBSUIRichTextEditorToolbarH6 = @"com.zedsaid.toolbaritem.h6";
static NSString * const BBSUIRichTextEditorToolbarTextColor = @"com.zedsaid.toolbaritem.textColor";
static NSString * const BBSUIRichTextEditorToolbarBackgroundColor = @"com.zedsaid.toolbaritem.backgroundColor";
static NSString * const BBSUIRichTextEditorToolbarUnorderedList = @"com.zedsaid.toolbaritem.unorderedList";
static NSString * const BBSUIRichTextEditorToolbarOrderedList = @"com.zedsaid.toolbaritem.orderedList";
static NSString * const BBSUIRichTextEditorToolbarHorizontalRule = @"com.zedsaid.toolbaritem.horizontalRule";
static NSString * const BBSUIRichTextEditorToolbarIndent = @"com.zedsaid.toolbaritem.indent";
static NSString * const BBSUIRichTextEditorToolbarOutdent = @"com.zedsaid.toolbaritem.outdent";
static NSString * const BBSUIRichTextEditorToolbarInsertImage = @"com.zedsaid.toolbaritem.insertImage";
static NSString * const BBSUIRichTextEditorToolbarInsertImageFromDevice = @"com.zedsaid.toolbaritem.insertImageFromDevice";
static NSString * const BBSUIRichTextEditorToolbarInsertLink = @"com.zedsaid.toolbaritem.insertLink";
static NSString * const BBSUIRichTextEditorToolbarRemoveLink = @"com.zedsaid.toolbaritem.removeLink";
static NSString * const BBSUIRichTextEditorToolbarQuickLink = @"com.zedsaid.toolbaritem.quickLink";
static NSString * const BBSUIRichTextEditorToolbarUndo = @"com.zedsaid.toolbaritem.undo";
static NSString * const BBSUIRichTextEditorToolbarRedo = @"com.zedsaid.toolbaritem.redo";
static NSString * const BBSUIRichTextEditorToolbarViewSource = @"com.zedsaid.toolbaritem.viewSource";
static NSString * const BBSUIRichTextEditorToolbarParagraph = @"com.zedsaid.toolbaritem.paragraph";
static NSString * const BBSUIRichTextEditorToolbarAll = @"com.zedsaid.toolbaritem.all";
static NSString * const BBSUIRichTextEditorToolbarNone = @"com.zedsaid.toolbaritem.none";
static NSString * const BBSUIRichTextEditorToolbarFonts = @"com.zedsaid.toolbaritem.fonts";

@class BBSUIRTEBarButtonItem;

/**
 *  The viewController used with BBSUIRichTextEditor
 */
@interface BBSUIBaseRichTextEditor : UIViewController <UIWebViewDelegate, BBSUIHRColorPickerViewControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,BBSUIRTEFontsViewControllerDelegate>

/*
 *  UIWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) UIWebView *editorView;
/**
 *  The base URL to use for the webView
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

/**
 *  If the keyboard should be shown when the editor loads
 */
@property (nonatomic) BOOL shouldShowKeyboard;

/**
 * If the toolbar should always be shown or not
 */
@property (nonatomic) BOOL alwaysShowToolbar;

/**
 * If the sub class recieves text did change events or not
 */
@property (nonatomic) BOOL receiveEditorDidChangeEvents;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 *  Toolbar items to include
 */
@property (nonatomic, strong) NSArray *enabledToolbarItems;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *toolbarItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *toolbarItemSelectedTintColor;

/**
 *  UI style type [Custom]
 */
@property (nonatomic, assign) BBSUIRTEStyleType uiStyleType;

@property (nonatomic,copy) NSString *addressTag;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (NSString *)getHTML;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (NSString *)getText;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(NSString *)html;

/**
 *  Manually focuses on the text editor
 */
- (void)focusTextEditor;

/**
 *  Manually dismisses on the text editor
 */
- (void)blurTextEditor;

/**
 *  Shows the insert image dialog with optinal inputs
 *
 *  @param url The URL for the image
 *  @param alt The alt for the image
 */
- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt;

/**
 *  Inserts an image
 *
 *  @param url The URL for the image
 *  @param alt The alt attribute for the image
 */
- (void)insertImage:(NSString *)url alt:(NSString *)alt;

/**
 *  Shows the insert link dialog with optional inputs
 *
 *  @param url   The URL for the link
 *  @param title The tile for the link
 */
- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title;

/**
 *  Inserts a link
 *
 *  @param url The URL for the link
 *  @param title The title for the link
 */
- (void)insertLink:(NSString *)url title:(NSString *)title;

/**
 *  Gets called when the insert URL picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertURLAlternatePicker;

/**
 *  Gets called when the insert Image picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertImageAlternatePicker;

/**
 *  Dismisses the current AlertView
 */
- (void)dismissAlertView;

/**
 *  Add a custom UIBarButtonItem by using a UIButton
 */
- (void)addCustomToolbarItemWithButton:(UIButton*)button;

/**
 *  Add a custom BBSUIBarButtonItem
 */
- (void)addCustomToolbarItem:(BBSUIRTEBarButtonItem *)item;

/**
 *  Scroll event callback with position
 */
- (void)editorDidScrollWithPosition:(NSInteger)position;

/**
 *  Text change callback with text and html
 */
- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html;

/**
 *  Hashtag callback with word
 */
- (void)hashtagRecognizedWithWord:(NSString *)word;

/**
 *  Mention callback with word
 */
- (void)mentionRecognizedWithWord:(NSString *)word;

/**
 *  Set custom css
 */
- (void)setCSS:(NSString *)css;

- (void)hideKeyboard;

@end
