//
//  BBSUIPickerView.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/31.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIPickerView.h"


@interface BBSUIPickerView ()


@end
@implementation BBSUIPickerView

- (instancetype)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    // 加载Tap手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    [self addGestureRecognizer:tapRecognizer];
    
    [self loadPickerViewRegion];
}

- (void)loadPickerViewRegion {
    self.pickerRegionHeight = 240;
    
    /* pickerView 区域 */
    self.pickerRegionView = [[UIView alloc] initWithFrame:(CGRect){0, DZSUIScreen_height, DZSUIScreen_width,self.pickerRegionHeight}];
    self.pickerRegionView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.pickerRegionView];
    
    CGFloat controlViewH = 40;
    
    /* 确定、取消 按钮 */
    UIView *controlView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DZSUIScreen_width,controlViewH}];
    controlView.backgroundColor = [UIColor whiteColor];
    [self.pickerRegionView addSubview:controlView];
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:(CGRect){15, 0, 50,controlViewH}];
    cancelBtn.tag = 1;
    [controlView addSubview:cancelBtn];
    
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:(CGRect){DZSUIScreen_width-50-15, 0, 50,controlViewH}];
    confirmBtn.tag = 2;
    [controlView addSubview:confirmBtn];
    
    [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
}


/**
 弹出分享区域
 */
- (void)show
{
    if (!self.superview)
    {
        // 添加到window
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.pickerRegionView.frame = (CGRect){0, DZSUIScreen_height - self.pickerRegionHeight, DZSUIScreen_width,self.pickerRegionHeight};
        } completion:^(BOOL finished) {
            
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
    }
}

/**
 *  隐藏视图
 */
- (void) hide:(id)sender {
    if ([sender isKindOfClass:[UIButton class]] && [(UIButton *)sender tag] == 2)
    {
        if ([self respondsToSelector:self.confirm]) {
            [self performSelector:self.confirm withObject:nil];
        }
    }
    if (self.superview) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.pickerRegionView.frame = (CGRect){0, DZSUIScreen_height, DZSUIScreen_width, self.pickerRegionHeight};
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end


@interface BBSDatePicker ()

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation BBSDatePicker

- (instancetype)init{
    if (self = [super init]) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    /**
     pickView
     */
    CGFloat controlViewH = 40;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:(CGRect){0, controlViewH, DZSUIScreen_width,200}];
    datePicker.maximumDate = [NSDate date];
    [self.pickerRegionView addSubview:datePicker];
    
    datePicker.backgroundColor = [UIColor whiteColor];
    //datePicker.center = self.center;
    //设置本地化支持的语言（在此是中文)
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //显示方式是只显示年月日
    datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker = datePicker;
    
    self.confirm = NSSelectorFromString(@"confirmDate");
    
    [self show];
}

- (void)confirmDate {
    if (self.confirmBlock)
    {
        self.confirmBlock(self.datePicker.date);
    }
}

@end


#define BBSUIUserAvatarTmpPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BBSUIUserAvatar.JPEG"]

@interface BBSPickerView ()<UIPickerViewDataSource,
                            UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *pickerViewProvince;
@property (nonatomic, strong) NSArray <NSDictionary *>*pickerViewCities;    // 所有市、区数据
@property (nonatomic, strong) NSArray *pickerViewRegion;    // 区

@end

@implementation BBSPickerView

- (instancetype)init{
    if (self = [super init]) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    /**
     pickView
     */
    CGFloat controlViewH = 40;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BBSSDKUI.bundle/Data/address" ofType:@"plist"];
    _pickerViewProvince = [NSDictionary dictionaryWithContentsOfFile:path][@"address"];
    _pickerViewCities = _pickerViewProvince[0][@"sub"];
    _pickerViewRegion = _pickerViewCities[0][@"sub"];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:(CGRect){0, controlViewH, DZSUIScreen_width,200}];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [self.pickerRegionView addSubview:pickerView];
    
    self.pickerView = pickerView;
    
    self.confirm = NSSelectorFromString(@"confirmPicker");
    
    [self show];
}

- (void)confirmPicker {
    NSInteger row0 = [self.pickerView selectedRowInComponent:0];
    NSInteger row1 = [self.pickerView selectedRowInComponent:1];
    NSInteger row2 = [self.pickerView selectedRowInComponent:2];
    
    NSString *province = self.pickerViewProvince[row0][@"name"];
    NSString *city = self.pickerViewCities[row1][@"name"];
    NSString *region = self.pickerViewCities[row1][@"sub"][row2];
    
    if (self.confirmBlock)
    {
        self.confirmBlock(province, city, region);
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger rows = 0;
    switch (component) {
        case 0:
            rows = self.pickerViewProvince.count;
            break;
        case 1:
            rows = self.pickerViewCities.count;
            break;
        case 2:
            rows = self.pickerViewRegion.count;
            break;
        default:
            break;
    }
    return rows;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString * title = nil;
    switch (component) {
        case 0:
            title = self.pickerViewProvince[row][@"name"];
            break;
        case 1:
            title = self.pickerViewCities[row][@"name"];
            break;
        case 2:
            title = self.pickerViewRegion[row];
            break;
        default:
            break;
    }
    return title;
}

//选中时回调的委托方法，在此方法中实现联动
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:
            self.pickerViewCities = self.pickerViewProvince[row][@"sub"];
            self.pickerViewRegion = self.pickerViewCities[0][@"sub"];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            break;
        case 1:
            self.pickerViewRegion = self.pickerViewCities[row][@"sub"];
            [pickerView reloadComponent:2];
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
}

@end




