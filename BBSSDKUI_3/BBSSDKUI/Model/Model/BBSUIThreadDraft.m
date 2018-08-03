//
//  BBSUIThreadDraft.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/5/3.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIThreadDraft.h"
#import "BBSForum+BBSUI.h"

static NSString * const kThread = @"com.bbs.threadcache";

@implementation BBSUIThreadDraft

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        NSString *title = [aDecoder decodeObjectForKey:@"title"];
        if ([title isKindOfClass:NSString.class])
        {
            self.title = title;
        }
        
        NSString *html = [aDecoder decodeObjectForKey:@"html"];
        if ([html isKindOfClass:NSString.class])
        {
            self.html = html;
        }
        
        BBSForum *forum = [aDecoder decodeObjectForKey:@"forum"];
        if ([forum isKindOfClass:BBSForum.class])
        {
            self.forum = forum;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (self.title)
    {
        [coder encodeObject:self.title forKey:@"title"];
    }
    
    if (self.html)
    {
        [coder encodeObject:self.html forKey:@"html"];
    }
    
    if (self.forum)
    {
        [coder encodeObject:self.forum forKey:@"forum"];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n title:%@,\n html:%@,\n forumName:%@\
            n forumID:%zd", _title,_html,_forum.name,_forum.fid];
}

- (void)save
{
    [[MOBFDataService sharedInstance] setCacheData:self forKey:kThread domain:@"BBSUI"];
}

+ (instancetype)savedDraft
{
    return [[MOBFDataService sharedInstance] cacheDataForKey:kThread domain:@"BBSUI"];
}

+ (void)deleteCachedDraft
{
    [[MOBFDataService sharedInstance] setCacheData:nil forKey:kThread domain:@"BBSUI"];
}

@end
