//
//  BBSSDK.h
//  BBSSDK
//
//  Created by liyc on 2017/2/14.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MOBFoundation/MOBFoundation.h>
#import "BBSUser.h"
#import "BBSThread.h"
#import "BBSPost.h"

@interface BBSSDK : NSObject

/**
 获取版块列表
 
 @param fup 上级论坛id 预留字段，暂时不用
 @param result 回调
 */
+ (void)getForumListWithFup:(NSInteger)fup
                     result:(void (^)(NSArray *forumsList, NSError *error))result;

/**
 获取帖子列表

 @param fid 板块id
 @param pageIndex 页索引
 @param pageSize 每页请求大小
 @param result 回调
 */
+ (void)getThreadListWithFid:(NSInteger)fid
                   orderType:(NSString *)orderType
                  selectType:(NSString *)selectType
                   pageIndex:(NSInteger)pageIndex
                    pageSize:(NSInteger)pageSize
                      result:(void (^)(NSArray *threadList, NSError *error))result;

/**
 获取评论列表

 @param fid 板块id
 @param tid 帖子id
 @param pageIndex 页索引
 @param pageSize 页大小
 @param result 回调
 */
+ (void)getPostListWithFid:(NSInteger)fid
                       tid:(NSInteger)tid
                  authorId:(NSInteger)authorId
                 pageIndex:(NSInteger)pageIndex
                  pageSize:(NSInteger)pageSize
                    result:(void (^)(NSArray *postList, NSError *error))result;


/**
 上传图片
 
 @param imagePath 需要上传的图片路径
 @param result 回调
 */
+ (void)uploadImageWithContentPath:(NSString *)imagePath result:(void(^)(NSString *url, NSError *error))result;


/**
 发帖
 
 @param fid 帖子版块id
 @param subject 标题
 @param message 内容html
 @param token 用户登录凭证
 @param result 回调
 */
+ (void)postThreadWithFid:(NSInteger)fid
                  subject:(NSString *)subject
                  message:(NSString *)message
                    token:(NSString *)token
                   result:(void(^)(NSError *))result;

/**
 发评论
 
 @param fid 板块id
 @param tid 主贴id
 @param reppid 被回复的帖子id
 @param message 消息内容
 @param result 回调
 */
+ (void)postCommentWithFid:(NSInteger)fid
                       tid:(NSInteger)tid
                    reppid:(NSInteger)reppid
                   message:(NSString *)message
                     token:(NSString *)token
                    result:(void(^)(BBSPost *, NSError *))result;

/**
 获取贴子详情
 
 @param fid 板块id
 @param tid 主贴id
 @param result 回调
 */
+ (void)getThreadDetailWithFid:(NSInteger)fid
                           tid:(NSInteger)tid
                        result:(void(^)(BBSThread *,NSError *error))result;

/**
 注册接口
 
 @param userName 用户名
 @param email 邮箱
 @param password 密码
 @param result 回调
 */
+ (void)registUserWithUserName:(NSString *)userName
                         email:(NSString *)email
                      password:(NSString *)password
                        result:(void(^)(BBSUser * , NSError *error))result;

/**
 登录接口
 
 @param userName 用户名
 @param email 邮箱
 @param password 密码
 @param questionid 问题id
 @param answer 问题答案
 */
+ (void)loginWithUserName:(NSString *)userName
                    email:(NSString *)email
                 password:(NSString *)password
               questionid:(NSInteger)questionid
                   answer:(NSString *)answer
                   result:(void(^)(BBSUser * ,id res, NSError *error))result;

/**
 重置密码/忘记密码

 @param email 邮箱地址
 @param userName 用户名
 @param token token
 @param result 回调
 */
+ (void)resetPasswordWithEmail:(NSString *)email 
                      userName:(NSString *)userName 
                         token:(NSString *)token 
                        result:(void (^)(NSError *error))result;

/**
 重发认证邮件

 @param email 邮件地址
 @param userName 用户名
 @param result 回调
 */
+ (void)sendIdentyEmail:(NSString *)email
               userName:(NSString *)userName
                 result:(void (^)(NSError *))result;

/**
 修改用户信息

 @param gender 性别 0保密 1男 2女
 @param avatarBigUrl 用户头像url，大尺寸 200*200
 @param avatarMiddleUrl 用户头像url，中尺寸 120*120
 @param avatarSmallUrl 用户头像url，小尺寸 48*48
 @param result 回调
 */
+ (void)editUserInfoWithGender:(NSInteger)gender
                         token:(NSString *)token
                  avatarBigUrl:(NSString *)avatarBigUrl 
               avatarMiddleUrl:(NSString *)avatarMiddleUrl 
                avatarSmallUrl:(NSString *)avatarSmallUrl 
                        result:(void (^)(BBSUser *user, NSError *))result;

/**
 上传头像

 @param imagePath 头像沙盒路径
 @param result 回调
 */
+ (void)uploadAvatarWithContentPath:(NSString *)imagePath
                             scales:(NSArray *)scales
                             result:(void(^)(NSArray *urlsDic, NSError *error))result;

@end
