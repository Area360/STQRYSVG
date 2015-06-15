//
//  STQRYSVGModel.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  This class represents an SVG model. It has a list of supported shapes that are used to generate a CGPath which can be used in a Cocoa application.
 */
@interface STQRYSVGModel : NSObject <NSXMLParserDelegate>

/// Array of STQRYSVGShape objects, created from parsing the XML during initialization.
@property (nonatomic, copy, readonly) NSArray *shapes;

/**
 *  Initializes a new SVG model with XML data.
 *
 *  @param svgData The SVG to parse to create the instructions needed to render.
 *
 *  @return An initialized instance, or nil if there was an error parsing the XML.
 */
- (instancetype)initWithSVGData:(NSData *)svgData;

/**
 *  Creates a new CGPath by adding subpaths created from iterating over `shapes`.
 *
 *  @return A new CGPath object. You are responsible for releasing this path yourself.
 */
- (CGPathRef)path;

@end
