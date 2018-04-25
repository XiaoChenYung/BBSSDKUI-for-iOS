
#import "BBSUIHRCgUtil.h"

void BBSUIHRSetRoundedRectanglePath(CGContextRef context,const CGRect rect,CGFloat radius){
    CGFloat lx = CGRectGetMinX(rect);
    CGFloat cx = CGRectGetMidX(rect);
    CGFloat rx = CGRectGetMaxX(rect);
    CGFloat by = CGRectGetMinY(rect);
    CGFloat cy = CGRectGetMidY(rect);
    CGFloat ty = CGRectGetMaxY(rect);
	
    CGContextMoveToPoint(context, lx, cy);
    CGContextAddArcToPoint(context, lx, by, cx, by, radius);
    CGContextAddArcToPoint(context, rx, by, rx, cy, radius);
    CGContextAddArcToPoint(context, rx, ty, cx, ty, radius);
    CGContextAddArcToPoint(context, lx, ty, lx, cy, radius);
    CGContextClosePath(context);
}

void BBSUIHRDrawSquareColorBatch(CGContextRef context,CGPoint position,BBSUIHRRGBColor* color,float size){
    float cx = position.x;
    float cy = position.y;
    
    float rRize = size;
    float backRSize = rRize + 3.0f;
    float shadowRSize = backRSize + 3.0f;
    
    CGRect rectEllipse = CGRectMake(cx - rRize, cy - rRize, rRize*2, rRize*2);
    CGRect rectBackEllipse = CGRectMake(cx - backRSize, cy - backRSize, backRSize*2, backRSize*2);
    CGRect rectShadowEllipse = CGRectMake(cx - shadowRSize, cy - shadowRSize, shadowRSize*2, shadowRSize*2);
    
    CGContextSaveGState(context);
    BBSUIHRSetRoundedRectanglePath(context, rectBackEllipse,8.0f);
    CGContextClip(context);
    BBSUIHRSetRoundedRectanglePath(context, rectShadowEllipse,8.0f);
    CGContextSetLineWidth(context, 5.5f);
    [[UIColor whiteColor] set];
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 4.0f, [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetRGBFillColor(context, color->r, color->g, color->b, 1.0f);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.5f), 0.5f, [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor);
    BBSUIHRSetRoundedRectanglePath(context, rectEllipse,5.0f);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
}
