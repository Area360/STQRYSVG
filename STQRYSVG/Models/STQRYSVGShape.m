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

@interface STQRYSVGShape ()

@end

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
        NSMutableDictionary *strippedAttributes = [attributes mutableCopy];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            if (!obj.length || [obj isEqualToString:@"none"]) {
                [strippedAttributes removeObjectForKey:key];
            }
        }];
        _attributes = strippedAttributes;
        _type = type;
    }
    return self;
}

- (void)addToPath:(CGMutablePathRef)path
{
    /* Intentionally empty, implemented by private subclasses. */
}

@end

#pragma mark - Private Subclass Implementations

@implementation STQRYSVGShapeRect

- (void)addToPath:(CGMutablePathRef)path
{
    CGFloat x      = [self.attributes[@"x"]      doubleValue];
    CGFloat y      = [self.attributes[@"y"]      doubleValue];
    CGFloat width  = [self.attributes[@"width"]  doubleValue];
    CGFloat height = [self.attributes[@"height"] doubleValue];
    CGFloat rx     = [self.attributes[@"rx"]     doubleValue];
    CGFloat ry     = [self.attributes[@"ry"]     doubleValue];
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    if (rx == 0.0 && ry == 0.0) {
        CGPathAddRect(path, NULL, rect);
    } else {
        ry = (ry == 0.0) ? rx : ry;
        rx = (rx == 0.0) ? ry : rx;
        CGPathAddRoundedRect(path, NULL, rect, rx, ry);
    }
}

@end

@implementation STQRYSVGShapeCircle

- (void)addToPath:(CGMutablePathRef)path
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat r  = [self.attributes[@"r"]  doubleValue];
    CGFloat d  = r * 2;
    
    CGPathAddEllipseInRect(path, NULL, CGRectMake(cx - r, cy - r, d, d));
}

@end

@implementation STQRYSVGShapeEllipse

- (void)addToPath:(CGMutablePathRef)path
{
    CGFloat cx = [self.attributes[@"cx"] doubleValue];
    CGFloat cy = [self.attributes[@"cy"] doubleValue];
    CGFloat rx = [self.attributes[@"rx"] doubleValue];
    CGFloat ry = [self.attributes[@"ry"] doubleValue];
    
    CGPathAddEllipseInRect(path, NULL, CGRectMake(cx - rx, cy - ry, rx * 2, ry * 2));
}

@end

@implementation STQRYSVGShapeLine

- (void)addToPath:(CGMutablePathRef)path
{
    CGFloat x1 = [self.attributes[@"x1"] doubleValue];
    CGFloat y1 = [self.attributes[@"y1"] doubleValue];
    CGFloat x2 = [self.attributes[@"x2"] doubleValue];
    CGFloat y2 = [self.attributes[@"y2"] doubleValue];
    
    CGPathMoveToPoint   (path, NULL, x1, y1);
    CGPathAddLineToPoint(path, NULL, x2, y2);
}

@end

@implementation STQRYSVGShapePolyline

- (void)addToPath:(CGMutablePathRef)path
{
    NSArray *points = [self.attributes[@"points"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *validPoints = [points filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *str, NSDictionary *bindings) {
        return ([str rangeOfString:@","].location != NSNotFound);
    }]];
    
    [validPoints enumerateObjectsUsingBlock:^(NSString *pointString, NSUInteger idx, BOOL *stop) {
        NSArray *xyPoint = [pointString componentsSeparatedByString:@","];
        CGFloat x = [xyPoint[0] doubleValue];
        CGFloat y = [xyPoint[1] doubleValue];
        
        if (idx == 0) CGPathMoveToPoint   (path, NULL, x, y);
        else          CGPathAddLineToPoint(path, NULL, x, y);
    }];
}

@end

@implementation STQRYSVGShapePolygon

- (void)addToPath:(CGMutablePathRef)path
{
    [super addToPath:path];
    CGPathCloseSubpath(path);
}

@end

@implementation STQRYSVGShapePath

- (void)addToPath:(CGMutablePathRef)path
{
    CGPathAddPath(path, NULL, [PocketSVG pathFromDAttribute:self.attributes[@"d"]]);
}

@end
