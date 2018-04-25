
#import <UIKit/UIKit.h>

typedef struct{
    float r;
    float g;
    float b;
} BBSUIHRRGBColor;

/////////////////////////////////////////////////////////////////////////////
//
// 0.0f~1.0fの値をとるHSVの構造体です
//
/////////////////////////////////////////////////////////////////////////////

typedef struct{
    float h;
    float s;
    float v;
} BBSUIHRHSVColor;

// 値のチェックしてません。数値として入れさせるなら自前でチェックして下さい。

/////////////////////////////////////////////////////////////////////////////
//
// 変換用の関数
//
/////////////////////////////////////////////////////////////////////////////

void BBSUIHSVColorFromRGBColor(const BBSUIHRRGBColor*,BBSUIHRHSVColor*);
void RGBColorFromBBSUIHSVColor(const BBSUIHRHSVColor*,BBSUIHRRGBColor*);
void RGBColorFromUIColor(const UIColor*,BBSUIHRRGBColor*);

// 16進数のカラーコードを取得 (例:#ffffff)
// NSString* hexColorStr = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor([UIColor redColor])]; で文字列に変換されます
int HexColorFromRGBColor(const BBSUIHRRGBColor*);
int HexColorFromUIColor(const UIColor*);


// 同値チェック
bool BBSUIHRHSVColorEqualToColor(const BBSUIHRHSVColor*,const BBSUIHRHSVColor*);


// 0.0f~1.0fに納まるxとy、彩度の下限、輝度からHSVを求める
void BBSUIHSVColorAt(BBSUIHRHSVColor* hsv,float x,float y,float saturationLowerLimit,float brightness);

