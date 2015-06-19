//
//  UIButton+STQRYSVG.h
//  STQRYSVG
//
//  Created by Daniel Clelland on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This category adds support for calling the UIButton's `setImage:forState:` method with a rendered SVG images in Interface Builder.
 */
@interface UIButton (STQRYSVG)

/// The name of the SVG file to load, excluding the file extension. Upon setting, a new image is created and set for this button's UIControlStateNormal.
@property (nonatomic, copy) IBInspectable NSString *svgImageName;

/// The desired size of the image. Upon setting, a new image is created and set for this button's UIControlStateNormal.
@property (nonatomic, assign) IBInspectable CGSize svgImageSize;

@end
