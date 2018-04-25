//
//  BBSUIAlertView.m
//  BBSSDKUI
//
//  Created by mob on 2018/4/17.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUIAlertView.h"

@implementation BBSUIAlertView

- (BBSUIAlertView *)initWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
                sureButtonTitle:(NSString *)sureButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock
                      sureBlock:(void(^)(void))sureBlock
{
    self = [super initWithTitle:title
                        message:message
                       delegate:self
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:sureButtonTitle, nil];
    
    self.delegate = self;
    
    cancelBlk = cancelBlock;
    sureBlk = sureBlock;
    
    return self;
}

// title cancel
- (BBSUIAlertView *)initWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock
{
    return [self initWithTitle:title
                       message:nil
             cancelButtonTitle:cancelButtonTitle
               sureButtonTitle:nil
                   cancelBlock:cancelBlock
                     sureBlock:nil];
}

// title cancel sure
- (BBSUIAlertView *)initWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
                sureButtonTitle:(NSString *)sureButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock
                      sureBlock:(void(^)(void))sureBlock
{
    return [self initWithTitle:title
                       message:nil
             cancelButtonTitle:cancelButtonTitle
               sureButtonTitle:nil
                   cancelBlock:cancelBlock
                     sureBlock:nil];
}

// message cancel
- (BBSUIAlertView *)initWithMessage:(NSString *)message
                cancelButtonTitle:(NSString *)cancelButtonTitle
                      cancelBlock:(void(^)(void))cancelBlock
{
    return [self initWithTitle:nil
                       message:message
             cancelButtonTitle:cancelButtonTitle
               sureButtonTitle:nil
                   cancelBlock:cancelBlock
                     sureBlock:nil];
}

// message cancel sure
- (BBSUIAlertView *)initWithMessage:(NSString *)message
                cancelButtonTitle:(NSString *)cancelButtonTitle
                  sureButtonTitle:(NSString *)sureButtonTitle
                      cancelBlock:(void(^)(void))cancelBlock
                        sureBlock:(void(^)(void))sureBlock
{
    return [self initWithTitle:nil
                       message:message
             cancelButtonTitle:cancelButtonTitle
               sureButtonTitle:sureButtonTitle
                   cancelBlock:cancelBlock
                     sureBlock:sureBlock];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        if (cancelBlk)  cancelBlk();
    }else{
        if (sureBlk) sureBlk();
    }
}

@end
