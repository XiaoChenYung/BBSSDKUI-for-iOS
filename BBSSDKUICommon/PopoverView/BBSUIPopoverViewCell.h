
#import <UIKit/UIKit.h>
#import "BBSUIPopoverAction.h"

UIKIT_EXTERN float const BBSUIPopoverViewCellHorizontalMargin; ///< 水平间距边距
UIKIT_EXTERN float const BBSUIPopoverViewCellVerticalMargin; ///< 垂直边距
UIKIT_EXTERN float const BBSUIPopoverViewCellTitleLeftEdge; ///< 标题左边边距

@interface BBSUIPopoverViewCell : UITableViewCell

@property (nonatomic, assign) BBSUIPopoverViewStyle style;

/*! @brief 标题字体
 */
+ (UIFont *)titleFont;

- (void)setTitleColor:(UIColor *)color;

/*! @brief 底部线条颜色
 */
+ (UIColor *)bottomLineColorForStyle:(BBSUIPopoverViewStyle)style;

- (void)setAction:(BBSUIPopoverAction *)action;

- (void)showBottomLine:(BOOL)show;

- (void)changeSelectStatus:(BOOL)selected;

- (void)changeSelectStatus:(BOOL)selected isFashion:(BOOL)isFashion;



- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled;

@end
