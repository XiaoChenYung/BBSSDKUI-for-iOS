
#import <UIKit/UIKit.h>

typedef NS_ENUM(int16_t, BBSUIRTEFontFamily) {
    
    BBSUIRTEFontFamilyDefault = 0,
    BBSUIRTEFontFamilyTrebuchet = 1,
    BBSUIRTEFontFamilyVerdana = 2,
    BBSUIRTEFontFamilyGeorgia = 3,
    BBSUIRTEFontFamilyPalatino = 4,
    BBSUIRTEFontFamilyTimesNew = 5,
    BBSUIRTEFontFamilyCourierNew = 6,
    
    
};

@protocol BBSUIRTEFontsViewControllerDelegate
- (void)setSelectedFontFamily:(BBSUIRTEFontFamily)fontFamily;
@end

@interface BBSUIRTEFontsViewController : UIViewController {
    
    id<BBSUIRTEFontsViewControllerDelegate> __weak delegate;
    
    BBSUIRTEFontFamily _font;
    
}

+ (BBSUIRTEFontsViewController *)cancelableFontPickerViewControllerWithFontFamily:(BBSUIRTEFontFamily)fontFamily;

- (id)initWithFontFamily:(BBSUIRTEFontFamily)fontFamily;

@property (weak) id<BBSUIRTEFontsViewControllerDelegate> delegate;

@end
