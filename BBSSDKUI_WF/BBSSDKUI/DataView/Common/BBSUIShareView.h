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


@property (nonatomic, copy)  NSString          *shareUrl;

@property (nonatomic, strong)UIImage       *share_img;

+ (instancetype)sharedInstance;

- (instancetype)init:(id)content;

/**
 *  展现分享视图
 */
- (void)show;

@end

#pragma mark - SSShareViewItem

/**
 *  分享类型枚举
 */
typedef NS_ENUM(NSInteger, SSShareViewItemType){
    /**
     *  微信
     */
    SSShareViewItemTypeWechatSession = 0,
    /**
     *  微信朋友圈
     */
    SSShareViewItemTypeWechatTimeline =1,
    
    /**
     *  新浪微博
     */
    SSShareViewItemTypeWechatSina,
    
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
    SSShareViewItemTypeWechatSendMessage,
    
    /**
     *  复制链接
     */
    SSShareViewItemTypeWechatCopyUrl,
    
    /**
     *  分享二维码
     */
    SSShareViewItemTypeWechatShareTwoDimension,
};

/**
 *  分享视图单元
 */
@interface SSShareViewItem : UIControl
- (void)configureViewWithObject:(id)obj;
@end
