//
//  NSString+MAXCommon.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/6.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (BBSUIRegular)

- (BOOL)bbs_isEmpty ;

- (BOOL)bbs_isPhoneNumber ;

- (BOOL)bbs_isEmail ;

- (BOOL)bbs_isPassword ;

- (BOOL)bbs_isUserName ;

+ (NSString *)bbs_localTimeStringWithDate:(NSDate *)date ;

/**
 获取文字长度

 @return 字数
 */
- (NSInteger)bbs_charNumber ;

- (BOOL)bbs_isObjectID ;
@end
