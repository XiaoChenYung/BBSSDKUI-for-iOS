
#import "BBSUIHRColorCursor.h"
#import "BBSUIHRCgUtil.h"

@implementation BBSUIHRColorCursor

+ (CGSize) cursorSize 
{
    return CGSizeMake(30.0, 30.0f);
}

+ (float) outlineSize
{
    return 4.0f;
}

+ (float) shadowSize
{
    return 2.0f;
}


- (id)initWithPoint:(CGPoint)point
{
    CGSize size = [BBSUIHRColorCursor cursorSize];
    CGRect frame = CGRectMake(point.x, point.y, size.width, size.height);
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:FALSE];
        _currentColor.r = _currentColor.g = _currentColor.b = 1.0f;
    }
    return self;
}

- (void)setColorRed:(float)red andGreen:(float)green andBlue:(float)blue{
    _currentColor.r = red;
    _currentColor.g = green;
    _currentColor.b = blue;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    float outlineSize = [BBSUIHRColorCursor outlineSize];
    CGSize cursorSize = [BBSUIHRColorCursor cursorSize];
    float shadowSize = [BBSUIHRColorCursor shadowSize];
    
    CGContextSaveGState(context);
    BBSUIHRSetRoundedRectanglePath(context, CGRectMake(shadowSize, shadowSize, cursorSize.width - shadowSize*2.0f, cursorSize.height - shadowSize*2.0f), 2.0f);
    [[UIColor whiteColor] set];
    CGContextSetShadow(context, CGSizeMake(0.0f, 1.0f), shadowSize);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
    
    
    [[UIColor colorWithRed:_currentColor.r green:_currentColor.g blue:_currentColor.b alpha:1.0f] set];
    CGContextFillRect(context, CGRectMake(outlineSize + shadowSize, outlineSize + shadowSize, cursorSize.width - (outlineSize + shadowSize)*2.0f, cursorSize.height - (outlineSize + shadowSize)*2.0f));
}


@end
