

#import "BBSUIPopoverViewCell.h"
#import "BBSUIMacro.h"

// extern
float const BBSUIPopoverViewCellHorizontalMargin = 40; ///< 水平边距
float const BBSUIPopoverViewCellVerticalMargin = 3.f; ///< 垂直边距
float const BBSUIPopoverViewCellTitleLeftEdge = 8.f; ///< 标题左边边距

@interface BBSUIPopoverViewCell ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, strong)BBSUIPopoverAction *currentAction;

@end

@implementation BBSUIPopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // initialize
    [self initialize];
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = _style == BBSUIPopoverViewStyleDefault ? [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] : [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.00];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - Setter
- (void)setStyle:(BBSUIPopoverViewStyle)style {
    _style = style;
    _bottomLine.backgroundColor = [self.class bottomLineColorForStyle:style];
    if (_style == BBSUIPopoverViewStyleDefault) {
        [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    } else {
        [_button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
}

- (void)setTitleColor:(UIColor *)color
{
    [_button setTitleColor:color forState:UIControlStateNormal];
}

#pragma mark - Private
// 初始化
- (void)initialize {
    // UI
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.userInteractionEnabled = NO; // has no use for UserInteraction.
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.titleLabel.font = [self.class titleFont];
    _button.backgroundColor = self.contentView.backgroundColor;
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//    [_button setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [self.contentView addSubview:_button];
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_button]-margin-|" options:kNilOptions metrics:@{@"margin" : @(BBSUIPopoverViewCellHorizontalMargin)} views:NSDictionaryOfVariableBindings(_button)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_button]-margin-|" options:kNilOptions metrics:@{@"margin" : @(BBSUIPopoverViewCellVerticalMargin)} views:NSDictionaryOfVariableBindings(_button)]];
    // 底部线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLine]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(bottomLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLine(lineHeight)]|" options:kNilOptions metrics:@{@"lineHeight" : @(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(bottomLine)]];
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:14.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(BBSUIPopoverViewStyle)style {
    return style == BBSUIPopoverViewStyleDefault ? [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00] : [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
}

- (void)setAction:(BBSUIPopoverAction *)action {
    _currentAction = action;
//    [_button setImage:action.image forState:UIControlStateNormal];
    [_button setTitle:action.title forState:UIControlStateNormal];
    _button.titleEdgeInsets = action.image ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    
}

- (void)showBottomLine:(BOOL)show {
    _bottomLine.hidden = !show;
}

- (void)changeSelectStatus:(BOOL)selected
{
    if (selected) {
//        [_button setImage:self.currentAction.image forState:UIControlStateNormal];
        if (_currentAction.selectedColor) {
            [_button setTitleColor:_currentAction.selectedColor forState:UIControlStateNormal];
        }else{
            [_button setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
        }
        _button.titleEdgeInsets = self.currentAction.image ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    }else{
//        [_button setImage:self.currentAction.deselectedImage forState:UIControlStateNormal];
        [_button setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
        _button.titleEdgeInsets = self.currentAction.deselectedImage ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    }
}

- (void)changeSelectStatus:(BOOL)selected isFashion:(BOOL)isFashion
{
    if (selected) {
        if (_currentAction.selectedColor) {
            [_button setTitleColor:_currentAction.selectedColor forState:UIControlStateNormal];
        }else{
            if (isFashion) {
                [_button setTitleColor:DZSUIColorFromHex(0xFFAA42) forState:UIControlStateNormal];
            }else {
                [_button setTitleColor:DZSUIColorFromHex(0x5B7EF0) forState:UIControlStateNormal];
            }
            
        }
        
        _button.titleEdgeInsets = self.currentAction.image ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    }else{
        //        [_button setImage:self.currentAction.deselectedImage forState:UIControlStateNormal];
        [_button setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
        _button.titleEdgeInsets = self.currentAction.deselectedImage ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
    }
}


- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
//    [_button setImage:self.currentAction.deselectedImage forState:UIControlStateNormal];
    [_button setTitleColor:DZSUIColorFromHex(0x6A7081) forState:UIControlStateNormal];
    _button.titleEdgeInsets = self.currentAction.deselectedImage ? UIEdgeInsetsMake(0, BBSUIPopoverViewCellTitleLeftEdge, 0, -BBSUIPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
}

@end
