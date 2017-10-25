//
//  BBSUIThreadDraft.h
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/3.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSForum;

@interface BBSUIThreadDraft : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, strong) BBSForum *forum;

- (void)save;

+ (instancetype)savedDraft;

+ (void)deleteCachedDraft;

@end
