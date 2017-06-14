//
//  BBSUICacheManager.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/24.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICacheManager.h"

#define CACHE_BASE_PATH(path) [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), path]

static const NSString *BBSUIStickForumsCacheName = @"StickForums";

@implementation BBSUICacheManager

@synthesize stickForums = _stickForums;

+ (BBSUICacheManager *)sharedInstance
{
    static BBSUICacheManager *sharedCache = nil;
    static dispatch_once_t sharedCachePredicate;
    dispatch_once(&sharedCachePredicate, ^{
        
        sharedCache = [[BBSUICacheManager alloc] init];
        
    });
    
    return sharedCache;
}

- (NSArray *)stickForums
{
    if (!_stickForums)
    {
        @try
        {
            _stickForums = [NSKeyedUnarchiver unarchiveObjectWithFile:CACHE_BASE_PATH(BBSUIStickForumsCacheName)];
        }
        @catch (NSException *exception)
        {
            
        }
    }
    
    return _stickForums;
}

- (void)setStickForums:(NSArray *)stickForums
{
    _stickForums = stickForums;
    
    //写入缓存
    NSString *path = CACHE_BASE_PATH(BBSUIStickForumsCacheName);
    if (_stickForums)
    {
        @try
        {
            [NSKeyedArchiver archiveRootObject:_stickForums
                                        toFile:path];
        }
        @catch (NSException *exception)
        {
            
        }
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
