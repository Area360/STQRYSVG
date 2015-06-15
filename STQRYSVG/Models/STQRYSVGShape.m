//
//  STQRYSVGShape.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGShape.h"
#import <PocketSVG.h>

STQRYSVGShapeType SVGShapeTypeFromNSString(NSString *type)
{
    if      ([type isEqualToString:@"path"])     return STQRYSVGShapeTypePath;
    else if ([type isEqualToString:@"circle"])   return STQRYSVGShapeTypeCircle;
    else if ([type isEqualToString:@"ellipse"])  return STQRYSVGShapeTypeEllipse;
    else if ([type isEqualToString:@"polygon"])  return STQRYSVGShapeTypePolygon;
    else if ([type isEqualToString:@"rect"])     return STQRYSVGShapeTypeRect;
    else if ([type isEqualToString:@"line"])     return STQRYSVGShapeTypeLine;
    else if ([type isEqualToString:@"polyline"]) return STQRYSVGShapeTypePolyline;
    else                                         return STQRYSVGShapeTypeUnknown;
}

CGPathDrawingMode CGPathDrawingModeFromOptions(BOOL fill, BOOL stroke, BOOL eo)
{
    if      ( fill &&  stroke && eo) return kCGPathEOFillStroke;
    else if ( fill &&  stroke)       return kCGPathFillStroke;
    else if ( fill && !stroke && eo) return kCGPathEOFill;
    else if ( fill && !stroke)       return kCGPathFill;
    else if (!fill &&  stroke)       return kCGPathStroke;
    else                             return (CGPathDrawingMode)-1;
}

CGLineCap CGLineCapFromNSString(NSString *cap)
{
    if      ([cap isEqualToString:@"round"])  return kCGLineCapRound;
    else if ([cap isEqualToString:@"square"]) return kCGLineCapSquare;
    else                                      return kCGLineCapButt;
}

CGLineJoin CGLineJoinFromNSString(NSString *join)
{
    if      ([join isEqualToString:@"round"]) return kCGLineJoinRound;
    else if ([join isEqualToString:@"bevel"]) return kCGLineJoinBevel;
    else                                      return kCGLineJoinMiter;
}

#pragma mark - Private Subclasses

@interface STQRYSVGShapeRect     : STQRYSVGShape         @end
@interface STQRYSVGShapeCircle   : STQRYSVGShape         @end
@interface STQRYSVGShapeEllipse  : STQRYSVGShape         @end
@interface STQRYSVGShapeLine     : STQRYSVGShape         @end
@interface STQRYSVGShapePolyline : STQRYSVGShape         @end
@interface STQRYSVGShapePolygon  : STQRYSVGShapePolyline @end
@interface STQRYSVGShapePath     : STQRYSVGShape         @end

NS_INLINE Class ClassFromSVGShapeType(STQRYSVGShapeType type)
{
    switch (type) {
        case STQRYSVGShapeTypePath:     return [STQRYSVGShapePath     class];
        case STQRYSVGShapeTypeCircle:   return [STQRYSVGShapeCircle   class];
        case STQRYSVGShapeTypeEllipse:  return [STQRYSVGShapeEllipse  class];
        case STQRYSVGShapeTypePolygon:  return [STQRYSVGShapePolygon  class];
        case STQRYSVGShapeTypeRect:     return [STQRYSVGShapeRect     class];
        case STQRYSVGShapeTypeLine:     return [STQRYSVGShapeLine     class];
        case STQRYSVGShapeTypePolyline: return [STQRYSVGShapePolyline class];
        default:                        return nil;
    }
}

#pragma mark - Public Superclass

@implementation STQRYSVGShape

+ (instancetype)svgShapeWithTypeName:(NSString *)typeName attributes:(NSDictionary *)attributes
{
    STQRYSVGShapeType type = SVGShapeTypeFromNSString(typeName);
    Class class = ClassFromSVGShapeType(type);
    
    return [[class alloc] initWithType:type attributes:attributes];
}

- (instancetype)initWithType:(STQRYSVGShapeType)type attributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _attributes = attributes;
        _type = type;
    }
    return self;
}

- (BOOL)shouldFill
{
    return ![self.attributes[@"fill"] isEqualToString:@"none"] && self.fillOpacity > 0.0;
}

- (BOOL)shouldStroke
{
    return ![self.attributes[@"stroke"] isEqualToString:@"none"] && self.strokeOpacity > 0.0 && self.strokeWidth > 0.0;
}

- (BOOL)usesEvenOddFillRule
{
    return [self.attributes[@"fill-rule"] isEqualToString:@"evenodd"];
}

- (CGFloat)fillOpacity
{
    NSNumber *fillOpacity = self.attributes[@"fill-opacity"];
    return fillOpacity ? [fillOpacity doubleValue] : 1.0;
}

- (CGFloat)strokeOpacity
{
    NSNumber *strokeOpacity = self.attributes[@"stroke-opacity"];
    return strokeOpacity ? [strokeOpacity doubleValue] : 1.0;
}

- (CGFloat)strokeWidth
{
    NSNumber *strokeWidth = self.attributes[@"stroke-width"];
    return strokeWidth ? [strokeWidth doubleValue] : 1.0;
}

- (CGLineCap)lineCap
{
    return CGLineCapFromNSString(self.attributes[@"stroke-linecap"]);
}

- (CGLineJoin)lineJoin
{
    return CGLineJoinFromNSString(self.attributes[@"stroke-linejoin"]);
}

- (CGFloat)miterLimit
{
    NSNumber *miterLimit = self.attributes[@"stroke-miterlimit"];
    return miterLimit ? [miterLimit doubleValue] : 4.0;
}

