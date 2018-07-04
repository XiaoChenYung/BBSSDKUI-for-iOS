//
//  UIImage+BBSFunction.m
//  BBSSDKUI
//
//  Created by liyc on 2017/2/20.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "UIImage+BBSFunction.h"
#import "NSBundle+BBSSDKUI.h"

@implementation UIImage (BBSFunction)

+(UIImage *)BBSImageNamed:(NSString *)name
{
    if ([NSBundle bbsLoadBundle] == [NSBundle mainBundle]) {
        
        return [UIImage imageNamed:name];
    }
    
    NSRange range = [name rangeOfString:[NSString stringWithFormat:@".%@",[name pathExtension]]];
    if (range.location != NSNotFound)
    {
        NSString *fileName = [name substringToIndex:range.location];
        NSString *path = [[NSBundle bbsLoadBundle] pathForResource:fileName ofType:[name pathExtension]];
        return [UIImage imageWithContentsOfFile:path];
    }
    
    return nil;
}

@end
