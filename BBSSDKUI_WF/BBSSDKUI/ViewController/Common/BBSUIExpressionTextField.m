//
//  BBSUIExpressionTextField.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/10/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIExpressionTextField.h"
#import "BBSUIExpressionViewConfiguration.h"
#import "UITextField+ExtentRange.h"

@interface BBSUIExpressionTextField()<UITextViewDelegate>
@end

@implementation BBSUIExpressionTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    // 表情
    //    if ([self.expressionDelegate respondsToSelector:@selector(expressionTextDidChange:textLength:)]) {
    //        [self.expressionDelegate expressionTextDidChange:self textLength:self.attributedText.length];
    //    }
}

#pragma mark - 表情
- (void)setExpressionWithImageName:(NSString *)imageName fontSize:(CGFloat)fontSize
{
    //富文本
    BBSUIExpressionTextAttachment *attachment = [[BBSUIExpressionTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"BBSSDKUI.bundle/Emoji/%@",imageName]];
    attachment.image = image;
    attachment.text = [BBSUIExpressionTool getExpressionStringWithImageName:imageName];
    attachment.bounds = CGRectMake(0, 0, fontSize, fontSize);
    NSAttributedString *insertAttributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *resultAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    //在当前编辑位置插入字符串
    [resultAttrString insertAttributedString:insertAttributeStr atIndex:self.selectedRange.location];
    
    NSRange tempRange = self.selectedRange;
    
    self.attributedText = resultAttrString;
    
    self.selectedRange = NSMakeRange(tempRange.location + 1, 0);
    
//    [self.attributedText addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:NSMakeRange(0, self.attributedText.length)];
    
//    [self scrollRangeToVisible:self.selectedRange];
    
    [self textViewDidChange:self];
}



- (void)textChange:(NSNotification *)noti
{
    return;
    NSLog(@"%@", self.attributedText);
    
    NSRange tempRange = self.selectedRange;
    //     self.attributedText = [BBSUIExpressionTool generateAttributeStringWithOriginalString:[self  parseAttributeTextToNormalString:self.attributedText] fontSize:_defaultFontSize];
    
//    [self.attributedText addAttributes:self.typingAttributes range:NSMakeRange(0, self.attributedText.length)];
//    [self.attributedText ]
//    
//    [self.attributedText addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:_defaultFontSize]} range:NSMakeRange(0, self.attributedText.length)];
    
//    [self scrollRangeToVisible:self.selectedRange];
    
    self.selectedRange = NSMakeRange(tempRange.location, 0);
}

- (NSString *)parseAttributeTextToNormalString:(NSAttributedString *)attributedString
{
    NSMutableString *normalString = [NSMutableString string];
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        BBSUIExpressionTextAttachment *attachment = attrs[@"NSAttachment"];
        
        if (attachment) {//图片
            NSLog(@"图片");
            [normalString appendString:attachment.text];
        }else{//文字
            NSLog(@"文字");
            NSAttributedString *attrStr = [attributedString attributedSubstringFromRange:range];
            
            [normalString appendString:attrStr.string];
        }
    }];
    
    return normalString;
}





#pragma mark - Actions
- (void)copy:(id)sender
{
    NSAttributedString *selectedString = [self.attributedText attributedSubstringFromRange:self.selectedRange];
    NSString *copyString = [self parseAttributeTextToNormalString:selectedString];
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    if (copyString.length != 0) {
        pboard.string = copyString;
    }
}

- (void)cut:(id)sender
{
    [self copy:sender];
    
    NSMutableAttributedString *originalString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [originalString deleteCharactersInRange:self.selectedRange];
    self.attributedText = originalString;
    
    NSLog(@"--%@", NSStringFromRange(self.selectedRange));
    [self textChanged];
}

- (void)textChanged
{
    [self textViewDidChange:self];
}

@end


@interface UITextField (ExtentRange)

- (NSRange) selectedRange;
- (void) setSelectedRange:(NSRange) range;

@end

@implementation UITextField (ExtentRange)

- (NSRange) selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void) setSelectedRange:(NSRange) range  // 备注：UITextField必须为第一响应者才有效
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

@end


