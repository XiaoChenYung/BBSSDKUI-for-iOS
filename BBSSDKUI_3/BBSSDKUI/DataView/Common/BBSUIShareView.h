//
//  BBSUIShareView.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/29.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  分享视图
 */
@interface BBSUIShareView : UIView


@property (nonatomic, copy) NSString *shareUrl;

@property (nonatomic, strong) UIImage *share_img;

+ (instancetype)sharedInstance;

/**
 新建分享视图

 @param content 分享内容model
 @param animation 是否需要动画
 @param flag 标识,0论坛,1门户
 */
- (void)createShareViewWithContent:(id)content flag:(NSInteger)flag animation:(BOOL)animation;

/**
 *  展现分享视图
 */
- (void)show;

@end

#pragma mark - SSShareViewItem

/**
 *  分享类型枚举
 */
typedef NS_ENUM(NSInteger, BBSShareViewItemType){
    /**
     *  微信
     */
    BBSShareViewItemTypeWechatSession = 0,
    /**
     *  微信朋友圈
     */
    BBSShareViewItemTypeWechatTimeline =1,
    
    /**
     *  新浪微博
     */
    BBSShareViewItemTypeWechatSina,
    
    //    /**
    //     *  QQ空间
    //     */
    //    SSShareViewItemTypeWechatQQZone,
    //
    //    /**
    //     *  QQ
    //     */
    //    SSShareViewItemTypeWechatQQ,
    
    /**
     *  发短信
     */
    BBSShareViewItemTypeWechatSendMessage,
    
    /**
     *  复制链接
     */
    BBSShareViewItemTypeWechatCopyUrl,
    
    /**
     *  分享二维码
     */
    BBSShareViewItemTypeWechatShareTwoDimension,
};

/**
 *  分享视图单元
 */
@interface BBSShareViewItem : UIControl
- (void)configureViewWithObject:(id)obj;
@end
