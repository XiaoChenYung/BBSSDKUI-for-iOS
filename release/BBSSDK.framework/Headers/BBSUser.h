//
//  BBSUser.h
//  BBSSDK
//
//  Created by youzu_Max on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSUser : NSObject<NSCoding>

/**
 登录凭证
 */
@property (nonatomic, copy) NSString *token;

/**
 会员id
 */
@property (nonatomic, strong) NSNumber *uid;

/**
 会员昵称
 */
@property (nonatomic, copy) NSString *nickName;

/**
 邮箱
 */
@property (nonatomic, copy) NSString *email;

/**
 用户名
 */
@property (nonatomic, copy) NSString *userName;

/**
 性别
 */
@property (nonatomic, strong) NSNumber *gender;

/**
 email是否经过验证
 */
@property (nonatomic, strong) NSNumber *emailStatus;

/**
 是否有头像
 */
@property (nonatomic, strong) NSNumber *avatarStatus;

/**
 注册时间
 */
@property (nonatomic, strong) NSNumber *regDate;

/**
 用户组id
 */
@property (nonatomic, strong) NSNumber *groupId;

/**
 用户头像url
 */
@property (nonatomic, copy) NSString *avatar;

/**
 用户组名
 */
@property (nonatomic, copy) NSString *groupName;

/**
 阅读权限
 */
@property (nonatomic, strong) NSNumber *readAccess;

/**
 允许发帖
 */
@property (nonatomic, strong) NSNumber *allowPost;

/**
 允许回复
 */
@property (nonatomic, strong) NSNumber *allowReply;

/**
 根据res字典初始化属性
 */
- (void) setValueForPropertiesWithDictionary:(NSDictionary *)res;

@end
