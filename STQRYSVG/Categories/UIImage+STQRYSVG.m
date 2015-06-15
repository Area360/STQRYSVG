//
//  UIImage+STQRYSVG.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "UIImage+STQRYSVG.h"
#import "STQRYSVGUtilities.h"
#import "STQRYSVGModel.h"

@implementation UIImage (STQRYSVG)

+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename
{
    return [self stqry_imageWithSVGNamed:filename size:CGSizeZero];
}

+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename size:(CGSize)targetSize
{
    NSParameterAssert(filename);
    
    CGPathRef path = [STQRYSVGUtilities cachedCGPathForKey:filename];
    if (!path) { // Not cached. Load from disk.
        path = [STQRYSVGUtilities loadSVGFileNamed:filename];
    }
    if (!path) { // Not found on disk. Bail.
        return nil;
    }
    
    BOOL shouldScale = !CGSizeEqualToSize(targetSize, CGSizeZero);
    CGSize imageSize;
    
    if (shouldScale) {
        path = [STQRYSVGUtilities scalePath:path toSize:targetSize];
        imageSize = targetSize;
    } else {
        imageSize = CGPathGetPathBoundingBox(path).size;
    }
    
    UIImage *image = [STQRYSVGUtilities renderPath:path size:imageSize];
    
    if (shouldScale) {
        CGPathRelease(path);
    }
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - CGPath helpers





@end
