//
//  IMOBFLinkComponent.h
//  MOBFoundation
//
//  Created by Sands_Lee on 2017/4/25.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MOBFoundation/IMOBFServiceComponent.h>

@protocol IMOBFScene;
@protocol IMOBFLinkController;

/**
 MobLink产品组件
 */
@protocol IMOBFLinkComponent <IMOBFServiceComponent>

/**
 获取mobId

 @param scene 当前场景信息
 @param result 回调处理，返回mobId
 */
+ (void)getMobId:(id<IMOBFScene>)scene result:(void (^)(NSString *mobId))result;

/**
 设置委托

 @param delegate 委托对象
 */
+ (void)setDelegate:(id)delegate;

@end

/**
 MobLink控制器
 */
@protocol IMOBFLinkController

@required

/**
 设定控制器路径
 
 @return 控制器路径
 */
+ (NSString *)MLSDKPath;

/**
 控制器初始化
 
 @param scene 场景参数
 @return 控制器对象
 */
- (instancetype)initWithMobLinkScene:(id<IMOBFScene>)scene;

@end

/**
 MobLink场景对象
 */
@protocol IMOBFScene

@required

/**
 场景信息初始化
 
 @param path 路径,应传入需要恢复的控制器所设定的路径,即控制器在实现UIViewController+MLSDKRestore里面的+[MLSDKPath]时所返回的值。
 @param source 来源标识
 @param params 自定义参数,可传入自定义键值对
 @return 场景对象
 */
- (instancetype)initWithMLSDKPath:(NSString *)path source:(NSString *)source params:(NSDictionary *)params;

/**
 获取路径

 @return 路径
 */
- (NSString *)getPath;

/**
 获取来源

 @return 来源
 */
- (NSString *)getSource;

/**
 获取自定义参数

 @return 自定义参数
 */
- (NSDictionary *)getParams;

/**
 获取mobid

 @return MobId
 */
- (NSString *)getMobId;

@end

