//
//  NSString+BBSUIParagraph.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/28.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (BBSUIParagraph)

+ (NSMutableAttributedString *)bbs_stringWithString:(NSString *)string fontSize:(CGFloat)size defaultColorValue:(NSString *)defaultColorValue lineSpace:(CGFloat)lineSpace wordSpace:(CGFloat)wordSpace;


@end
