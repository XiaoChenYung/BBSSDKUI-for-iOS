//
//  BBSUICommentTextView.h
//
//
//  Created by liyc on 17/9/02.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZCountNumTextView.h"
#import "BBSUIImagePickerView.h"
#import "BBSUIExpressionView.h"

@interface BBSUICommentTextView : UIView
@property(nonatomic, strong) NSDictionary *addressLBS;
@property(nonatomic, copy) void (^openLBS)();
@property(nonatomic, copy) void (^showLBS)();

- (void)setSendHandler:(void (^)(NSArray <UIImage *>*images,NSString *content))handler;

@property (nonatomic,strong) QZCountNumTextView *countNumTextView;
@property (nonatomic ,strong) BBSUIImagePickerView *imagePickerView ;
@property (nonatomic, assign) BOOL isHideZixun;
@property (nonatomic,assign) BOOL isHiddenLBSMenu;
@property (nonatomic, strong) BBSUIExpressionView *expView;
@property (nonatomic, strong) UIView * bgView;

- (void)cleanData;

+ (instancetype)topTextView;

+ (instancetype)portalTextView;

@end
