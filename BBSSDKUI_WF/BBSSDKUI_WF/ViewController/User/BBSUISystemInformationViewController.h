//
//  BBSUISystemInformationViewController.h
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBackViewController.h"
#import "BBSUIBaseView.h"

@interface BBSUISystemInformationViewController : BBSUIBackViewController

@property (nonatomic, copy) NSString *context;

@property (nonatomic, copy) NSString *infoTitle;

@end

@interface BBSUISystemInformationView : BBSUIBaseView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *context;

@end
