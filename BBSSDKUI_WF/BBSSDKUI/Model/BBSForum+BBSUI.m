//
//  BBSForum+BBSUI.m
//  BBSSDKUI
//
//  Created by liyc on 2017/4/26.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSForum+BBSUI.h"
#import <objc/runtime.h>

static void * BBSUIStickPorpertyKey = (void *)@"BBSUIStickPorpertyKey";

@interface BBSForum (BBSUI)

@property (nonatomic, copy, readwrite) NSString *name;

@property (nonatomic, copy, readwrite) NSString *type;

@property (nonatomic, copy, readwrite) NSString *forumDescription;

@property (nonatomic, copy, readwrite) NSString *forumPic;

@property (nonatomic, assign, readwrite) NSInteger fid;

@property (nonatomic, assign, readwrite) NSInteger displayOrder;

@property (nonatomic, assign, readwrite) NSInteger allowPost;

@property (nonatomic, assign, readwrite) NSInteger allowReply;

@property (nonatomic, assign, readwrite) NSInteger status;

@property (nonatomic, assign, readwrite) NSInteger isSticked;

@end

@implementation BBSForum (BBSUI)

- (BOOL)isSticked
{
    return [objc_getAssociatedObject(self, BBSUIStickPorpertyKey) boolValue];
}

- (void)setIsSticked:(BOOL)isSticked
{
    objc_setAssociatedObject(self, BBSUIStickPorpertyKey, [NSNumber numberWithBool:isSticked], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.name) {
        [aCoder encodeObject:self.name forKey:@"name"];
    }
    
    if (self.type) {
        [aCoder encodeObject:self.type forKey:@"type"];
    }
    
    if (self.forumDescription) {
        [aCoder encodeObject:self.forumDescription forKey:@"description"];
    }
    
    if (self.forumPic) {
        [aCoder encodeObject:self.forumPic forKey:@"forumPic"];
    }
    
    if (self.fid)
    {
        [aCoder encodeInteger:self.fid forKey:@"fid"];
    }
    
    [aCoder encodeInteger:self.displayOrder forKey:@"displayOrder"];
    [aCoder encodeInteger:self.allowPost    forKey:@"allowPost"];
    [aCoder encodeInteger:self.allowReply   forKey:@"allowReply"];
    [aCoder encodeInteger:self.status       forKey:@"status"];
    [aCoder encodeBool:self.isSticked       forKey:@"isSticked"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        
        NSString *name = [aDecoder decodeObjectForKey:@"name"];
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        }

        NSString *type = [aDecoder decodeObjectForKey:@"type"];
        if ([type isKindOfClass:[NSString class]]) {
            self.type = type;
        }
        
        NSString *forumDescription = [aDecoder decodeObjectForKey:@"description"];
        if ([forumDescription isKindOfClass:[NSString class]]) {
            self.forumDescription = forumDescription;
        }
        
        NSString *forumPic = [aDecoder decodeObjectForKey:@"forumPic"];
        if ([forumPic isKindOfClass:[NSString class]]) {
            self.forumPic = forumPic;
        }

        self.displayOrder   = [aDecoder decodeIntegerForKey:@"displayOrder"];
        self.allowPost      = [aDecoder decodeIntegerForKey:@"allowPost"];
        self.allowReply     = [aDecoder decodeIntegerForKey:@"allowReply"];
        self.status         = [aDecoder decodeIntegerForKey:@"status"];
        self.isSticked      = [aDecoder decodeBoolForKey:@"isSticked"];
        self.fid            = [aDecoder decodeIntegerForKey:@"fid"];
    }
    
    return self;
}

@end
