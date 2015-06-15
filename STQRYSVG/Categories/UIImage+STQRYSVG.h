//
//  UIImage+STQRYSVG.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This category declares convienience methods for creating new UIImage objects which are rendered from SVG paths.
 */
@interface UIImage (STQRYSVG)

/**
 *  Creates a new UIImage object which is created from rendering the SVG file found in the application's main bundle. The image is a template, so its final colour will equal the value of its presenting view's `tintColor` property.
 *
 *  This calls `+[stqry_imageWithSVGNamed:size:]` with a size of CGSizeZero.
 *
 *  @param filename The name of the SVG file to read, excluding the file extension.
 *
 *  @return An initialized UIImage, or nil if the file could not be found or is not a valid SVG file.
 */
+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename;

/**
 *  Creates a new UIImage object which is created from rendering the SVG file found in the application's main bundle. The image is a template, so its final colour will equal the value of its presenting view's `tintColor` property.
 *
 *  @param filename The name of the SVG file to read, excluding the file extension.
 *  @param size     The desired size of the created image. Passing CGSizeZero will use the native size of the loaded SVG.
 *
 *  @return An initialized UIImage, or nil if the file could not be found or is not a valid SVG file.
 */
+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename size:(CGSize)size;

@end
