//
//  UIImageView+STQRYSVG.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This category adds support for setting the UIImageView's `image` property from rendered SVG images in Interface Builder.
 */
@interface UIImageView (STQRYSVG)

/// The name of the SVG file to load, excluding the file extension. Upon setting, a new image is created and set for this image view.
@property (nonatomic, copy) IBInspectable NSString *svgImageName;

/// The desired size of the image. Upon setting, a new image is created and set for this image view.
@property (nonatomic, assign) IBInspectable CGSize svgImageSize;

@end
