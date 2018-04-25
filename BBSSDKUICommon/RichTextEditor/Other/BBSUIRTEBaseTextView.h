
#import <UIKit/UIKit.h>
#import "BBSUIRTEToken.h"

@interface BBSUIRTEBaseTextView : UITextView

@property (nonatomic, strong) NSArray *tokens;
@property (nonatomic, strong) UIPanGestureRecognizer *singleFingerPanRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *doubleFingerPanRecognizer;

@property UIColor *gutterBackgroundColor;
@property UIColor *gutterLineColor;

@property (nonatomic, assign) BOOL lineCursorEnabled;

@end
