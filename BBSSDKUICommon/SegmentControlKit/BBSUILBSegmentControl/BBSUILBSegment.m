
#import "BBSUILBSegment.h"
#import "BBSUILBKitConst.h"

@interface BBSUILBSegment ()

@property (strong, nonatomic) UILabel * titleLabel;

@end

@implementation BBSUILBSegment

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.selectProgress == 1) {
        self.currentStatus = BBSUISegementItemCurrentStatusSelect;
    }
}

/**
 *  正常标题颜色
 */
- (void)setTitleNormalColor:(UIColor *)titleNormalColor {
    _titleNormalColor = titleNormalColor;
    self.titleLabel.textColor = titleNormalColor;
}

- (void)setTitle:(NSString *)title titleSize:(CGFloat)titleSize{
    if (_title.length == 0) {
        
        _title = title;
        _titleSize = titleSize;
        // 初始化
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bbs_width, self.bbs_height)];
        self.titleLabel.font = [UIFont systemFontOfSize:titleSize];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = self.titleNormalColor;
        [self addSubview:self.titleLabel];
    }
    self.titleLabel.text = title;
}

- (void)setSelectProgress:(CGFloat)selectProgress {
    _selectProgress = selectProgress;
    
    // 判断是正常状态、选中状态、正在选中状态、取消选中状态
    if (_selectProgress == 0) {
        // 正常状态
        
        self.currentStatus = BBSUISegementItemCurrentStatusNormal;
    } else if (_selectProgress == 1) {
        // 选中状态
        
        self.currentStatus = BBSUISegementItemCurrentStatusSelect;
    } else if (_selectProgress < _selectProgress) {
        // 正在选中状态
        
        self.currentStatus = BBSUISegementItemCurrentStatusSelecting;
    } else {
        // 取消选中状态
        
        self.currentStatus = BBSUISegementItemCurrentStatusDeselecting;
    }
}

/**
 *  设置当前状态
 */
- (void)setCurrentStatus:(BBSUISegementItemCurrentStatus)currentStatus {
    _currentStatus = currentStatus;
    if (currentStatus == BBSUISegementItemCurrentStatusNormal) {
        // 正常状态
        
        // 设置正常时的标题颜色
        self.titleLabel.textColor = self.titleNormalColor;
        // 设置正常时的背景颜色
        self.backgroundColor = self.normalColor;
        // 设置正常时的标题颜色
        if (self.titleSelectBold == NO) {
            self.titleLabel.font = [UIFont systemFontOfSize:self.titleSize];
        }
        self.titleLabel.transform = CGAffineTransformMakeScale(1, 1);
    } else if (currentStatus == BBSUISegementItemCurrentStatusSelect) {
        // 选中状态
        [self titleScale];
        // 设置选中时的标题颜色
        self.titleLabel.textColor = self.titleSelectColor;
        // 设置选中时的背景颜色
        self.backgroundColor = self.selectColor;
        // 设置选中时的标题颜色
        if (self.titleSelectBold == YES) {
//            self.titleLabel.font = segementTitleSelectFont;
        }
        // 缩放比例
//        CGFloat scaleRatio = LBSegementViewTitleSelectMaxScale;
//        self.titleLabel.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
    } else if (currentStatus == BBSUISegementItemCurrentStatusDeselecting) {
        // 正在取消选中
        
        [self titleScale];
    } else {
        // 正在选中
        
        [self titleScale];
    }
}

- (void)titleScale {
    if (self.isTitleScale == NO) {
        return;
    }
    // 缩放比例
    CGFloat scaleRatio = 1 + self.selectProgress * (BBSUILBSegementViewTitleSelectMaxScale - 1);
    self.titleLabel.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
}

@end



///-----------------------------
/// @name Running Download Tasks
///-----------------------------
