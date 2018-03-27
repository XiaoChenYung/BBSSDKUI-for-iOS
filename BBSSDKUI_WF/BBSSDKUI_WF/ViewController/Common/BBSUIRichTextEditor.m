//
//  BBSUIRichTextEditor.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/11.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIRichTextEditor.h"

@interface BBSUIRichTextEditor ()

@end

@implementation BBSUIRichTextEditor

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.enabledToolbarItems = @[
                                  ZSSRichTextEditorToolbarBold,
                                ZSSRichTextEditorToolbarItalic,
//                                  ZSSRichTextEditorToolbarStrikeThrough,
//                                  ZSSRichTextEditorToolbarUnorderedList,
//                                  ZSSRichTextEditorToolbarH1,
//                                  ZSSRichTextEditorToolbarH2,
//                                  ZSSRichTextEditorToolbarH3,
//                                  ZSSRichTextEditorToolbarH4
                                  ZSSRichTextEditorToolbarStrikeThrough,
                                  ZSSRichTextEditorToolbarUnorderedList
                                  ];
    
    self.toolbarItemTintColor = [UIColor darkGrayColor];
    
    self.alwaysShowToolbar = YES;
    
    self.shouldShowKeyboard = NO;
    
    self.placeholder = @"写点什么...";
        
    self.toolbarItemSelectedTintColor = [UIColor colorWithRed:77.0/255 green:162.0/255 blue:210.0/250 alpha:1];
}

@end