- (void)strokePath:(CGPathRef)path inContext:(CGContextRef)context
{
    CGContextSetGrayStrokeColor(context, 0.0, self.strokeOpacity);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetLineCap(context, self.lineCap);
    CGContextSetLineJoin(context, self.lineJoin);
    CGContextSetMiterLimit(context, self.miterLimit);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

- (CGPathRef)strokePathWithTransform:(CGAffineTransform *)transform
{
    CGPathRef path = [self pathWithTransform:transform];
    CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(path, NULL, self.strokeWidth, self.lineCap, self.lineJoin, self.miterLimit);
    CGPathRelease(path);
    return strokedPath;
}

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    /* Intentionally empty, implemented in subclasses. */
    return nil;
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    /* Intentionally empty, implemented in subclasses. */
}

@end

#pragma mark - Private Subclass Implementations

@implementation STQRYSVGShapeRect

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGFloat x      = [self.attributes[@"x"]      doubleValue];
    CGFloat y      = [self.attributes[@"y"]      doubleValue];
    CGFloat width  = [self.attributes[@"width"]  doubleValue];
    CGFloat height = [self.attributes[@"height"] doubleValue];
    CGFloat rx     = [self.attributes[@"rx"]     doubleValue];
    CGFloat ry     = [self.attributes[@"ry"]     doubleValue];
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    if (rx == 0.0 && ry == 0.0) {
        return CGPathCreateWithRect(rect, transform);
    } else {
        ry = (ry == 0.0) ? rx : ry;
        rx = (rx == 0.0) ? ry : rx;
        return CGPathCreateWithRoundedRect(rect, rx, ry, transform);
    }
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    CGFloat x      = [self.attributes[@"x"]      doubleValue];
    CGFloat y      = [self.attributes[@"y"]      doubleValue];
    CGFloat width  = [self.attributes[@"width"]  doubleValue];
    CGFloat height = [self.attributes[@"height"] doubleValue];
    CGFloat rx     = [self.attributes[@"rx"]     doubleValue];
    CGFloat ry     = [self.attributes[@"ry"]     doubleValue];
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    if (rx == 0.0 && ry == 0.0) {
        CGPathAddRect(path, transform, rect);
    } else {
        ry = (ry == 0.0) ? rx : ry;
        rx = (rx == 0.0) ? ry : rx;
        CGPathAddRoundedRect(path, transform, rect, rx, ry);
    }
}

@end

@implementation STQRYSVGShapeCircle

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat r  = [self.attributes[@"r"]  doubleValue];
    CGFloat d  = r * 2;
    
    return CGPathCreateWithEllipseInRect(CGRectMake(cx - r, cy - r, d, d), transform);
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat r  = [self.attributes[@"r"]  doubleValue];
    CGFloat d  = r * 2;
    
    CGPathAddEllipseInRect(path, transform, CGRectMake(cx - r, cy - r, d, d));
}

@end

@implementation STQRYSVGShapeEllipse

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat rx = [self.attributes[@"rx"] doubleValue];
    CGFloat ry = [self.attributes[@"ry"] doubleValue];
    
    return CGPathCreateWithEllipseInRect(CGRectMake(cx - rx, cy - ry, rx * 2, ry * 2), transform);
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat rx = [self.attributes[@"rx"] doubleValue];
    CGFloat ry = [self.attributes[@"ry"] doubleValue];
    
    CGPathAddEllipseInRect(path, transform, CGRectMake(cx - rx, cy - ry, rx * 2, ry * 2));
}

@end

@implementation STQRYSVGShapeLine

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGFloat x1 = [self.attributes[@"x1"] doubleValue];
    CGFloat y1 = [self.attributes[@"y1"] doubleValue];
    CGFloat x2 = [self.attributes[@"x2"] doubleValue];
    CGFloat y2 = [self.attributes[@"y2"] doubleValue];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint   (path, transform, x1, y1);
    CGPathAddLineToPoint(path, transform, x2, y2);
    return path;
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    CGFloat x1 = [self.attributes[@"x1"] doubleValue];
    CGFloat y1 = [self.attributes[@"y1"] doubleValue];
    CGFloat x2 = [self.attributes[@"x2"] doubleValue];
    CGFloat y2 = [self.attributes[@"y2"] doubleValue];
    
    CGPathMoveToPoint(path, transform, x1, y1);
    CGPathAddLineToPoint(path, transform, x2, y2);
}

@end

@implementation STQRYSVGShapePolyline

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGMutablePathRef path = CGPathCreateMutable();
    [self addToPath:path transform:transform];
    return path;
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    NSArray *points = [self.attributes[@"points"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *validPoints = [points filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *str, NSDictionary *bindings) {
        return ([str rangeOfString:@","].location != NSNotFound);
    }]];
    
    [validPoints enumerateObjectsUsingBlock:^(NSString *pointString, NSUInteger idx, BOOL *stop) {
        NSArray *xyPoint = [pointString componentsSeparatedByString:@","];
        CGFloat x = [xyPoint[0] doubleValue];
        CGFloat y = [xyPoint[1] doubleValue];
        
        if (idx == 0) CGPathMoveToPoint   (path, transform, x, y);
        else          CGPathAddLineToPoint(path, transform, x, y);
    }];
}

@end

@implementation STQRYSVGShapePolygon

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    CGMutablePathRef path = (CGMutablePathRef)[super pathWithTransform:transform];
    CGPathCloseSubpath(path);
    return path;
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    [super addToPath:path transform:transform];
    CGPathCloseSubpath(path);
}

@end

@implementation STQRYSVGShapePath

- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform
{
    return CGPathCreateCopyByTransformingPath([PocketSVG pathFromDAttribute:self.attributes[@"d"]], transform);
}

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform
{
    CGPathAddPath(path, transform, [PocketSVG pathFromDAttribute:self.attributes[@"d"]]);
}

@end
