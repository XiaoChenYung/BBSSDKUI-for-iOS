//
//  BBSUIImagePickerView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSUIBaseView.h"

@protocol iBBSUIImagePickerViewDelegate <NSObject>

- (void) didBeginPickImages ;

- (void) didEndPickImages ;

- (void) didResetAutolayout ;

@end

@interface BBSUIImagePickerView : BBSUIBaseView

@property (nonatomic, weak) id<iBBSUIImagePickerViewDelegate> delegate ;

@property(nonatomic, strong) UIButton *addBtn;
@property (nonatomic, assign) BOOL isXun;

- (NSMutableArray <UIImage*>*)selectedImages ;

- (void) pickImages ;

- (void)cleanData;

- (void)hideAddButton;


@end
