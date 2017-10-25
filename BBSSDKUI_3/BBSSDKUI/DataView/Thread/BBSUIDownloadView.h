//
//  BBSUIDownloadView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/3/5.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSUIDownloadView : UIView

@property (nonatomic, strong) NSDictionary *attachment;

- (void)setFinishResult:(void (^) (NSString *fileURL, BOOL canOpen, BOOL isTxt))result openInOther:(void (^)())openInOhter;

@end
