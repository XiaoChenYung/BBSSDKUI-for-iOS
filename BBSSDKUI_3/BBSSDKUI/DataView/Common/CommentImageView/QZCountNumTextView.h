//
//  QZCountNumTextView.h
//  Application
//
//  Created by MrYu on 2016/12/9.
//  Copyright © 2016年 yu qingzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QZCountNumTextView;

@protocol BBSUIExpressionTextViewDelegate <UITextViewDelegate>

/**
 有内容输入
 */
- (void)expressionTextDidChange:(QZCountNumTextView *)textView textLength:(NSInteger)length;

@end

@interface QZCountNumTextView : UITextView

+ (instancetype)countNumTextView;

@property (nonatomic,copy) NSString *placeholder;

@property (nonatomic,assign) NSInteger maxCount;

@property (nonatomic, strong) NSString *originalString;//用于粘贴复制的字符串
@property (nonatomic, assign) CGFloat defaultFontSize;
@property (nonatomic, weak) id<BBSUIExpressionTextViewDelegate> expressionDelegate;

- (void)setExpressionWithImageName:(NSString *)imageName fontSize:(CGFloat)fontSize;

- (void)textChanged;

- (NSString *)parseAttributeTextToNormalString:(NSAttributedString *)attributedString;

@end
