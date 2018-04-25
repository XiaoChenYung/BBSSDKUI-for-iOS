
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/time.h>
#import "BBSUIHRColorUtil.h"
#import "BBSUIHRColorPickerMacros.h"

@class BBSUIHRColorPickerView;

@protocol BBSUIHRColorPickerViewDelegate
- (void)colorWasChanged:(BBSUIHRColorPickerView*)color_picker_view;
@end

typedef struct timeval timeval;

struct BBSUIHRColorPickerStyle{
    float width; // viewの横幅。デフォルトは320.0f;
    float headerHeight; // 明度スライダーを含むヘッダ部分の高さ(デフォルトは106.0f。70.0fくらいが下限になると思います)
    float colorMapTileSize; // カラーマップの中のタイルのサイズ。デフォルトは15.0f;
    int colorMapSizeWidth; // カラーマップの中にいくつのタイルが並ぶか (not view.width)。デフォルトは20;
    int colorMapSizeHeight; // 同じく縦にいくつ並ぶか。デフォルトは20;
    float brightnessLowerLimit; // 明度の下限
    float saturationUpperLimit; // 彩度の上限
};

typedef struct BBSUIHRColorPickerStyle BBSUIHRColorPickerStyle;

@class BBSUIHRBrightnessCursor;
@class BBSUIHRColorCursor;

@interface BBSUIHRColorPickerView : UIControl{
    NSObject<BBSUIHRColorPickerViewDelegate>* __weak delegate;
 @private
    bool _animating;
    
    // 入力関係
    bool _isTapStart;
    bool _isTapped;
	bool _wasDragStart;
    bool _isDragStart;
	bool _isDragging;
	bool _isDragEnd;
    
	CGPoint _activeTouchPosition;
	CGPoint _touchStartPosition;
    
    // 色情報
    BBSUIHRRGBColor _defaultRgbColor;
    BBSUIHRHSVColor _currentHsvColor;
    
    // カラーマップ上のカーソルの位置
    CGPoint _colorCursorPosition;
    
    // パーツの配置
    CGRect _currentColorFrame;
    CGRect _brightnessPickerFrame;
    CGRect _brightnessPickerTouchFrame;
    CGRect _brightnessPickerShadowFrame;
    CGRect _colorMapFrame;
    CGRect _colorMapSideFrame;
    float _tileSize;
    float _brightnessLowerLimit;
    float _saturationUpperLimit;
    
    BBSUIHRBrightnessCursor* _brightnessCursor;
    BBSUIHRColorCursor* _colorCursor;
    
    // キャッシュ
    CGImageRef _brightnessPickerShadowImage;
    
    // フレームレート
    timeval _lastDrawTime;
    timeval _timeInterval15fps;
    
    bool _delegateHasSELColorWasChanged;
}

// スタイルを取得
+ (BBSUIHRColorPickerStyle)defaultStyle;
+ (BBSUIHRColorPickerStyle)fullColorStyle;

+ (BBSUIHRColorPickerStyle)fitScreenStyle; // iPhone5以降の縦長スクリーンに対応しています。
+ (BBSUIHRColorPickerStyle)fitScreenFullColorStyle;

// スタイルからviewのサイズを取得
+ (CGSize)sizeWithStyle:(BBSUIHRColorPickerStyle)style;

// スタイルを指定してデフォルトカラーで初期化
- (id)initWithStyle:(BBSUIHRColorPickerStyle)style defaultColor:(const BBSUIHRRGBColor)defaultColor;

// デフォルトカラーで初期化 (互換性のために残していますが、frameが反映されません)
- (id)initWithFrame:(CGRect)frame defaultColor:(const BBSUIHRRGBColor)defaultColor;

// 現在選択している色をRGBで返す
- (BBSUIHRRGBColor)RGBColor;

// 後方互換性のため。呼び出す必要はありません。
- (void)BeforeDealloc; 

@property (getter = BrightnessLowerLimit, setter = setBrightnessLowerLimit:) float BrightnessLowerLimit;
@property (getter = SaturationUpperLimit, setter = setSaturationUpperLimit:) float SaturationUpperLimit;
@property (nonatomic, weak) NSObject<BBSUIHRColorPickerViewDelegate>* delegate;

@end
