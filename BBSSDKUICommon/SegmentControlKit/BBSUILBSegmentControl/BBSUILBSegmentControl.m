
#import "BBSUILBSegmentControl.h"
#import "BBSUILBKitConst.h"
#import "BBSUILBSegment.h"
#import "UIView+BBSUIViewController.h"

typedef NS_ENUM(NSInteger, BBSUILBScrollCtrlViewScrollStatus) {
    // 当前状态向左移动
    BBSUILBScrollCtrlViewScrollStatusToLeft,
    // 当前状态向右移动
    BBSUILBScrollCtrlViewScrollStatusToRight,
    // 正在状态静止
    BBSUILBScrollCtrlViewScrollStatusStatic,
};

@interface BBSUILBSegmentControl () <UIScrollViewDelegate>

/**
 *  是否是滑动标题
 */
@property (assign, nonatomic) BOOL isScrollTitle;

/**
 *  字体大小
 */
@property (assign, nonatomic) CGFloat titleSize;

/**
 *  标题栏滑动试图
 */
@property (strong, nonatomic) UIScrollView * segementScrollView;

/**
 *  控制器试图滑动试图
 */
@property (strong, nonatomic) UIScrollView * scrollCtrlView;

/**
 *  底部栏试图
 */
@property (strong, nonatomic) UIView * bottomView;

/**
 *  当前选中索引
 */
@property (assign, nonatomic) BBSUILBSegment * currentItem;

/**
 *  将要选中的Item
 */
@property (assign, nonatomic) BBSUILBSegment * nextItem;

/**
 *  滑动控制器视图（下面的ScrollView）滑动状态
 */
@property (assign, nonatomic) BBSUILBScrollCtrlViewScrollStatus scrollCtrlViewScrollStatus;

/**
 *  选中进度(1:选中状态，0:正常状态)
 */
@property (assign, nonatomic) CGFloat currentSelectProgress;

@property (strong, nonatomic) UIView *seperateView;

@property (nonatomic, assign) CGFloat currentContentOffSet;

@end

@implementation BBSUILBSegmentControl

#pragma mark - Lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.currentItem = [self.segementScrollView viewWithTag:1995 + 0];
    
    // 必须要在这个方法中调用，因为在这里才可以知道响应者链的顺序
    [self.bbs_viewController.view addSubview:self.scrollCtrlView];
    
    if (self.isIntegrated) {
        [self.scrollCtrlView setFrame:CGRectMake(0, 0, BBSUILBkScreen_width, CGRectGetHeight(self.bbs_viewController.view.frame))];
    }
    if (self.notScroll)
    {
        self.scrollCtrlView.scrollEnabled = NO;
    }
    
    // 创建默认的控制器试图
    [self addCtrlViewToScrollViewWithCtrlIndex:0];
    
    // 设置默认选中的Item
    self.currentItem.selectProgress = 1;
    // 为标题设置属性
    if (self.titles.count != 0) {
        for (UIView * subview in self.segementScrollView.subviews) {
            if ([subview isKindOfClass:[BBSUILBSegment class]]) {
                BBSUILBSegment * segment = (BBSUILBSegment *)subview;
                segment.titleNormalColor = self.titleNormalColor;
                segment.titleSelectColor = self.titleSelectColor;
                segment.isTitleScale = self.isTitleScale;
            }
        }
    }
    
    if (self.bottomViewIsAlignment) {
        
        CGSize labelSize = [self sizeWithText:self.titles[0] font:BBSUILBSegementTitleNormalFont maxSize:CGSizeMake(BBSUILBkScreen_width, self.bbs_height)];
        [self.bottomView setFrame:CGRectMake((CGRectGetWidth(self.currentItem.bounds) - labelSize.width) / 2, self.bottomView.frame.origin.y, labelSize.width, CGRectGetHeight(self.bottomView.bounds))];
        
    }else{
        // 设置底部条的宽度
        self.bottomView.bbs_width = self.currentItem.bbs_width;
        // 设置底部条x值
        self.bottomView.bbs_left = 0;
    }
    
    if (self.bottomView.subviews.count != 0) {
        UIImageView * imageView = [self.bottomView.subviews firstObject];
        imageView.bbs_left = (self.bottomView.bbs_width - imageView.bbs_width) / 2;
    }
}

/**
 *  初始化静止标题栏（不可左右拖动）
 */
