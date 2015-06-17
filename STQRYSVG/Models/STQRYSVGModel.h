//
//  STQRYSVGModel.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STQRYSVGShape.h"

/**
 *  This class represents an SVG model. It has a list of supported shapes that are used to generate a CGPath which can be used in a Cocoa application.
 */
@interface STQRYSVGModel : NSObject <NSXMLParserDelegate>

/// Array of STQRYSVGShape objects, created from parsing the XML during initialization.
@property (nonatomic, copy, readonly) NSArray *shapes;

/// The name of this model.
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Initializes a new SVG model with XML data.
 *
 *  @param name    The name of this model.
 *  @param svgData The SVG to parse to create the instructions needed to render.
 *
 *  @return An initialized instance, or nil if there was an error parsing the XML.
 */
- (instancetype)initWithName:(NSString *)name data:(NSData *)svgData;

/**
 *  Creates a new CGPath by adding subpaths created from iterating over `shapes`.
 *
 *  @param transform An optional transform to apply to each path as it is added.
 *
 *  @return A new CGPath object. You are responsible for releasing this path yourself.
 */
- (CGPathRef)combinedPathsWithTransform:(CGAffineTransform *)transform;

/**
 *  Renders the SVG into a context.
 *
 *  @param context   The context to render into.
 *  @param transform An optional transform to apply to each path before it is rendered.
 */
- (void)renderInContext:(CGContextRef)context transform:(CGAffineTransform *)transform;

@end
