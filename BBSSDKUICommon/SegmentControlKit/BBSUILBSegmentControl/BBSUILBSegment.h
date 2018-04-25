
#import <UIKit/UIKit.h>

@interface BBSUILBSegment : UIControl

typedef NS_ENUM(NSInteger, BBSUISegementItemCurrentStatus) {
    // 当前状态选中
    BBSUISegementItemCurrentStatusSelect,
    // 当前状态正常
    BBSUISegementItemCurrentStatusNormal,
    // 正在取消选中
    BBSUISegementItemCurrentStatusDeselecting,
    // 正在选中
    BBSUISegementItemCurrentStatusSelecting,
};

/**
 *  标题
 */
@property (copy, nonatomic) NSString * title;

/**
 *  标题字体大小
 */
@property (assign, nonatomic) CGFloat titleSize;

/**
 *  选中颜色
 */
@property (strong, nonatomic) UIColor * selectColor;

/**
 *  正常颜色
 */
@property (strong, nonatomic) UIColor * normalColor;

/**
 *  选中标题颜色
 */
@property (strong, nonatomic) UIColor * titleSelectColor;

/**
 *  正常标题颜色
 */
@property (strong, nonatomic) UIColor * titleNormalColor;

/**
 *  选中标题是否加粗
 */
@property (assign, nonatomic) BOOL titleSelectBold;

/**
 *  选中进度 0 ~ 1
 */
@property (assign, nonatomic) CGFloat selectProgress;

/**
 *  当前状态
 */
@property (assign, nonatomic) BBSUISegementItemCurrentStatus currentStatus;

/**
 *  标题是否支持缩放(默认不支持)
 */
@property (assign, nonatomic) BOOL isTitleScale;

- (void)setTitle:(NSString *)title titleSize:(CGFloat)titleSize;

@end
