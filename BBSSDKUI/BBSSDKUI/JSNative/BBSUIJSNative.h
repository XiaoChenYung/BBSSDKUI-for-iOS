//
//  BBSUIJSNative.h
//  BBSSDKUI
//
//  Created by liyc on 2017/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <MOBFoundation/MOBFoundation.h>
#import <BBSSDK/BBSThread.h>

@interface BBSUIJSNative : NSObject

- (instancetype)initWithJSContext:(JSContext *)context threadModel:(BBSThread *)model viewController:(id)viewController;

- (instancetype)initWithJSContext:(JSContext *)context urlsArray:(NSArray *)urlsArray index:(NSInteger)index viewController:(id)viewController;

- (void)saveImage;

@end
