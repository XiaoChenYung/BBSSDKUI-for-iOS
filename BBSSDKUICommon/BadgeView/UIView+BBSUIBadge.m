
#import "UIView+BBSUIBadge.h"
#include <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "BBSUIBadgeLable.h"
const static  void *BBSUIBadgeLableString =&BBSUIBadgeLableString;
@implementation UIView (BBSUIBadge)

//只是设置圆点
-(void)bbs_MakeRedBadge:(CGFloat)corner color:(UIColor *)cornerColor{
    
  //圆点大小
  //圆点颜色
    if ([self bbs_BadgeLable]==nil) {//如果没有绑定就重新创建,然后绑定
        BBSUIBadgeLable *badgeLable =[[BBSUIBadgeLable alloc] init];
        objc_setAssociatedObject(self, BBSUIBadgeLableString, badgeLable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:badgeLable];
    }
    [[self bbs_BadgeLable]setFrame:CGRectMake(self.frame.size.width-corner, -corner, corner*2.0, corner*2.0)];
   
    [[self  bbs_BadgeLable] makeBrdgeViewWithCor:corner CornerColor:cornerColor];
    
}
-(void)bbs_MakeBadgeText:(NSString *)text
               textColor:(UIColor *)tColor
               backColor:(UIColor *)backColor
                    Font:(UIFont*)tfont{
    if ([self bbs_BadgeLable]==nil) {//如果没有绑定就重新创建,然后绑定
        BBSUIBadgeLable *badgeLable =[[BBSUIBadgeLable alloc] init];
        objc_setAssociatedObject(self, BBSUIBadgeLableString, badgeLable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:badgeLable];
    }
    CGSize textSize=[self bbs_sizeWithString:text font:tfont constrainedToWidth:self.frame.size.width];
        if ([self isKindOfClass:[UIButton class]]) {
            UIButton *weakButton=(UIButton*)self;
            [[self  bbs_BadgeLable] makeBrdgeViewWithText:text textColor:tColor backColor:backColor textFont:tfont tframe:CGRectMake(weakButton.imageView.frame.size.width*0.5+weakButton.imageView.frame.origin.x,weakButton.imageView.frame.origin.y, textSize.width+8.0, textSize.height)];
        }else{
    
         [[self  bbs_BadgeLable] makeBrdgeViewWithText:text textColor:tColor backColor:backColor textFont:tfont tframe:CGRectMake(self.frame.size.width-(textSize.width+8.0)*0.5, -textSize.height*0.5, textSize.width+8.0, textSize.height)];
        }
}
-(void)removeBadgeView{
    
    [[self bbs_BadgeLable] removeFromSuperview];
  
}
-(BBSUIBadgeLable *)bbs_BadgeLable{
    
    BBSUIBadgeLable *badgeLable=objc_getAssociatedObject(self, BBSUIBadgeLableString);
    return badgeLable;
}
#pragma mark sizeLableText
-(CGSize)bbs_sizeWithString:(NSString *)string font:(UIFont *)font constrainedToWidth:(CGFloat)width{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:(NSStringDrawingUsesLineFragmentOrigin |
                                                 NSStringDrawingTruncatesLastVisibleLine)
                                     attributes:attributes
                                        context:nil].size;
    } else
    {
        textSize = [string sizeWithFont:textFont
                      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                    options:(NSStringDrawingUsesLineFragmentOrigin |
                                             NSStringDrawingTruncatesLastVisibleLine)
                                 attributes:attributes
                                    context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
    
}

@end