- (instancetype)initStaticTitlesWithFrame:(CGRect)frame titleFontSize:(CGFloat)titleSize isIntegrated:(BOOL)isIntegrated{
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.isIntegrated = isIntegrated;
        self.titleSize = titleSize;
        self.isScrollTitle = NO;
        [self initDefault];
        [self creatSegementScrollView];
    }
    return self;
}

/**
 *  初始化滑动标题栏（可以左右拖动）
 */
- (instancetype)initScrollTitlesWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.isScrollTitle = YES;
        self.titleSize = 14;
        [self initDefault];
        [self creatSegementScrollView];
    }
    return self;
}

- (void)initDefault {
    self.titleNormalColor = BBSUILBSegementColor_title_color;
    self.titleSelectColor = BBSUILBSegementColor_title_select_color;
    // 防止在存在导航栏的情况下ScrollView向下偏移64像素
    UIView * view = [[UIView alloc] init];
    [self addSubview:view];
    
    _seperateView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds), 1)];
    [_seperateView setBackgroundColor:[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1]];
    [self addSubview:_seperateView];
}
/**
 *  创建标题栏
 */
- (void)creatSegementScrollView {
    self.segementScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bbs_width, self.bbs_height)];
    // 隐藏滑动条
    self.segementScrollView.showsVerticalScrollIndicator = NO;
    self.segementScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.segementScrollView];
    
    self.scrollCtrlView.scrollEnabled = NO;
    self.segementScrollView.scrollEnabled = self.isScrollTitle;
}

/**
 *  创建滑动控制器试图
 */
- (void)creatScrollCtrlView {
    // 滑动控制器试图y值
    CGFloat scrollCtrlViewY = self.bbs_origin.y + self.bbs_height;
    // 创建滑动控制器试图
    self.scrollCtrlView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollCtrlViewY, BBSUILBkScreen_width, BBSUILBkScreen_height - scrollCtrlViewY)];
    self.scrollCtrlView.contentSize = CGSizeMake(self.viewControllers.count * BBSUILBkScreen_width, 0);
    // 隐藏滑动条
    self.scrollCtrlView.showsVerticalScrollIndicator = NO;
    self.scrollCtrlView.showsHorizontalScrollIndicator = NO;
    self.scrollCtrlView.backgroundColor = [UIColor whiteColor];
    // 取消回弹效果
    self.scrollCtrlView.bounces = NO;
    self.scrollCtrlView.delegate = self;
    self.scrollCtrlView.pagingEnabled = YES;
}

#pragma mark - Custom Accessors

- (void)setTitles:(NSArray *)titles {
    _titles = titles;

    // Item的宽度
    CGFloat itemW = 0.0;
    CGFloat itemX = 0.0;
    
    for (int i = 0; i < titles.count; i ++) {
        // 判断是滑动还是静止标题栏
        if (self.isScrollTitle == YES) {
            // 滑动标题栏
            
            // 计算文本标签的Size
            CGSize labelSize = [self sizeWithText:titles[i] font:BBSUILBSegementTitleNormalFont maxSize:CGSizeMake(BBSUILBkScreen_width, self.bbs_height)];
            // 计算Item的宽度  Item的宽度 = 本标签的宽度 + 间距
            itemW = labelSize.width + BBSUILBSegementViewTitlePadding / 2;
    
            // 设置contentSize
//            self.segementScrollView.contentSize = [self getContentSize];
            // 滑动标题栏Item的x值在后面进行计算
        } else {
            // 静止标题栏
            
            // Item的宽度
            itemW = self.bbs_width / titles.count;
            // Item的x值
            itemX = i * itemW;
            // 设置contentSize
//            self.segementScrollView.contentSize = CGSizeMake(LBkScreen_width, 0);
        }
        
        BBSUILBSegment * segment = [[BBSUILBSegment alloc] initWithFrame:CGRectMake(itemX, 0, itemW, self.bbs_height)];
        [segment setTitle:titles[i] titleSize:self.titleSize];
        segment.titleNormalColor = self.titleNormalColor;
        segment.titleSelectColor = self.titleSelectColor;
        
        segment.titleSelectBold = YES;
        segment.tag = 1995 + i;
        [segment addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.segementScrollView addSubview:segment];
        
        // 计算滑动标题栏Item的x值
        itemX += itemW;
    }
    
    if (self.isScrollTitle == YES) {
        self.segementScrollView.contentSize = CGSizeMake(itemX, 0);
    }else{
        self.segementScrollView.contentSize = CGSizeMake(BBSUILBkScreen_width > self.bbs_width? self.bbs_width:BBSUILBkScreen_width, 0);
    }
}

