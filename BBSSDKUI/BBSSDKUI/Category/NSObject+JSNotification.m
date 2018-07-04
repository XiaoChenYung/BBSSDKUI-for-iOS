//
//  NSObject+JSNotification.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "NSObject+JSNotification.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation NSObject (JSNotification)

- (void)webView:(id)unuse didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    [[NSNotificationCenter defaultCenter] postNotificationName:DZSDidCreateContextNotification object:ctx];
}

@end
