//
//  BBSUIOrderSegmentView.h
//  BBSSDKUI
//
//  Created by liyc on 2017/9/9.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIBaseView.h"

@protocol BBSUIOrderSegmentDelegate <NSObject>

- (void)clickHandler:(NSInteger)index;

@end

@interface BBSUIOrderSegmentView : BBSUIBaseView
{
    
    UIButton *_seletedBtn;
    UIButton *lastBtn;
    NSInteger index ;
    //按钮总宽度
    CGFloat   titleWidth;
    
}

@property (nonatomic, weak) id <BBSUIOrderSegmentDelegate> delegate;

//@property (nonatomic,retain) UIScrollView          *pageScroll;
//@property (nonatomic,retain) NSArray               *viewControllers;
@property (nonatomic,retain) UIView                *lineView;
@property (nonatomic,retain) UIView                *btnView;
@property (nonatomic,retain) NSArray               *titleArray;
//设置按钮字体大小
@property (nonatomic,assign) NSInteger             btnFont;

//设置菜单栏高度
@property (nonatomic,assign) NSInteger             btnViewHeight;

//设置按钮下划线高度
@property (nonatomic,assign) NSInteger             btnLineHeight;

@end
