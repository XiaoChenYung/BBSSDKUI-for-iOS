//
//  BBSUICoreDataManage.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/8/8.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUICoreDataManage.h"
#import "BBSUIStore.h"
#import <BBSSDK/BBSThread.h>
#import "BBSUIContext.h"

@interface BBSUICoreDataManage ()

@property (nonatomic, strong) BBSUIStore *store;

@property (nonatomic, strong) NSString *entityName;

@property (nonatomic, assign) long lastHistoryTime;

@end

@implementation BBSUICoreDataManage

+ (instancetype) shareManager {
    static BBSUICoreDataManage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BBSUICoreDataManage alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _lastHistoryTime = -1;
    }
    
    return self;
}

- (BBSUIStore *)store{
    if (!_store) {
        _store = [[BBSUIStore alloc] init];
    }
    return _store;
}

- (NSString *)entityName {
    return @"History";
}

- (void)addHistoryWithThread:(BBSThread *)thread
{
    if (! [BBSUIContext shareInstance].currentUser) {
        return;
    }
    
    NSInteger uid = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    
//    if ([self queryHistoryWithTid:thread.tid needTransform:NO].count > 0) {
//        return;
//    }
    
    [self deleteHistoryWithTid:thread.tid];
    
    History *threadHistory = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.store.managedObjectContext];
    
    threadHistory.tid           = @(thread.tid);
    threadHistory.fid           = @(thread.fid);
    threadHistory.forumName     = thread.forumName;
    threadHistory.subject       = thread.subject;
    threadHistory.deviceName    = thread.deviceName;
    threadHistory.heatLevel     = @(thread.heatLevel);
    threadHistory.displayOrder  = @(thread.displayOrder);
    threadHistory.digest        = @(thread.digest);
    threadHistory.highLight     = @(thread.highLight);
    threadHistory.summary       = thread.summary;
    threadHistory.images        = thread.images;
    threadHistory.attachments   = thread.attachments;
    threadHistory.message       = thread.message;
    threadHistory.author        = thread.author;
    threadHistory.authorId      = @(thread.authorId);
    threadHistory.createdOn     = @(thread.createdOn);
    threadHistory.lastPost      = @(thread.lastPost);
    threadHistory.avatar        = thread.avatar;
    threadHistory.replies       = @(thread.replies);
    threadHistory.views         = @(thread.views);
    threadHistory.username      = thread.username;
    threadHistory.uid           = @(uid);
    
    long historyTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"____________%zu",historyTime);
    threadHistory.historyTime   = @(historyTime);
    
    if ([self.store.managedObjectContext save:nil]) {
        NSLog(@"添加历史记录成功");
    }
    else{
        NSLog(@"添加历史记录失败");
    }
}

- (NSArray *)queryHistoryWithTid:(NSInteger)tid needTransform:(BOOL)transform
{
    NSInteger uid = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tid == %lu && uid == %lu",tid,uid];
    NSArray *array = [self queryHistoryWithPredicate:predicate limit:10 needTransform:transform];
    
    return array;
}


/**
 查询一定条数结果集

 @param limit 条数
 @return 结果集
 */
- (NSArray *)queryHistoryWithTid:(NSInteger)tid limit:(NSInteger)limit {
    if (tid == -1)
    {
        _lastHistoryTime = -1;
    }
    
    NSInteger uid = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    
    NSArray *array;
    if (_lastHistoryTime < 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %lu",uid];
        array = [self queryHistoryWithPredicate:predicate limit:limit needTransform:YES];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"historyTime < %lu && uid == %lu",_lastHistoryTime,uid];
        array = [self queryHistoryWithPredicate:predicate limit:limit needTransform:YES];
    }
    
    return array;
}


/**
 查询数据

 @param predicate 条件
 @param limit 条数
 @param transform 是否需要转换数据 YES:需要,转成BBSThread类型 NO:不需要，得到查询结果源数据
 @return 查询结果集
 */
- (NSArray *)queryHistoryWithPredicate:(NSPredicate *)predicate limit:(NSInteger)limit needTransform:(BOOL)transform{
    // 1. 实例化一个查询(Fetch)请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 2.设置要查询的实体
    request.entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.store.managedObjectContext];
    // 3. 条件查询，通过谓词来实现的
    if (predicate)
        request.predicate = predicate;
    // 排序 ascendingYes为递增排序，ascending为No递减排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"historyTime" ascending:NO];
    request.sortDescriptors=@[sort];
    // 限定查询结果的数量(每页的数量)
    [request setFetchLimit:limit];
    
    //查询的偏移量(查询多少条以后的数据 一般是： 页数 * 每页的数据量)
    
    //    [request setFetchOffset:1];
    
    // 2. 让_context执行查询数据
    NSArray <History *>*array = [self.store.managedObjectContext executeFetchRequest:request error:nil];
    
    if (transform)
    {
        _lastHistoryTime = [array.lastObject.historyTime integerValue];
        
        NSLog(@"____________ss %zu",_lastHistoryTime);
        
        return [self arrayWithHistoryArray:array];
    }
    return array;
}

- (NSArray *)arrayWithHistoryArray:(NSArray *)historyArray {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (History *thread in historyArray) {
        // 在CoreData中，查询是懒加载的
        // 在CoreData本身的SQL查询中，是不使用JOIN的，不需要外键
        // 这种方式的优点是：内存占用相对较小，但是磁盘读写的频率会较高
        BBSThread *threadHistory = [BBSThread new];
        threadHistory.tid           = [thread.tid integerValue];
        threadHistory.fid           = [thread.fid integerValue];
        threadHistory.forumName     = thread.forumName;
        threadHistory.subject       = thread.subject;
        threadHistory.deviceName    = thread.deviceName;
        threadHistory.heatLevel     = [thread.heatLevel integerValue];
        threadHistory.displayOrder  = [thread.displayOrder integerValue];
        threadHistory.digest        = [thread.digest integerValue];
        threadHistory.highLight     = [thread.highLight integerValue];
        threadHistory.summary       = thread.summary;
        threadHistory.images        = thread.images;
        threadHistory.attachments   = thread.attachments;
        threadHistory.message       = thread.message;
        threadHistory.author        = thread.author;
        threadHistory.authorId      = [thread.authorId integerValue];
        threadHistory.createdOn     = [thread.createdOn integerValue];
        threadHistory.lastPost      = [thread.lastPost integerValue];
        threadHistory.avatar        = thread.avatar;
        threadHistory.replies       = [thread.replies integerValue];
        threadHistory.views         = [thread.views integerValue];
        threadHistory.username      = thread.username;
        
        [resultArray addObject:threadHistory];
    }
    
    return resultArray;
}

- (void)deleteHistoryWithTid:(NSInteger)tid {
 
    NSArray *arrHistory = [self queryHistoryWithTid:tid needTransform:NO];
    if (arrHistory != nil && arrHistory.count > 0) {
        [self.store.managedObjectContext deleteObject:arrHistory.firstObject];
        [self.store saveContext];
        NSLog(@"Delete successfully");
    }else{
        NSLog(@"This does not exist before,can not delete");
    }
}

- (NSInteger)historyCount {
    NSInteger uid = [[BBSUIContext shareInstance].currentUser.uid integerValue];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.store.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"uid == %lu",uid];
    return [self.store.managedObjectContext countForFetchRequest:request error:nil];
}

@end