- (NSArray <BBSUILBSegment *>*)settingTitles:(NSArray *)titles{
    _titles = titles;
    NSMutableArray *segments = [NSMutableArray arrayWithCapacity:2];
    
    // Item的宽度
    CGFloat itemW = 0.0;
    CGFloat itemX = 0.0;
    for (int i = 0; i < titles.count; i ++) {
        // 判断是滑动还是静止标题栏
        if (self.isScrollTitle == YES) {
            // 滑动标题栏
            
            // 计算文本标签的Size
            CGSize labelSize = [self sizeWithText:titles[i] font:BBSUILBSegementTitleNormalFont maxSize:CGSizeMake(BBSUILBkScreen_width, self.bbs_height)];
            // 计算Item的宽度  Item的宽度 = 本标签的宽度 + 间距
            itemW = labelSize.width + BBSUILBSegementViewTitlePadding / 2;
            // 设置contentSize
//            self.segementScrollView.contentSize = [self getContentSize];
            // 滑动标题栏Item的x值在后面进行计算
        } else {
            // 静止标题栏
            
            // Item的宽度
            itemW = self.bbs_width / titles.count;
            // Item的x值
            itemX = i * itemW;
            // 设置contentSize
//            self.segementScrollView.contentSize = CGSizeMake(LBkScreen_width, 0);
        }
        BBSUILBSegment * segment = [[BBSUILBSegment alloc] initWithFrame:CGRectMake(itemX, 0, itemW, self.bbs_height)];
        [segment setTitle:titles[i] titleSize:self.titleSize];
        segment.titleNormalColor = self.titleNormalColor;
        segment.titleSelectColor = self.titleSelectColor;
        
        segment.titleSelectBold = YES;
        segment.tag = 1995 + i;
        [segment addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.segementScrollView addSubview:segment];
        [segments addObject:segment];
        
        // 计算滑动标题栏Item的x值
        itemX += itemW;
        
        if (self.isScrollTitle == YES) {
            self.segementScrollView.contentSize = CGSizeMake(itemX, 0);
        }else{
            self.segementScrollView.contentSize = CGSizeMake(BBSUILBkScreen_width > self.bbs_width? self.bbs_width:BBSUILBkScreen_width, 0);
        }
    }
    
    return segments;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    
    [self creatScrollCtrlView];
}

- (void)setIsIntegrated:(BOOL)isIntegrated
{
    _isIntegrated = isIntegrated;
    
    [_seperateView setHidden:isIntegrated];
    
    if (_isIntegrated) {
//        self.segementScrollView.contentSize = CGSizeMake(self.width, 0);
    }
}

#pragma mark - IBActions(事件)
/**
 *  标题项点击事件
 */
- (void)itemAction:(BBSUILBSegment *)segment {
    
//    NSLog(@"=====________ %@ %@",self.currentItem.title, self.nextItem.title);
    [self _settingCurrentContentOffSet];
    
    // 设置滑动试图的偏移量
    [self.scrollCtrlView setContentOffset:CGPointMake(BBSUILBkScreen_width * (segment.tag - 1995), 0) animated:NO];
    
    // 赋值
    self.currentItem = segment;
    [self setSegementAnimate];
    [self _settingNextContentOffSet];
}

#pragma mark - Public

/**
 *  设置底部栏颜色(和底部栏图片只能设置一个)
 */
- (void)setBottomViewColor:(UIColor *)color {
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bbs_height - BBSUILBSegementViewBottomViewHeight, 0, BBSUILBSegementViewBottomViewHeight)];
    self.bottomView.backgroundColor = color;
    [self.segementScrollView addSubview:self.bottomView];
}

/**
 *  设置底部栏图片(和底部栏颜色只能设置一个)
 */
- (void)setBottomViewImage:(UIImage *)image {
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bbs_height - 10, 0, 10)];
    [self.segementScrollView addSubview:self.bottomView];
    // 设置图片
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    imageView.image = image;
    [self.bottomView addSubview:imageView];
}

/**
 *  取消底部栏
 */
- (void)cancelBottomView {
    self.bottomView = nil;
}

- (void)setNotScroll:(BOOL)notScroll
{
    _notScroll = notScroll;
//    self.scrollCtrlView.scrollEnabled = !notScroll;
}
#pragma mark - Private

/**
 *  添加控制器的视图到滑动试图上
 */
