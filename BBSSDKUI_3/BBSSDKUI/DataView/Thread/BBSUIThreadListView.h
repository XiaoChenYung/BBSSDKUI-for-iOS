//
//  BBSUIThreadListView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/4/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"
#import <BBSSDK/BBSForum.h>
#import "NSString+ThreadOrderType.h"


@interface BBSUIThreadListView : BBSUIBaseView

@property (nonatomic, assign) NSInteger currentSelectType;

@property (nonatomic, assign) NSInteger currentOrderType;

- (instancetype)initWithFrame:(CGRect)frame forum:(BBSForum *)forum;

- (void)dismissRefreshWindow;

- (void)requestDataWithOrderType:(BBSUIThreadOrderType)orderType;

@end


