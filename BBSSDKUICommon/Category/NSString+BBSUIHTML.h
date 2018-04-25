//
//  NSString+BBSUIHTML.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/14.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BBSUIHTML)

/**
 *  富文本转html字符串
 */
+ (NSString *)bbs_attriToStrWithAttri:(NSAttributedString *)attri;

/**
 *  html转富文本(转之后的富文本，再通过调用sting属性，可以拿到最终的字符串)
 */
+ (NSAttributedString *)bbs_strToAttriWithHtmlStr:(NSString *)htmlStr;


@end
