//
//  BBSUIMacro.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/16.
//  Copyright © 2017年 MOB. All rights reserved.
//

#ifndef BBSUIMacro_h
#define BBSUIMacro_h

#define NavigationBar_Height 64

#define DZSUIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#define DZSUI_MainColor 0x88BE66

#define DZSUIScreen_width [UIScreen mainScreen].bounds.size.width
#define DZSUIScreen_height [UIScreen mainScreen].bounds.size.height

//notification
#define DZSDidCreateContextNotification @"DZSDidCreateContextNotification"

#define BBSUIAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#define BBSUILog(s, ...) NSLog(@"\n\n---------------------------------------------------\n %s[line:%d] \n %@ \n---------------------------------------------------\n", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#import "NSBundle+BBSSDKUI.h"
#import "UIImage+BBSFunction.h"
#import <MOBFoundation/MOBFoundation.h>
#import "SVProgressHUD.h"

#endif /* BBSUIMacro_h */
