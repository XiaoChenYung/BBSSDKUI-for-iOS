//
//  BBSUIPickerView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/31.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

@interface BBSUIPickerView : BBSUIBaseView

@property (nonatomic, strong) UIView *pickerRegionView;
@property (nonatomic, assign) CGFloat pickerRegionHeight;

@property (nonatomic, assign) SEL confirm;

@property (nonatomic, copy)  void(^confirmBlock)();

- (void)show;

@end


@interface BBSDatePicker : BBSUIPickerView

@end

@interface BBSPickerView : BBSUIPickerView

@end





