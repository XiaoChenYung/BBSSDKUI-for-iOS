//
//  UIDevice+Model.h
//  CloutropySDK
//
//  Created by xiaochen yang on 2018/10/25.
//  Copyright © 2018 chainedbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Model)

- (NSString *)innner_modelName;

- (BOOL)inner_isIphoneXOrLater;

@end

NS_ASSUME_NONNULL_END
