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
@property (nonatomic, strong, readonly) NSDictionary *attributes;

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
 *  @param path The path to append a subpath to.
 */
- (void)addToPath:(CGMutablePathRef)path;

@end
