
#import <UIKit/UIKit.h>

CGPoint BBS_CGRectGetCenter(CGRect rect);
CGRect  BBS_CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (BBSUIExt)
@property CGPoint bbs_origin;
@property CGSize bbs_size;

@property (readonly) CGPoint bbs_bottomLeft;
@property (readonly) CGPoint bbs_bottomRight;
@property (readonly) CGPoint bbs_topRight;

@property CGFloat bbs_height;
@property CGFloat bbs_width;

@property CGFloat bbs_top;
@property CGFloat bbs_left;

@property CGFloat bbs_bottom;
@property CGFloat bbs_right;

- (void) bbs_moveBy: (CGPoint) delta;
- (void) bbs_scaleBy: (CGFloat) scaleFactor;
- (void) bbs_fitInSize: (CGSize) aSize;
@end
