
#import <UIKit/UIKit.h>

@interface BBSUIRTELayoutManager : NSLayoutManager

@property (nonatomic, strong) UIFont *lineNumberFont;
@property (nonatomic, strong) UIColor *lineNumberColor;

@property (nonatomic, readonly) CGFloat gutterWidth;
@property (nonatomic, assign) NSRange selectedRange;

- (CGRect)paragraphRectForRange:(NSRange)range;

@end
