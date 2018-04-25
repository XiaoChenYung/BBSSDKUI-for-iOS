//
//  BBSUIActionSheet.h
//  BBSLBSPro
//
//  Created by wukx on 2018/4/5.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBSUIActionSheetDelegate<NSObject>

-(void)bbsui_actionSheetClickWithIndex:(int)index;

@end

@interface BBSUIActionSheet : UIView

@property(nonatomic,weak) id <BBSUIActionSheetDelegate> delegate;

//默认取消按钮颜色
@property(nonatomic,strong) UIColor *cancelDefaultColor;

//默认选项按钮颜色
@property(nonatomic,strong) UIColor *optionDefaultColor;

//创建标题形式ActionSheet
+(instancetype)actionSheetWithTitleArray:(NSArray *)titleArray  andTitleColorArray:(NSArray *)colors delegate:(id<BBSUIActionSheetDelegate>)delegate;
+(instancetype)actionSheetWithTitleArray:(NSArray *)titleArray  andTitleColorArray:(NSArray *)colors block:(void (^)(int index)) block;

//创建图片形式ActionSheet
+(instancetype)actionSheetWithImageArray:(NSArray *)imgArray delegate:(id<BBSUIActionSheetDelegate>)delegate;
+(instancetype)actionSheetWithImageArray:(NSArray *)imgArray block:(void (^)(int index)) block;

//显示ActionSheet
-(void)showActionSheet;

@end