- (void)addCtrlViewToScrollViewWithCtrlIndex:(NSInteger)ctrlIndex {
    // 创建试图控制器
    UIViewController * VC = self.viewControllers[ctrlIndex];
    // 判断试图有没有加载过
//    if ([VC isViewLoaded]) {
//        return;
//    }
    // 设置子视图
    
    if (self.isIntegrated) {
        VC.view.frame = CGRectMake(ctrlIndex * BBSUILBkScreen_width, 0, BBSUILBkScreen_width, CGRectGetHeight(self.scrollCtrlView.frame));
    }else if (self.viewHeight){
        VC.view.frame = CGRectMake(ctrlIndex * BBSUILBkScreen_width, 0, BBSUILBkScreen_width, self.viewHeight);
    }else{
        VC.view.frame = CGRectMake(ctrlIndex * BBSUILBkScreen_width, 0, BBSUILBkScreen_width, BBSUILBkScreen_height - BBSUILBNavigationBar_Height - self.bbs_height);
    }
    
    [self.scrollCtrlView addSubview:VC.view];
    [self.bbs_viewController addChildViewController:VC];
}

/**
 *  获取ContentSize
 */
- (CGSize)getContentSize {
    NSString * titleString = @"";
    for (NSString * title in self.titles) {
        titleString = [titleString stringByAppendingString:title];
    }
    // 计算总字符串得宽度
    CGSize stringWidth = [self sizeWithText:titleString font:BBSUILBSegementTitleNormalFont maxSize:CGSizeMake(MAXFLOAT, self.bbs_height)];
    // 加上间距
    CGFloat totalWidth = stringWidth.width + self.titles.count * (BBSUILBSegementViewTitlePadding / 2);
    
    return CGSizeMake(totalWidth, 0);
}

/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize fontSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    return CGSizeMake(fontSize.width + 10, fontSize.height);
}


/**
 *  修改选中进度
 */
- (void)changeSelectProgressWithCurrentIndex:(NSInteger)currentIndex {
    // 计算出当前选择的Item
    CGFloat selectIndex = self.scrollCtrlView.contentOffset.x / BBSUILBkScreen_width;
    // 计算出变化跨度是几
    CGFloat changeIndexNumber = selectIndex - currentIndex;
    // 取绝对值，向上取整操作
    changeIndexNumber = ceil(fabs(changeIndexNumber));
    // 获取将要选中的Item
    if (self.scrollCtrlViewScrollStatus == BBSUILBScrollCtrlViewScrollStatusToLeft) {
        // 试图向左拖拽
        self.nextItem = [self.segementScrollView viewWithTag:self.currentItem.tag + changeIndexNumber];
    } else if (self.scrollCtrlViewScrollStatus == BBSUILBScrollCtrlViewScrollStatusToRight) {
        // 试图向右拖拽
        self.nextItem = [self.segementScrollView viewWithTag:self.currentItem.tag - changeIndexNumber];
    }
    [UIView animateWithDuration:0.3 animations:^{
        // 设置将要选中Item的选择进度
        self.nextItem.selectProgress = 1 - self.currentSelectProgress;
        self.currentItem.selectProgress = self.currentSelectProgress;
        // 设置底部栏视图
        // 两个标题项中宽度的差
        CGFloat differenceW = self.nextItem.bbs_width - self.currentItem.bbs_width;
        // 设置动画增长或缩短宽度
//        self.bottomView.width = self.currentItem.width + (differenceW * (1 - self.currentSelectProgress));
        CGSize labelSize = [self sizeWithText:self.titles[currentIndex] font:BBSUILBSegementTitleNormalFont maxSize:CGSizeMake(BBSUILBkScreen_width, self.bbs_height)];
        self.bottomView.bbs_width = labelSize.width;
        // 两个标题项中x的差
        CGFloat differenceX = self.nextItem.bbs_left - self.currentItem.bbs_left;
        // 设置动画修改x值
        self.bottomView.bbs_left = self.currentItem.bbs_left + (differenceX * (1 - self.currentSelectProgress)) + (self.currentItem.bbs_width - self.bottomView.bbs_width) / 2;
        // 判断底部条是否是图片，如果是图片设置图片
        if (self.bottomView.subviews.count != 0) {
            UIImageView * imageView = [self.bottomView.subviews firstObject];
            imageView.bbs_left = (self.bottomView.bbs_width - imageView.bbs_width) / 2;
        }
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectIndex:)]) {
        [self.delegate selectIndex:selectIndex];
    }
}

