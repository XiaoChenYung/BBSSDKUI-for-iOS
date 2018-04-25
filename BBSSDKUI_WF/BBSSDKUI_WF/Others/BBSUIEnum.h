//
//  BBSUIEnum.h
//  BBSSDKUI_WF
//
//  Created by chuxiao on 2018/1/19.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBSUIThreadSelectType)
{
    BBSUIThreadSelectTypeLatest = 0,        //最新
    BBSUIThreadSelectTypeHeats = 1,         //热门
    BBSUIThreadSelectTypeDigest = 2,        //精华
    BBSUIThreadSelectTypeDisplayOrder = 3   //置顶
};

typedef NS_ENUM(NSInteger, BBSUIThreadOrderType)
{
    BBSUIThreadOrderCommentTime = 0,    //最后回复时间排序
    
    BBSUIThreadOrderPostTime = 1        //发布时间排序
};

typedef NS_ENUM(NSInteger, PageType) {
    PageTypeHomePage    = 0,
    PageTypeForumToHome = 1,    // 从forum过来的homePage
    PageTypeSearch      = 2,
    PageTypeHistory     = 3,
    PageTypePortal      = 4,     // 资讯
    PageTypeAttion      = 5      //关注动态
};

typedef NS_ENUM(NSInteger, BBSUIThreadListViewType){
    BBSUIThreadListViewTypeThread   = 0,
    BBSUIThreadListViewTypePortal   = 1
};




