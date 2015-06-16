//
//  STQRYSVGShape.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  Supported shape types.
 */
typedef NS_ENUM(NSInteger, STQRYSVGShapeType){
    STQRYSVGShapeTypeUnknown = 0, ///< Unknown or not supported.
    STQRYSVGShapeTypePath,        ///< Path type.
    STQRYSVGShapeTypeCircle,      ///< Circle shape.
    STQRYSVGShapeTypeEllipse,     ///< Ellipse shape.
    STQRYSVGShapeTypePolygon,     ///< Multiple lines that are closed.
    STQRYSVGShapeTypeRect,        ///< Rectangle shape.
    STQRYSVGShapeTypeLine,        ///< Singular line.
    STQRYSVGShapeTypePolyline     ///< Multiple lines that are not closed.
};

/**
 *  Converts the supported name element string, as listed in http://www.w3.org/TR/SVG/paths.html#PathElement and http://www.w3.org/TR/SVG/shapes.html , to its enumeration equivalent.
 *
 *  @param type The name of the element.
 *
 *  @return The matching enumeration value, or STQRYSVGShapeTypeUnknown if unknown.
 */
STQRYSVGShapeType SVGShapeTypeFromNSString(NSString *type);

/**
 *  This class represents a single shape or path from an SVG model.
 *
 *  Internally this class is a class cluster. A specific subclass is instantiated based on the `typeName` tag, and that subclass contains instructions on how to add points to a CGPath.
 */
@interface STQRYSVGShape : NSObject

/// The raw attributes found in the XML tag.
@property (nonatomic, copy, readonly) NSDictionary *attributes;

/// The type of shape this object is. This matches with what subclass is used, eg. STQRYSVGShapeTypeRect will have class type STQRYSVGShapeRect.
@property (nonatomic, assign, readonly) STQRYSVGShapeType type;

/**
 *  Creates a new SVG Shape object.
 *
 *  @param typeName   The element name for this shape.
 *  @param attributes The attributes included in the element.
 *
 *  @return An initialize instance, or nil if the element is not supported.
 */
+ (instancetype)svgShapeWithTypeName:(NSString *)typeName attributes:(NSDictionary *)attributes;

/**
 *  Starts a new subpath in the given path, and appends a list of CGPath elements to it. The path may not neccessarily be closed after this operation, as some paths do not close (such as line or polyline).
 *
 *  @param path      The path to append a subpath to.
 *  @param transform An optional transform to apply to the path being added.
 */
- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform *)transform;

/**
 *  Creates a new CGPath based on this shapes `type` and values in the `attributes` dictionary.
 *
 *  @param transform An optional transform to apply to the path.
 *
 *  @return A new CGPath. You are responsible for releasing this path yourself.
 */
- (CGPathRef)pathWithTransform:(CGAffineTransform *)transform;

/**
 *  Strokes the given path using values set from the `attributes` dictionary.
 *
 *  @param path    The path to stroke.
 *  @param context The context in which to render the stroked path into.
 */
- (void)strokePath:(CGPathRef)path inContext:(CGContextRef)context;

/**
 *  Creates a new CGPath by stroking the path returned from `-[pathWithTransform:]`.
 *
 *  @param transform An optional transform to apply to the path.
 *
 *  @return A new CGPath. You are responsible for releasing this path yourself.
 */
- (CGPathRef)strokePathWithTransform:(CGAffineTransform *)transform;

/**
 *  Whether or not this shape should be filled into a context.
 *
 *  @return YES if this shape should be filled, NO otherwise.
 */
- (BOOL)shouldFill;

/**
 *  Whether or not this shape should have a stroke rendered into a context.
 *
 *  @return YES if this shape should have a stroke rendered, NO otherwise.
 */
- (BOOL)shouldStroke;

/**
 *  Whether or not this shape uses the even/odd rule for filling its content.
 *
 *  @return YES if this shape uses the even/odd rule for filling content, NO if it uses the non-zero winding rule.
 */
- (BOOL)usesEvenOddFillRule;

/**
 *  The fill opacity value to use when rendering this shape.
 *
 *  @return The opacity value, between 0 and 1.
 */
- (CGFloat)fillOpacity;

/**
 *  The stroke opacity value to use when rendering this shape.
 *
 *  @return The opacity value, between 0 and 1.
 */
- (CGFloat)strokeOpacity;

/**
 *  The width of the line that should be used to stroke this shape. Default is 1.
 *
 *  @return The stroke width value.
 */
- (CGFloat)strokeWidth;

/**
 *  The line cap type used when stroking this shape. Default is `kCGLineCapButt`.
 *
 *  @return The line cap type. One of `kCGLineCapRound`, `kCGLineCapSquare`, `kCGLineCapButt`.
 */
- (CGLineCap)lineCap;

/**
 *  The line join mode used when stroking this shape. Default is `kCGLineJoinMiter`.
 *
 *  @return The line join type. One of `kCGLineJoinRound`, `kCGLineJoinBevel`, `kCGLineJoinMiter`.
 */
- (CGLineJoin)lineJoin;

/**
 *  The miter limit used when stroking this shape. Default is 4.
 *
 *  @return The miter limit value.
 */
- (CGFloat)miterLimit;

/**
 *  The transform that should be applied to this shape.
 *
 *  @return The CGAffineTransform mapping which transforms to apply to this shape when drawing. If no transforms should be applied then this is the identity transform.
 */
- (CGAffineTransform)transform;

@end
