//
//  BBSUIPostTip.m
//  BBSSDKUI_WF
//
//  Created by xiaochen yang on 2019/2/12.
//  Copyright © 2019 MOB. All rights reserved.
//

#import "BBSUIPostTip.h"

@interface BBSUIPostTip ()

@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIView *infoContent;

@end

@implementation BBSUIPostTip

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.infoContent.layer.cornerRadius = 3;
    self.clipsToBounds = true;
    [self.selectedButton setImage:[UIImage BBSImageNamed:@"RichEditor/icon_selected_nor@2x.png"] forState:UIControlStateNormal];
    [self.selectedButton setImage:[UIImage BBSImageNamed:@"RichEditor/icon_selected_pre@2x.png"] forState:UIControlStateSelected];
}

- (IBAction)confirm:(UIButton *)sender {
    if (self.selectedButton.isSelected) {
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"postTip"];
    }
    [self removeFromSuperview];
}

- (IBAction)selected:(UIButton *)sender {
    self.selectedButton.selected = !self.selectedButton.isSelected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
