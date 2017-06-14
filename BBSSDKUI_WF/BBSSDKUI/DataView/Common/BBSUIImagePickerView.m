//
//  BBSUIImagePickerView.m
//  BBSSDKUI
//
//  Created by youzu_Max on 2017/4/7.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import "BBSUIImagePickerView.h"
#import "Masonry.h"
#import "BBSUIImageView.h"
#import "BBSUIMacro.h"
@interface BBSUIImagePickerView()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,iBBSUIImageViewDelegate>

//@property(nonatomic, strong) UIButton *imagePickBtn;

@property(nonatomic, strong) UIScrollView *imagesView ;

@property(nonatomic, strong) UIButton *addBtn;

@end

@implementation BBSUIImagePickerView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    self.imagesView =
    ({
        UIScrollView *imagesView = [[UIScrollView alloc] init];
        imagesView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [self addSubview:imagesView];
        [imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        imagesView ;
    });
    
    self.addBtn =
    ({
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setImage:[UIImage BBSImageNamed:@"/Common/addImage.png"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(pickImages) forControlEvents:UIControlEventTouchUpInside];
        [_imagesView addSubview:addBtn];
        [self resetAutolayoutAnimation:NO];
        addBtn ;
    }); 
}

#pragma mark - Click Events

- (void)pickImages
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(didBeginPickImages)])
    {
        [_delegate didBeginPickImages];
    }
    
    if([self selectedImages].count>=8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"最多只能上传8张图片哦..." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (_delegate && [_delegate respondsToSelector:@selector(didEndPickImages)])
            {
                [_delegate didEndPickImages];
            }
        }];
        
        [alert addAction:ok];
        
        [(UIViewController *)self.delegate presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction * pickImg = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImgInAlbum];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (_delegate && [_delegate respondsToSelector:@selector(didEndPickImages)])
        {
            [_delegate didEndPickImages];
        }
    }];
    [alertVC addAction:takePhoto];
    [alertVC addAction:pickImg];
    [alertVC addAction:cancel];
    
    [(UIViewController *)self.delegate presentViewController:alertVC animated:YES completion:nil];
}
     
- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
//        [SVProgressHUD showInfoWithStatus:@"相机不可用.=_="];
        BBSUIAlert(@"相机不可用,到设置启用相机权限才能使用哦");
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypeCamera;
//    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self ;
    [(UIViewController *)self.delegate presentViewController:cameraVc animated:YES completion:nil];

}

- (void)pickImgInAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
//        [SVProgressHUD showInfoWithStatus:@"图库不可用.=_="];
        BBSUIAlert(@"相册不可用,到设置启用相册权限才能使用哦");
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self ;
    [(UIViewController *)self.delegate presentViewController:cameraVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *editedImg = info[UIImagePickerControllerOriginalImage];
    
    BBSUIImageView *view = [BBSUIImageView viewWithImage:editedImg];
    view.delegate = self ;
    [_imagesView insertSubview:view belowSubview:_addBtn];
    [self resetAutolayoutAnimation:NO];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if (_delegate && [_delegate respondsToSelector:@selector(didEndPickImages)])
        {
            [_delegate didEndPickImages];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(didEndPickImages)])
        {
            [_delegate didEndPickImages];
        }
    }];
}

- (void)resetAutolayoutAnimation:(BOOL)animation
{
    NSArray * subViews = _imagesView.subviews;
    
    for (NSInteger i=0; i<subViews.count; i++)
    {
        // contentSize 改变时会多出几个UIimageView.不知为什么。
        BOOL typeCheck = ([subViews[i] isKindOfClass:[UIButton class]])||([subViews[i] isKindOfClass:[BBSUIImageView class]]);
        if (!typeCheck)
        {
            [subViews[i] removeFromSuperview];
            continue ;
        }
        
        [subViews[i] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(i%4*(10+81.0)+10);
            make.top.mas_offset(i/4*(10+81.0)+10);
            make.height.width.equalTo(@81);
        }];
    }
    
    CGFloat height = (subViews.count/4 + (subViews.count%4?1:0))*(10+81.0)+10 ;
    
    _imagesView.contentSize = CGSizeMake(375, height);
    
    if (animation)
    {
        [UIView animateWithDuration:0.33 animations:^{
            [_imagesView layoutIfNeeded];
        }];
    }
    else
    {
        [_imagesView layoutIfNeeded];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didResetAutolayout)])
    {
        [_delegate didResetAutolayout];
    }
}

// 返回图片数组
- (NSMutableArray <UIImage*>*)selectedImages
{
    NSMutableArray *images = [NSMutableArray array];
    
    for (NSInteger i=0; i<_imagesView.subviews.count-1; i++)
    {
        BBSUIImageView *view = _imagesView.subviews[i];
        
        if ([view isKindOfClass:BBSUIImageView.class])
        {
            [images addObject:view.image];
        }
    }
    
    return images ;
}

#pragma mark - iBBSUIImageViewDelegate 

- (void)didDeleted:(BBSUIImageView *)view
{
    [self resetAutolayoutAnimation:YES];
}


@end