/**
 *  设置标题栏动画
 */
- (void)setSegementAnimate {
    // 当前选中的Item
    BBSUILBSegment * currentItem = self.currentItem;
    // 标题栏动画
    if (self.segementScrollView.contentSize.width <= BBSUILBkScreen_width)
    {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        // 判断能否设置居中（除开距离不够的）
        if (currentItem.center.x > (self.bbs_width / 2) && currentItem.center.x < (self.segementScrollView.contentSize.width - self.bbs_width / 2)) {
            // 居中的偏移量 = 标题按钮的偏移量 - 屏幕宽度的一半
            CGFloat contentOffsetX = currentItem.center.x - (BBSUILBkScreen_width / 2);
            self.segementScrollView.contentOffset = CGPointMake(contentOffsetX, 0);
        } else if (currentItem.center.x < self.bbs_width / 2) {
            self.segementScrollView.contentOffset = CGPointMake(0, 0);
        } else if (currentItem.center.x > (self.segementScrollView.contentSize.width - self.bbs_width / 2)) {
            self.segementScrollView.contentOffset = CGPointMake(self.segementScrollView.contentSize.width - (self.bbs_width), 0);
        }
    }];
}

- (void)_settingCurrentContentOffSet
{
    if (_tableViewY != 0)
    {
        id vc = self.viewControllers[self.currentItem.tag-1995];
        UITableView *tableView = [vc valueForKey:@"homeTableView"];
        
        _currentContentOffSet = tableView.contentOffset.y;
    }
}

- (void)_settingNextContentOffSet
{
    if (_tableViewY != 0)
    {
        id vc = self.viewControllers[self.nextItem.tag-1995];
        UITableView *tableView = [vc valueForKey:@"homeTableView"];
        
        CGFloat nextOffSetY = tableView.contentOffset.y;
        
        if (_currentContentOffSet <= _tableViewY)
        {
            nextOffSetY = _currentContentOffSet;
            
            if (_currentContentOffSet > nextOffSetY)
            {
                
            }else
            {
                
            }
            
        }
        else if (_currentContentOffSet > _tableViewY && nextOffSetY < _tableViewY)
        {
            nextOffSetY = _tableViewY;
        }
        
        tableView.contentOffset = CGPointMake(0, nextOffSetY);
    }
    
    if (self.changeControllerBlock)
    {
        self.changeControllerBlock(self.nextItem.tag-1995);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = self.currentItem.tag - 1995;
    
    [self _settingCurrentContentOffSet];
    
    if (scrollView.contentOffset.x > (currentIndex * BBSUILBkScreen_width)) {
        // 向左滑动，偏移量变大
        self.currentSelectProgress = 1 - (fmod (scrollView.contentOffset.x, BBSUILBkScreen_width) / BBSUILBkScreen_width);
        // 设置手势是向左滑动
        self.scrollCtrlViewScrollStatus = BBSUILBScrollCtrlViewScrollStatusToLeft;
        
        
        
        // 保持从0 -> 1，也就是从非选中到选中状态
        if (self.currentSelectProgress == 0) {
            self.currentSelectProgress = 1;
        } else if (self.currentSelectProgress == 1) {
            self.currentSelectProgress = 0;
        }
    } else if (scrollView.contentOffset.x < (currentIndex * BBSUILBkScreen_width)) {
        // 向右滑动，偏移量变小
        self.currentSelectProgress = fmod (scrollView.contentOffset.x, BBSUILBkScreen_width) / BBSUILBkScreen_width;
        // 设置手势是向右滑动
        self.scrollCtrlViewScrollStatus = BBSUILBScrollCtrlViewScrollStatusToRight;
    }
    // 修改选中进度
    [self changeSelectProgressWithCurrentIndex:currentIndex];
    
    // 判断选中进度（其实不判断也可以，判断就不会一直调用节省性能）
    if (self.currentSelectProgress > 0.95 || self.currentSelectProgress == 0.0) {
        // 添加控制器试图到滑动试图上
        [self addCtrlViewToScrollViewWithCtrlIndex:self.nextItem.tag - 1995];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = scrollView.contentOffset.x / BBSUILBkScreen_width;
    self.currentItem = [self.segementScrollView viewWithTag:currentIndex + 1995];
    scrollView.scrollEnabled = YES;
    [self setSegementAnimate];
    
    [self _settingNextContentOffSet];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollView.scrollEnabled = NO;
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = YES;
    [self setSegementAnimate];
}


@end
