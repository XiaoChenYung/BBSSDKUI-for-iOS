//
//  BBSUIProcessHUD.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSUIProcessHUD : NSObject

+ (void) showSuccessInfo:(NSString *)info;

+ (void) showFailInfo:(NSString *)info;

+ (void) showProcessHUDWithInfo:(NSString *)info;

@end
