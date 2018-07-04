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

#endif /* BBSUIMacro_h */
