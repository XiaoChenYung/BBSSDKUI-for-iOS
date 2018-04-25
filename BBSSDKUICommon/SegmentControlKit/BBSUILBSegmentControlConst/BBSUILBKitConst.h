
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import "UIView+BBSUIExt.h"
#import "UIView+BBSUIViewController.h"

// 当前设备的物理尺寸
#define BBSUILBkScreen_width [UIScreen mainScreen].bounds.size.width

#define BBSUILBkScreen_height [UIScreen mainScreen].bounds.size.height

#define BBSUILBNavigationBar_Height 64

// 颜色定义
#define BBSUILBkColor(r,g,b,a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]

#pragma mark - BBSUILBSegementView

// 设置标题选中字体(BBSUILBSegementView)
#define BBSUILBSegementTitleSelectFont [UIFont systemFontOfSize:16 weight:1.5]

// 设置标题正常字体(BBSUILBSegementView)
#define BBSUILBSegementTitleNormalFont [UIFont systemFontOfSize:14]

// 设置标题文本颜色(BBSUILBSegementView)
#define BBSUILBSegementColor_title_color [UIColor colorWithRed:180 / 255.0 green:149 / 255.0 blue:111 / 255.0 alpha:1.0]

// 设置标题文本选中颜色(BBSUILBSegementView)
#define BBSUILBSegementColor_title_select_color [UIColor colorWithRed:130 / 255.0 green:79 / 255.0 blue:15 / 255.0 alpha:1.0]


// 常量
// 分段控件标题之间的间距
UIKIT_EXTERN const CGFloat BBSUILBSegementViewTitlePadding;

// 分段控件底部视图的高度
UIKIT_EXTERN const CGFloat BBSUILBSegementViewBottomViewHeight;

// 分段控件标题缩放的最大比例(与正常状态对比)
UIKIT_EXTERN const CGFloat BBSUILBSegementViewTitleSelectMaxScale;




