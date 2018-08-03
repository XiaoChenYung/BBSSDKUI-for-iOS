//
//  QZCountNumTextView.m
//  Application
//
//  Created by MrYu on 2016/12/9.
//  Copyright © 2016年 yu qingzhu. All rights reserved.
//

#import "QZCountNumTextView.h"
#import "UIView+BBSUIExt.h"
#import "BBSUIExpressionViewConfiguration.h"
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QZCountNumTextView ()<UITextViewDelegate>
{
    UILabel *_placeholderLabel;
    UILabel *_countLabel;
}
@end

@implementation QZCountNumTextView

+ (instancetype)countNumTextView
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
        [self makeSubviews];
        self.delegate = self;
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _defaultFontSize = self.font.pointSize;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setFrameForSubviews];
}

- (void)setFrameForSubviews
{
    _placeholderLabel.frame =CGRectMake(5, 10, self.bounds.size.width - 10, 10);
    _countLabel.frame = CGRectMake(self.bounds.size.width - 100 - 5, self.bounds.size.height - 25, 100, 25);
    
}


- (void)makeSubviews
{
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = [UIFont systemFontOfSize:14];
    _placeholderLabel.textColor = UIColorFromRGB(0xcacaca);
    [self addSubview:_placeholderLabel];
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:14];
    _countLabel.textColor = UIColorFromRGB(0xcacaca);
    _countLabel.textAlignment = NSTextAlignmentRight;
//    [self addSubview:_countLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:self];
    
    _defaultFontSize = 14;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _placeholderLabel.hidden = textView.textStorage.length > 0;
    _countLabel.text = textView.text.length > self.maxCount ? [NSString stringWithFormat:@"-%ld",textView.text.length - self.maxCount ] : [NSString stringWithFormat:@"%ld",textView.text.length];
    
    // 表情
//    if ([self.expressionDelegate respondsToSelector:@selector(expressionTextDidChange:textLength:)]) {
//        [self.expressionDelegate expressionTextDidChange:self textLength:self.attributedText.length];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        textView.text = [NSString stringWithFormat:@"%@%@",textView.text,text];
    }
    return YES;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderLabel.text = placeholder;
//    [_placeholderLabel sizeToFit];
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
    
    [self.textStorage addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:_defaultFontSize]} range:NSMakeRange(0, self.attributedText.length)];
    
    [self scrollRangeToVisible:self.selectedRange];
    
    [self textViewDidChange:self];
}



- (void)textChange:(NSNotification *)noti
{
    return;
    NSLog(@"%@", self.textStorage);
    
    NSRange tempRange = self.selectedRange;
    //     self.attributedText = [BBSUIExpressionTool generateAttributeStringWithOriginalString:[self  parseAttributeTextToNormalString:self.attributedText] fontSize:_defaultFontSize];
    
    [self.textStorage addAttributes:self.typingAttributes range:NSMakeRange(0, self.attributedText.length)];
    
    
    
    [self.textStorage addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:_defaultFontSize]} range:NSMakeRange(0, self.attributedText.length)];
    
    [self scrollRangeToVisible:self.selectedRange];
    
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
