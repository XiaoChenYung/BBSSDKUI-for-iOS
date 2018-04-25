
#import <UIKit/UIKit.h>
#import "BBSUIHRColorPickerMacros.h"

@class BBSUIHRColorPickerView;

@protocol BBSUIHRColorPickerViewControllerDelegate
- (void)setSelectedColor:(UIColor*)color tag:(int)tag;
@end

#define BBSUIHRColorPickerDelegate BBSUIHRColorPickerViewControllerDelegate
// Delegateの名前変えました。すみません。

typedef enum {
    BBSUIHCPCSaveStyleSaveAlways,
    BBSUIHCPCSaveStyleSaveAndCancel
} BBSUIHCPCSaveStyle;

@interface BBSUIHRColorPickerViewController : UIViewController {
    id<BBSUIHRColorPickerViewControllerDelegate> __weak delegate;
    BBSUIHRColorPickerView* colorPickerView;
    
    UIColor *_color;
    BOOL _fullColor;
    BBSUIHCPCSaveStyle _saveStyle;
    
}

@property (nonatomic) int tag;

+ (BBSUIHRColorPickerViewController *)colorPickerViewControllerWithColor:(UIColor *)color;
+ (BBSUIHRColorPickerViewController *)cancelableColorPickerViewControllerWithColor:(UIColor *)color;
+ (BBSUIHRColorPickerViewController *)fullColorPickerViewControllerWithColor:(UIColor *)color;
+ (BBSUIHRColorPickerViewController *)cancelableFullColorPickerViewControllerWithColor:(UIColor *)color;

/** Initialize controller with selected color. 
 * @param defaultColor selected color
 * @param fullColor If YES, browseable full color. If NO color was limited.
 * @param saveStyle If it's HCPCSaveStyleSaveAlways, save color when self is closing. If it's HCPCSaveStyleSaveAndCancel, shows Cancel and Save button.
 */
- (id)initWithColor:(UIColor*)defaultColor fullColor:(BOOL)fullColor saveStyle:(BBSUIHCPCSaveStyle)saveStyle;

/** @deprecated use -save: instead of this . */
- (void)saveColor:(id)sender;

- (void)save;
- (void)save:(id)sender;
- (void)cancel:(id)sender;


@property (weak) id<BBSUIHRColorPickerViewControllerDelegate> delegate;


@end
