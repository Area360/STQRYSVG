//
//  STQRYSVGUtilities.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STQRYSVGModel.h"

/**
 *  This class provides utilities used by the framework, such as creating and rendering SVG Model objects. It also provides caching for efficient loading of models.
 */
@interface STQRYSVGUtilities : NSObject

/**
 *  Loads and returns an SVG file. Once loaded the model is cached, so any subsequent calls will not read from disk.
 *
 *  @param filename The name of the SVG file to load, excluding the file extension.
 *
 *  @return An initialized SVG model ready for rendering, or nil if there was an error in the SVG XML or the file was not found.
 */
+ (STQRYSVGModel *)SVGModelNamed:(NSString *)filename;

/**
 *  Renders the SVG file to a UIImage for displaying.
 *
 *  @param svgModel The SVG model to render.
 *  @param size     The desired size for the image to be.
 *
 *  @return An initialized UIImage created from the svg model data.
 */
+ (UIImage *)renderSVGModel:(STQRYSVGModel *)svgModel size:(CGSize)size;

@end
