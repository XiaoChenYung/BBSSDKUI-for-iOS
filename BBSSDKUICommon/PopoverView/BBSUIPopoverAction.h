
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BBSUIPopoverViewStyle) {
    BBSUIPopoverViewStyleDefault = 0, // 默认风格, 白色
    BBSUIPopoverViewStyleDark, // 黑色风格
};

@interface BBSUIPopoverAction : NSObject

@property (nonatomic, strong, readonly) UIImage *image; ///< 图标 (建议使用 60pix*60pix 的图片)
@property (nonatomic, copy, readonly) NSString *title; ///< 标题
@property (nonatomic, strong, readonly) UIImage *deselectedImage;
@property (nonatomic, strong, readonly) UIColor *selectedColor;
@property (nonatomic, copy, readonly) void(^handler)(BBSUIPopoverAction *action); ///< 选择回调, 该Block不会导致内存泄露, Block内代码无需刻意去设置弱引用.

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(BBSUIPopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(BBSUIPopoverAction *action))handler;

+ (instancetype)actionWithSelectedImage:(UIImage *)image deselectedImage:(UIImage *)deselectedImage title:(NSString *)title handler:(void (^)(BBSUIPopoverAction *action))handler;

+ (instancetype)actionWithSelectedImage:(UIImage *)image deselectedImage:(UIImage *)deselectedImage title:(NSString *)title selectedTitleColor:(UIColor *)titleColor handler:(void (^)(BBSUIPopoverAction *action))handler;

@end
