
#import <UIKit/UIKit.h>
#import "BBSUIHRColorUtil.h"

@interface BBSUIHRColorCursor : UIView{
    BBSUIHRRGBColor _currentColor;
}


+ (CGSize) cursorSize;
+ (float) outlineSize;
+ (float) shadowSize;

- (id)initWithPoint:(CGPoint)point;
- (void)setColorRed:(float)red andGreen:(float)green andBlue:(float)blue;

@end
