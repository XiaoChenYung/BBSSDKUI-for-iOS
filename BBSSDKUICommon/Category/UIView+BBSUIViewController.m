
#import "UIView+BBSUIViewController.h"

@implementation UIView (BBSUIViewController)

- (UIViewController *)bbs_viewController
{
    //获取当前对象的下一响应者
    id next = [self nextResponder];
    while (next != nil) {
        //判断next对象是否为控制器
        if ([next isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController *)next).viewControllers[0];
        }else if ([next isKindOfClass:[UIViewController class]])
        {
            return next;
        }
        
        //获取next对象的下一响应这
        next = [next nextResponder];
    }
    
    return nil;
}
@end
