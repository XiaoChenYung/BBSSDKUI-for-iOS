//
//  BBSUISystemInformationViewController.m
//  BBSSDKUI
//
//  Created by chuxiao on 2017/7/18.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUISystemInformationViewController.h"
#import <BBSSDK/BBSSDK.h>

@interface BBSUISystemInformationViewController ()

@property (nonatomic, strong) BBSUISystemInformationView *systemInformationView;

@end

@implementation BBSUISystemInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
//        
//    }];
    
    self.title = @"系统消息";
    
    _systemInformationView = [[BBSUISystemInformationView alloc] initWithFrame:self.view.bounds];
    _systemInformationView.context = self.context;
    [self.view addSubview:_systemInformationView];
    
    _systemInformationView.title = self.infoTitle;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


#import "Masonry.h"
#import "NSString+BBSUIParagraph.h"

@interface BBSUISystemInformationView ()

/**
 标题
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 正文
 */
@property (nonatomic, strong) UITextView *textView;

@end

@implementation BBSUISystemInformationView

- (instancetype)init{
    if (self = [super init]) {
        [self configUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI{
    
    /**
     标题
     */
    self.titleLabel =
    ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = DZSUIColorFromHex(0x2D3037);
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20);
            make.left.equalTo(@20);
            make.right.equalTo(@-15);
            make.height.equalTo(@14);
        }];
        
        label;
    });
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.075;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(18);
    }];

    
    /**
     正文
     */
    self.textView =
    ({
        UITextView *textView = [UITextView new];
        textView.editable = NO;
        [self addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line.mas_bottom).offset(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-13);
        }];
    
        textView;
    });
}

- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (void)setContext:(NSString *)context{
    self.textView.attributedText = [NSString bbs_stringWithString:context fontSize:14 defaultColorValue:@"6A7081" lineSpace:20 wordSpace:1.4];
}

/**
 设置行间距，字间距

 @param string 被设置字符串
 @param offset 行距
 @param wordSpace 字间距
 */
- (NSMutableAttributedString *)stringWithString:(NSString *)string lineSpace:(CGFloat)offset wordSpace:(CGFloat)wordSpace
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSKernAttributeName:@(wordSpace),NSForegroundColorAttributeName:DZSUIColorFromHex(0x6A7081),NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableParagraphStyle *paragrah = [[NSMutableParagraphStyle alloc] init];
    
    [paragrah setLineSpacing:offset];
    
    [str addAttribute:NSParagraphStyleAttributeName value:paragrah range:NSMakeRange(0, string.length)];
    
    return str;
}

@end






