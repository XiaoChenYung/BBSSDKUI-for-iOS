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
                                  BBSUIRichTextEditorToolbarBold,
                                BBSUIRichTextEditorToolbarItalic,
//                                  BBSUIRichTextEditorToolbarStrikeThrough,
//                                  BBSUIRichTextEditorToolbarUnorderedList,
//                                  BBSUIRichTextEditorToolbarH1,
//                                  BBSUIRichTextEditorToolbarH2,
//                                  BBSUIRichTextEditorToolbarH3,
//                                  BBSUIRichTextEditorToolbarH4
                                  BBSUIRichTextEditorToolbarStrikeThrough,
                                  BBSUIRichTextEditorToolbarUnorderedList
                                  ];
    
    self.toolbarItemTintColor = [UIColor darkGrayColor];
    
    self.alwaysShowToolbar = YES;
    
    self.shouldShowKeyboard = NO;
    
    self.placeholder = @"写点什么...";
        
    self.toolbarItemSelectedTintColor = [UIColor colorWithRed:77.0/255 green:162.0/255 blue:210.0/250 alpha:1];
}

@end
