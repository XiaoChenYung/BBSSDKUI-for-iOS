//
//  BBSCurrentViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/9/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSCurrentViewController.h"
#import "NSObject+SimpleKVONotification.h"

@interface BBSCurrentViewController ()

@property (nonatomic, strong, readwrite) NSMutableArray <__kindof UINavigationController *>*navigationControllers;

@end

@implementation BBSCurrentViewController

+ (instancetype)share
{
    static BBSCurrentViewController *currentVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentVC = [[BBSCurrentViewController alloc] init];
    });
    
    return currentVC;
}

- (void)setCurrentViewController:(__kindof UIViewController *)currentViewController
{
//    [collectionVC.collectionView.collectionTableView addObserverForKeyPath:NSStringFromSelector(@selector(contentOffset)) block:^(__weak id obj, id oldValue, id newValue) {
    

}

- (void)setCurrentNavigationController:(__kindof UINavigationController *)currentNavigationController
{
    
    NSLog(@"11111111111");
    
    if (! [self.navigationControllers containsObject:currentNavigationController])
    {
        [self.navigationControllers addObject:currentNavigationController];
        
        NSLog(@"222222222 %@",currentNavigationController);
        
        [currentNavigationController addObserverForKeyPath:@"viewControllers" block:^(__weak id obj, id oldValue, id newValue) {
           
            
            
            NSLog(@"mmmmmmmmmmmmmmmmm   %@",newValue);
            
            if ([newValue isKindOfClass:[UIViewController class]])
            {
                self.currentViewController = newValue;
                
                
            }
            
            
        }];
    }
}

- (NSMutableArray *)navigationControllers
{
    if (!_navigationControllers)
    {
        _navigationControllers = [NSMutableArray array];
    }
    
    return _navigationControllers;
}


@end
