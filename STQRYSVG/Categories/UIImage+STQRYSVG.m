//
//  UIImage+STQRYSVG.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "UIImage+STQRYSVG.h"
#import "STQRYSVGUtilities.h"

@implementation UIImage (STQRYSVG)

+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename
{
    return [self stqry_imageWithSVGNamed:filename size:CGSizeZero];
}

+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename size:(CGSize)size
{
    NSParameterAssert(filename);
    
    STQRYSVGModel *svgModel = [STQRYSVGUtilities SVGModelNamed:filename];
    UIImage *image = [STQRYSVGUtilities renderSVGModel:svgModel size:size];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
