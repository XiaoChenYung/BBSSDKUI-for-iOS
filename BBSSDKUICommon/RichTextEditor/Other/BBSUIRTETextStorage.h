
#import <UIKit/UIKit.h>

@interface BBSUIRTETextStorage : NSTextStorage

@property (nonatomic, strong) NSArray *tokens;
@property (nonatomic, strong) UIFont *defaultFont;

- (void)update;

@end
