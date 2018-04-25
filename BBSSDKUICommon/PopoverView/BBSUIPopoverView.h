
#import <UIKit/UIKit.h>
#import "BBSUIPopoverAction.h"

@interface BBSUIPopoverView : UIView

@property (nonatomic, assign) BOOL hideAfterTouchOutside; ///< 是否开启点击外部隐藏弹窗, 默认为YES.
@property (nonatomic, assign) BOOL showShade; ///< 是否显示阴影, 如果为YES则弹窗背景为半透明的阴影层, 否则为透明, 默认为NO.
@property (nonatomic, assign) BBSUIPopoverViewStyle style; ///< 弹出窗风格, 默认为 BBSUIPopoverViewStyleDefault(白色).
@property (nonatomic, assign) NSInteger selectType;
@property (nonatomic, assign) NSInteger orderIndex;
@property (nonatomic, assign) BOOL isFashion;//改变字体颜色

+ (instancetype)popoverView;

/*! @brief 指向指定的View来显示弹窗
 *  @param pointView 箭头指向的View
 *  @param actions   动作对象集合<PopoverAction>
 */
- (void)showToView:(UIView *)pointView withActions:(NSArray<BBSUIPopoverAction *> *)actions button:(UIImageView *)button;

/*! @brief 指向指定的点来显示弹窗
 *  @param toPoint 箭头指向的点(这个点的坐标需按照keyWindow的坐标为参照)
 *  @param actions 动作对象集合<PopoverAction>
 */
- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<BBSUIPopoverAction *> *)actions button:(UIButton *)button;

/**
 隐藏回调

 @param hiddenResult 回调
 */
- (void)setHiddenResult:(void (^)())hiddenResult;

@end
