//
//  BBSUIImagePickerView.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iBBSUIImagePickerViewDelegate <NSObject>

- (void) didBeginPickImages ;

- (void) didEndPickImages ;

- (void) didResetAutolayout ;

@end

@interface BBSUIImagePickerView : UIView

@property (nonatomic, weak) id<iBBSUIImagePickerViewDelegate> delegate ;
- (NSMutableArray <UIImage*>*)selectedImages ;

- (void) pickImages ;

@end
