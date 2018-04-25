
#import <UIKit/UIKit.h>

@interface UIView (BBSUIBadge)

//设
-(void)bbs_MakeBadgeText:(NSString *)text
               textColor:(UIColor *)tColor
               backColor:(UIColor *)backColor
                    Font:(UIFont*)tfont;


//只设置小圆点
-(void)bbs_MakeRedBadge:(CGFloat)corner color:(UIColor *)cornerColor;

-(void)removeBadgeView;

@end
