//
//  BBSUIAlertView.h
//  BBSSDKUI
//
//  Created by mob on 2018/4/17.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSUIAlertView : UIAlertView<UIAlertViewDelegate>
{
    void(^cancelBlk)(void);
    void(^sureBlk)(void);
}

- (BBSUIAlertView *)initWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
                sureButtonTitle:(NSString *)sureButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock
                      sureBlock:(void(^)(void))sureBlock;


// title cancel
- (BBSUIAlertView *)initWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock;
// title cancel sure
- (BBSUIAlertView *)initWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
                sureButtonTitle:(NSString *)sureButtonTitle
                    cancelBlock:(void(^)(void))cancelBlock
                      sureBlock:(void(^)(void))sureBlock;

// message cancel
- (BBSUIAlertView *)initWithMessage:(NSString *)message
                cancelButtonTitle:(NSString *)cancelButtonTitle
                      cancelBlock:(void(^)(void))cancelBlock;

// message cancel sure
- (BBSUIAlertView *)initWithMessage:(NSString *)message
                cancelButtonTitle:(NSString *)cancelButtonTitle
                  sureButtonTitle:(NSString *)sureButtonTitle
                      cancelBlock:(void(^)(void))cancelBlock
                        sureBlock:(void(^)(void))sureBlock;

@end
